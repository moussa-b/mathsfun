import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathsfun/core/constants/speech_constants.dart';
import 'package:mathsfun/data/services/speech_model_service.dart';

/// Serves a fake model bucket on 127.0.0.1.
class _FakeBucket {
  _FakeBucket(this._server);

  final HttpServer _server;
  final Map<String, List<int>> files = <String, List<int>>{};
  bool offline = false;

  /// Paths answered with headers and a first byte, then never finished.
  final Set<String> stalled = <String>{};

  /// Paths whose body is served with this many bytes (lying about size).
  final Map<String, int> padded = <String, int>{};

  String get baseUrl => 'http://127.0.0.1:${_server.port}/asr';

  static Future<_FakeBucket> start() async {
    final HttpServer server = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final _FakeBucket bucket = _FakeBucket(server);
    server.listen((HttpRequest request) async {
      final String path = request.uri.path.replaceFirst('/asr/', '');
      final List<int>? body = bucket.offline ? null : bucket.files[path];
      if (body != null && bucket.stalled.contains(path)) {
        request.response.add(body.take(1).toList());
        await request.response.flush();
        return;
      }
      if (body != null && bucket.padded.containsKey(path)) {
        request.response.add(List<int>.filled(bucket.padded[path]!, 0x41));
        await request.response.close();
        return;
      }
      if (body == null) {
        request.response.statusCode = HttpStatus.notFound;
      } else {
        request.response.add(body);
      }
      await request.response.close();
    });
    return bucket;
  }

  /// Publishes [version] of [lang] and returns the manifest it wrote.
  void publish(String lang, String version, {String? corruptFile}) {
    final List<Map<String, Object>> entries = <Map<String, Object>>[];
    for (final String name in kSpeechModelFiles) {
      final List<int> content = utf8.encode('$lang/$version/$name');
      files['$lang/$version/$name'] = name == corruptFile
          ? utf8.encode('tampered')
          : content;
      entries.add(<String, Object>{
        'name': name,
        'size': name == corruptFile ? 'tampered'.length : content.length,
        'sha256': sha256.convert(content).toString(),
      });
    }
    files[kSpeechModelManifest] = utf8.encode(
      jsonEncode(<String, Object>{
        'schema': 1,
        'languages': <String, Object>{
          lang: <String, Object>{
            'version': version,
            'model': 'fake',
            'files': entries,
          },
        },
      }),
    );
  }

  Future<void> close() => _server.close(force: true);
}

void main() {
  late _FakeBucket bucket;
  late Directory cache;
  late SpeechModelService service;

  setUp(() async {
    bucket = await _FakeBucket.start();
    cache = await Directory.systemTemp.createTemp('asr_test');
    service = SpeechModelService(
      baseUrl: bucket.baseUrl,
      baseDirectoryProvider: () async => cache,
    );
  });

  tearDown(() async {
    service.dispose();
    await bucket.close();
    await cache.delete(recursive: true);
  });

  Directory versionDir(String lang, String version) =>
      Directory('${cache.path}/asr/$lang/$version');

  // protects=a verified model becomes ready on disk (AC3);
  // fails_when=files are missing, .part files remain or status is not ready;
  // no_claim=real R2/HTTPS behaviour (a local HTTP server stands in for it).
  test('downloads, verifies and marks the model ready', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');

    expect(service.stateFor('fr').status, SpeechModelStatus.ready);
    final Directory dir = versionDir('fr', 'v1');
    for (final String name in kSpeechModelFiles) {
      expect(File('${dir.path}/$name').existsSync(), isTrue, reason: name);
    }
    expect(File('${dir.path}/.complete').readAsStringSync(), 'v1');
    expect(
      dir.listSync().where((FileSystemEntity e) => e.path.endsWith('.part')),
      isEmpty,
    );
    expect(await service.modelDir('fr'), dir.path);
    expect(await service.installedBytes(), greaterThan(0));
  });

  // protects=a tampered file is never used (AC4);
  // fails_when=the model is marked ready or partial files stay on disk;
  // no_claim=none beyond protects.
  test('rejects a file whose sha256 does not match', () async {
    bucket.publish('fr', 'v1', corruptFile: 'encoder.onnx');
    await service.download('fr');

    expect(service.stateFor('fr').status, SpeechModelStatus.error);
    expect(versionDir('fr', 'v1').existsSync(), isFalse);
    expect(await service.modelDir('fr'), isNull);
  });

  // protects=network/HTTP failures surface as a retryable error;
  // fails_when=status is ready/downloading after a 404; no_claim=none.
  test('reports an error when the bucket answers 404', () async {
    await service.download('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.error);

    bucket.publish('fr', 'v1');
    await service.download('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.ready);
  });

  // protects=an interrupted download or purged cache is detected (AC5);
  // fails_when=leftover folders count as ready or are not cleaned up;
  // no_claim=OS-level cache purging itself.
  test('refresh drops incomplete folders and detects purged files', () async {
    final Directory orphan = versionDir('fr', 'v1')..createSync(recursive: true);
    File('${orphan.path}/encoder.onnx.part').writeAsStringSync('half');
    await service.refresh('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.absent);
    expect(orphan.existsSync(), isFalse);

    bucket.publish('fr', 'v1');
    await service.download('fr');
    File('${versionDir('fr', 'v1').path}/tokens.txt').deleteSync();
    await service.refresh('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.absent);
  });

  // protects=a ready model survives an app restart; fails_when=a fresh
  // service does not see the installed model; no_claim=none.
  test('a new service instance sees the installed model', () async {
    bucket.publish('en', 'v1');
    await service.download('en');

    final SpeechModelService restarted = SpeechModelService(
      baseUrl: bucket.baseUrl,
      baseDirectoryProvider: () async => cache,
    );
    await restarted.refresh('en');
    expect(restarted.stateFor('en').status, SpeechModelStatus.ready);
    restarted.dispose();
  });

  // protects=deleting from parent settings frees the space (AC17);
  // fails_when=files remain or status stays ready; no_claim=none.
  test('deleteAll removes every model', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');
    await service.deleteAll();

    expect(service.stateFor('fr').status, SpeechModelStatus.absent);
    expect(Directory('${cache.path}/asr/fr').existsSync(), isFalse);
    expect(await service.installedBytes(), 0);
  });

  // protects=a new published version replaces the old one (AC15);
  // fails_when=the old model stays ready after a version bump;
  // no_claim=none beyond protects.
  test('checkForUpdate drops the model when the version changed', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');
    bucket.publish('fr', 'v2');

    await service.checkForUpdate('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.absent);
    expect(versionDir('fr', 'v1').existsSync(), isFalse);
  });

  // protects=offline use never breaks a ready model (AC15);
  // fails_when=a failed check changes the state; no_claim=none.
  test('checkForUpdate keeps the model when offline', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');
    bucket.offline = true;

    await service.checkForUpdate('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.ready);
  });

  // protects=re-entering the mode screen (tile refresh) while a download runs
  // never disturbs that download; fails_when=refresh() resets the state or
  // deletes the folder being written; no_claim=a slow real network (the local
  // server answers at once); why_new=existing refresh tests only run on idle
  // models; seam=none.
  test('refresh leaves a running download alone', () async {
    bucket.publish('fr', 'v1');
    final Future<void> downloading = service.download('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.downloading);

    await service.refresh('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.downloading);

    await downloading;
    expect(service.stateFor('fr').status, SpeechModelStatus.ready);
    expect(await service.modelDir('fr'), versionDir('fr', 'v1').path);
  });

  // protects=deleting the models in parent settings also stops a download in
  // progress, so the models do not come back afterwards; fails_when=deleteAll
  // skips the running download or leaves files behind; no_claim=a real slow
  // network (a stalled local response stands in); why_new=red-team finding
  // on the 'Voice models deleted' message lying; seam=none.
  test('deleteAll cancels a running download', () async {
    bucket.publish('fr', 'v1');
    bucket.stalled.add('fr/v1/encoder.onnx');
    final Future<void> downloading = service.download('fr');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(service.stateFor('fr').status, SpeechModelStatus.downloading);

    await service.deleteAll();
    await downloading;
    expect(service.stateFor('fr').status, SpeechModelStatus.absent);
    expect(Directory('${cache.path}/asr/fr').existsSync(), isFalse);
  });

  // protects=a connection that stops sending never locks the voice tile;
  // fails_when=the download waits forever in `downloading`; no_claim=real
  // network stalls (a local response that never ends stands in, with a short
  // idle timeout); why_new=no timeout existed (testing + adversarial
  // findings); seam=idleTimeout is the production setting, shortened here.
  test('a stalled download fails after the idle timeout', () async {
    final SpeechModelService impatient = SpeechModelService(
      baseUrl: bucket.baseUrl,
      baseDirectoryProvider: () async => cache,
      idleTimeout: const Duration(milliseconds: 300),
    );
    bucket.publish('fr', 'v1');
    bucket.stalled.add('fr/v1/encoder.onnx');
    await impatient.download('fr');
    expect(impatient.stateFor('fr').status, SpeechModelStatus.error);
    expect(versionDir('fr', 'v1').existsSync(), isFalse);
    impatient.dispose();
  });

  // protects=a response longer than announced is cut short and rejected;
  // fails_when=the oversized file is written in full or accepted;
  // no_claim=none beyond protects; why_new=only the sha256 branch was tested;
  // seam=none.
  test('rejects a file larger than the manifest size', () async {
    bucket.publish('fr', 'v1');
    bucket.padded['fr/v1/decoder.onnx'] = 4096;
    await service.download('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.error);
    expect(versionDir('fr', 'v1').existsSync(), isFalse);
  });

  // protects=a quick tap before the first disk check never re-downloads (and
  // deletes) a model already on disk; fails_when=download() wipes the
  // installed folder; no_claim=none; why_new=adversarial finding M2;
  // seam=none.
  test('download reuses a complete model already on disk', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');
    final File marker = File('${versionDir('fr', 'v1').path}/.complete');
    final DateTime written = marker.lastModifiedSync();

    final SpeechModelService fresh = SpeechModelService(
      baseUrl: bucket.baseUrl,
      baseDirectoryProvider: () async => cache,
    );
    bucket.offline = true;
    await fresh.download('fr');
    expect(fresh.stateFor('fr').status, SpeechModelStatus.ready);
    expect(marker.lastModifiedSync(), written);
    fresh.dispose();
  });

  // protects=an update check with the same version keeps the 71 MB model;
  // fails_when=the version comparison breaks and the model is deleted;
  // no_claim=none; why_new=testing specialist finding; seam=none.
  test('checkForUpdate keeps the model when the version is unchanged', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');
    await service.checkForUpdate('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.ready);
    expect(versionDir('fr', 'v1').existsSync(), isTrue);
  });

  // protects=an exercise using the model never sees it deleted by an update
  // check; fails_when=checkForUpdate deletes an acquired model; no_claim=none;
  // why_new=adversarial/red-team finding; seam=none.
  test('checkForUpdate never removes a model in use', () async {
    bucket.publish('fr', 'v1');
    await service.download('fr');
    service.acquire('fr');
    bucket.publish('fr', 'v2');
    await service.checkForUpdate('fr');
    expect(service.stateFor('fr').status, SpeechModelStatus.ready);
    expect(versionDir('fr', 'v1').existsSync(), isTrue);
    service.release('fr');
  });

  // protects=a hostile manifest cannot write outside the model folder;
  // fails_when=path-like names or versions are accepted; no_claim=none.
  test('manifest parser rejects unsafe names and versions', () {
    String manifest(String version, String name) => jsonEncode(<String, Object>{
      'schema': 1,
      'languages': <String, Object>{
        'fr': <String, Object>{
          'version': version,
          'files': <Object>[
            for (final String file in kSpeechModelFiles)
              <String, Object>{
                'name': file == 'tokens.txt' ? name : file,
                'size': 1,
                'sha256': 'ab',
              },
          ],
        },
      },
    });

    expect(SpeechModelRelease.fromManifest(manifest('v1', 'tokens.txt'), 'fr'),
        isNotNull);
    expect(SpeechModelRelease.fromManifest(manifest('../x', 'tokens.txt'), 'fr'),
        isNull);
    expect(SpeechModelRelease.fromManifest(manifest('v1', '../tokens.txt'), 'fr'),
        isNull);
    expect(SpeechModelRelease.fromManifest(manifest('v1', 'tokens.txt'), 'en'),
        isNull);
  });
}
