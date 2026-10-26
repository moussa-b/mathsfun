import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/constants/speech_constants.dart';

enum SpeechModelStatus { absent, downloading, ready, error }

@immutable
class SpeechModelState {
  const SpeechModelState({required this.status, this.progress = 0});

  const SpeechModelState.absent() : this(status: SpeechModelStatus.absent);

  final SpeechModelStatus status;

  /// Download progress between 0 and 1, meaningful while [status] is
  /// [SpeechModelStatus.downloading].
  final double progress;
}

/// A file entry of the manifest.
@immutable
class SpeechModelFile {
  const SpeechModelFile({
    required this.name,
    required this.size,
    required this.sha256,
  });

  final String name;
  final int size;
  final String sha256;
}

/// One language entry of the manifest.
@immutable
class SpeechModelRelease {
  const SpeechModelRelease({required this.version, required this.files});

  final String version;
  final List<SpeechModelFile> files;

  int get totalBytes =>
      files.fold<int>(0, (int sum, SpeechModelFile f) => sum + f.size);

  /// The version doubles as a folder name.
  static final RegExp safeVersion = RegExp(r'^[A-Za-z0-9_-]{1,32}$');

  /// Parses the entry for [lang], keeping only the files this app loads.
  /// Returns `null` for anything unexpected.
  static SpeechModelRelease? fromManifest(String json, String lang) {
    final Object? decoded = jsonDecode(json);
    if (decoded is! Map<String, dynamic> || decoded['schema'] != 1) {
      return null;
    }
    final Object? languages = decoded['languages'];
    if (languages is! Map<String, dynamic>) {
      return null;
    }
    final Object? entry = languages[lang];
    if (entry is! Map<String, dynamic>) {
      return null;
    }
    final Object? version = entry['version'];
    final Object? files = entry['files'];
    if (version is! String ||
        !safeVersion.hasMatch(version) ||
        files is! List<dynamic>) {
      return null;
    }
    final Map<String, SpeechModelFile> byName = <String, SpeechModelFile>{};
    for (final Object? file in files) {
      if (file is! Map<String, dynamic> ||
          file['name'] is! String ||
          file['size'] is! int ||
          file['sha256'] is! String) {
        return null;
      }
      final String name = file['name'] as String;
      final int size = file['size'] as int;
      // Only the known files, with a sane size: the names become paths in
      // the model folder and the bytes go to a native parser.
      if (!kSpeechModelFiles.contains(name)) {
        continue;
      }
      if (size <= 0 || size > kSpeechModelMaxFileBytes) {
        return null;
      }
      byName[name] = SpeechModelFile(
        name: name,
        size: size,
        sha256: (file['sha256'] as String).toLowerCase(),
      );
    }
    if (!kSpeechModelFiles.every(byName.containsKey)) {
      return null;
    }
    return SpeechModelRelease(
      version: version,
      files: <SpeechModelFile>[
        for (final String name in kSpeechModelFiles) byName[name]!,
      ],
    );
  }
}

/// Downloads, verifies and stores the on-device speech recognition models.
///
/// Models live in the OS cache folder (`<Caches>/asr/<lang>/<version>/`) so
/// they are never backed up to iCloud; the OS may purge them, which is why
/// [refresh] is called before every use.
class SpeechModelService extends ChangeNotifier {
  SpeechModelService({
    Future<Directory> Function()? baseDirectoryProvider,
    String? baseUrl,
    this.connectionTimeout = const Duration(seconds: 15),
    this.idleTimeout = const Duration(seconds: 30),
  }) : _baseDirectoryProvider =
           baseDirectoryProvider ?? getApplicationCacheDirectory,
       _baseUrl = baseUrl ?? kSpeechModelBaseUrl;

  static const String _completeMarker = '.complete';
  static const Duration _updateCheckTimeout = Duration(seconds: 3);
  static const Duration _availabilityTimeout = Duration(seconds: 5);
  static const Duration _progressInterval = Duration(milliseconds: 250);
  static const int _maxManifestBytes = 64 * 1024;

  /// Time allowed to open a connection to the model host.
  final Duration connectionTimeout;

  /// Longest silence tolerated in a response before the download fails.
  final Duration idleTimeout;

  final Future<Directory> Function() _baseDirectoryProvider;
  final String _baseUrl;

  final Map<String, SpeechModelState> _states = <String, SpeechModelState>{};
  final Map<String, String> _installedVersions = <String, String>{};
  final Map<String, HttpClient> _activeClients = <String, HttpClient>{};
  final Map<String, int> _inUse = <String, int>{};
  final Set<String> _updateChecked = <String>{};
  final Map<String, bool> _published = <String, bool>{};
  final Map<String, Future<void>> _availabilityChecks =
      <String, Future<void>>{};
  bool _disposed = false;

  SpeechModelState stateFor(String lang) =>
      _states[lang] ?? const SpeechModelState.absent();

  /// Whether the model host publishes a model for [lang]: `null` until
  /// [checkAvailability] has answered.
  bool? isPublished(String lang) => _published[lang];

  /// Asks the model host whether it publishes a model for [lang]. A positive
  /// answer holds for the app launch; a negative one is asked again on the
  /// next call, so the voice mode shows up once the host is back.
  Future<void> checkAvailability(String lang) {
    if (_published[lang] == true) {
      return Future<void>.value();
    }
    // A block body: whenComplete would otherwise wait on the removed future,
    // which is this very check.
    return _availabilityChecks[lang] ??= _probe(lang).whenComplete(() {
      _availabilityChecks.remove(lang);
    });
  }

  Future<void> _probe(String lang) async {
    bool published;
    try {
      published =
          await _fetchRelease(lang).timeout(_availabilityTimeout) != null;
    } catch (error) {
      debugPrint('Voice model host unreachable: $error');
      published = false;
    }
    if (_published[lang] != published) {
      _published[lang] = published;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Folder holding the ready model for [lang], or `null` when not ready.
  Future<String?> modelDir(String lang) async {
    final String? version = _installedVersions[lang];
    if (version == null || stateFor(lang).status != SpeechModelStatus.ready) {
      return null;
    }
    return (await _versionDir(lang, version)).path;
  }

  /// Marks the model of [lang] as loaded by an exercise: it is never removed
  /// by an update check until [release] is called.
  void acquire(String lang) => _inUse[lang] = (_inUse[lang] ?? 0) + 1;

  void release(String lang) {
    final int count = (_inUse[lang] ?? 0) - 1;
    if (count <= 0) {
      _inUse.remove(lang);
    } else {
      _inUse[lang] = count;
    }
  }

  /// Checks what is on disk for [lang]. Never touches the network.
  Future<void> refresh(String lang) async {
    if (_isDownloading(lang)) {
      return;
    }
    final String? readyVersion = await _scanDisk(lang);
    // A download may have started while the disk was being read.
    if (_isDownloading(lang)) {
      return;
    }
    if (readyVersion == null) {
      _installedVersions.remove(lang);
      _setState(lang, const SpeechModelState.absent());
    } else {
      _installedVersions[lang] = readyVersion;
      _setState(lang, const SpeechModelState(status: SpeechModelStatus.ready));
    }
  }

  /// Best effort, once per app launch: if the published version differs from
  /// the installed one and no exercise uses the model, drops it so the next
  /// tap downloads the new one.
  Future<void> checkForUpdate(String lang) async {
    final String? installed = _installedVersions[lang];
    if (installed == null ||
        stateFor(lang).status != SpeechModelStatus.ready ||
        !_updateChecked.add(lang)) {
      return;
    }
    final SpeechModelRelease? release;
    try {
      release = await _fetchRelease(lang).timeout(_updateCheckTimeout);
    } catch (_) {
      _updateChecked.remove(lang);
      return;
    }
    if (release == null ||
        release.version == installed ||
        stateFor(lang).status != SpeechModelStatus.ready) {
      return;
    }
    if (_inUse.containsKey(lang)) {
      // Try again on the next visit, once the exercise has closed.
      _updateChecked.remove(lang);
      return;
    }
    await _deleteLang(lang);
    _installedVersions.remove(lang);
    _setState(lang, const SpeechModelState.absent());
  }

  /// Downloads the model for [lang]. Does nothing while a download is
  /// running or once the model is ready, including a ready model found on
  /// disk before the first [refresh] completed.
  Future<void> download(String lang) async {
    final SpeechModelStatus status = stateFor(lang).status;
    if (status == SpeechModelStatus.downloading ||
        status == SpeechModelStatus.ready) {
      return;
    }
    _setState(
      lang,
      const SpeechModelState(status: SpeechModelStatus.downloading),
    );
    final HttpClient client = _newClient();
    _activeClients[lang] = client;

    Directory? target;
    try {
      final String? onDisk = await _scanDisk(lang);
      if (onDisk != null) {
        _installedVersions[lang] = onDisk;
        _setState(
          lang,
          const SpeechModelState(status: SpeechModelStatus.ready),
        );
        return;
      }
      final SpeechModelRelease? release = await _fetchRelease(
        lang,
        client: client,
      );
      if (release == null) {
        throw const FormatException('invalid manifest');
      }
      await _deleteLang(lang);
      target = await _versionDir(lang, release.version);
      await target.create(recursive: true);

      final int total = release.totalBytes;
      int received = 0;
      DateTime lastNotify = DateTime.fromMillisecondsSinceEpoch(0);
      for (final SpeechModelFile file in release.files) {
        await _downloadFile(client, lang, release.version, file, target, (
          int chunk,
        ) {
          received += chunk;
          final DateTime now = DateTime.now();
          if (now.difference(lastNotify) >= _progressInterval) {
            lastNotify = now;
            _setState(
              lang,
              SpeechModelState(
                status: SpeechModelStatus.downloading,
                progress: (received / total).clamp(0, 1),
              ),
            );
          }
        });
      }
      await File(
        '${target.path}/$_completeMarker',
      ).writeAsString(release.version, flush: true);
      _installedVersions[lang] = release.version;
      _setState(lang, const SpeechModelState(status: SpeechModelStatus.ready));
    } catch (error) {
      debugPrint('Speech model download failed ($lang): $error');
      try {
        if (target != null && await target.exists()) {
          await target.delete(recursive: true);
        }
      } on FileSystemException catch (cleanupError) {
        debugPrint('Speech model cleanup failed ($lang): $cleanupError');
      }
      _installedVersions.remove(lang);
      _setState(lang, const SpeechModelState(status: SpeechModelStatus.error));
    } finally {
      _activeClients.remove(lang);
      client.close(force: true);
    }
  }

  /// Removes the models of every language, cancelling running downloads.
  /// A model an exercise is using is kept.
  Future<void> deleteAll() async {
    for (final String lang in kSpeechModelLanguages) {
      if (_inUse.containsKey(lang)) {
        continue;
      }
      final HttpClient? running = _activeClients[lang];
      if (running != null) {
        running.close(force: true);
        // Let the cancelled download clean up and settle in `error`.
        final DateTime giveUp = DateTime.now().add(const Duration(seconds: 5));
        while (_isDownloading(lang) && DateTime.now().isBefore(giveUp)) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }
      }
      await _deleteLang(lang);
      _installedVersions.remove(lang);
      _setState(lang, const SpeechModelState.absent());
    }
  }

  /// Bytes used on disk by all installed models (0 when unreadable).
  Future<int> installedBytes() async {
    try {
      final Directory root = await _rootDir();
      if (!await root.exists()) {
        return 0;
      }
      int total = 0;
      await for (final FileSystemEntity entity in root.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
      return total;
    } on FileSystemException {
      return 0;
    }
  }

  bool _isDownloading(String lang) =>
      stateFor(lang).status == SpeechModelStatus.downloading;

  HttpClient _newClient() =>
      HttpClient()..connectionTimeout = connectionTimeout;

  /// Returns the version of the complete model on disk, removing leftovers
  /// of interrupted or purged downloads. Unreadable files count as absent.
  Future<String?> _scanDisk(String lang) async {
    try {
      return await _scanDiskUnsafe(lang);
    } on FileSystemException catch (error) {
      debugPrint('Speech model scan failed ($lang): $error');
      return null;
    } on FormatException catch (error) {
      debugPrint('Speech model marker unreadable ($lang): $error');
      return null;
    }
  }

  Future<String?> _scanDiskUnsafe(String lang) async {
    final Directory langDir = await _langDir(lang);
    if (!await langDir.exists()) {
      return null;
    }
    String? readyVersion;
    final List<Directory> leftovers = <Directory>[];
    await for (final FileSystemEntity entity in langDir.list()) {
      if (entity is! Directory) {
        continue;
      }
      final String folder = entity.uri.pathSegments
          .where((String s) => s.isNotEmpty)
          .last;
      final File marker = File('${entity.path}/$_completeMarker');
      if (readyVersion == null &&
          await marker.exists() &&
          (await marker.readAsString()).trim() == folder &&
          SpeechModelRelease.safeVersion.hasMatch(folder) &&
          await _hasAllFiles(entity)) {
        readyVersion = folder;
        continue;
      }
      leftovers.add(entity);
    }
    if (_isDownloading(lang) && _activeClients.containsKey(lang)) {
      // Never delete the folder a running download is writing.
      return readyVersion;
    }
    for (final Directory leftover in leftovers) {
      await leftover.delete(recursive: true);
    }
    return readyVersion;
  }

  Future<SpeechModelRelease?> _fetchRelease(
    String lang, {
    HttpClient? client,
  }) async {
    final HttpClient http = client ?? _newClient();
    try {
      final HttpClientRequest request = await http.getUrl(
        Uri.parse('$_baseUrl/$kSpeechModelManifest'),
      );
      final HttpClientResponse response = await request.close().timeout(
        idleTimeout,
      );
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        throw HttpException('manifest HTTP ${response.statusCode}');
      }
      final List<int> bytes = <int>[];
      await for (final List<int> chunk in response.timeout(idleTimeout)) {
        bytes.addAll(chunk);
        if (bytes.length > _maxManifestBytes) {
          throw const FormatException('manifest too large');
        }
      }
      return SpeechModelRelease.fromManifest(utf8.decode(bytes), lang);
    } finally {
      if (client == null) {
        http.close(force: true);
      }
    }
  }

  Future<void> _downloadFile(
    HttpClient client,
    String lang,
    String version,
    SpeechModelFile file,
    Directory target,
    void Function(int chunk) onChunk,
  ) async {
    final File part = File('${target.path}/${file.name}.part');
    final HttpClientRequest request = await client.getUrl(
      Uri.parse('$_baseUrl/$lang/$version/${file.name}'),
    );
    final HttpClientResponse response = await request.close().timeout(
      idleTimeout,
    );
    if (response.statusCode != HttpStatus.ok) {
      await response.drain<void>();
      throw HttpException('${file.name} HTTP ${response.statusCode}');
    }
    final IOSink sink = part.openWrite();
    final _DigestSink digestSink = _DigestSink();
    final ByteConversionSink hasher = sha256.startChunkedConversion(digestSink);
    int written = 0;
    try {
      await for (final List<int> chunk in response.timeout(idleTimeout)) {
        written += chunk.length;
        if (written > file.size) {
          throw FormatException('${file.name}: more than ${file.size} bytes');
        }
        sink.add(chunk);
        hasher.add(chunk);
        onChunk(chunk.length);
      }
    } finally {
      await sink.close();
    }
    hasher.close();
    if (written != file.size) {
      throw FormatException('${file.name}: size $written != ${file.size}');
    }
    if (digestSink.value.toString() != file.sha256) {
      throw FormatException('${file.name}: sha256 mismatch');
    }
    await part.rename('${target.path}/${file.name}');
  }

  Future<bool> _hasAllFiles(Directory dir) async {
    for (final String name in kSpeechModelFiles) {
      final File file = File('${dir.path}/$name');
      if (!await file.exists() || await file.length() == 0) {
        return false;
      }
    }
    return true;
  }

  Future<void> _deleteLang(String lang) async {
    final Directory dir = await _langDir(lang);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<Directory> _rootDir() async =>
      Directory('${(await _baseDirectoryProvider()).path}/asr');

  Future<Directory> _langDir(String lang) async =>
      Directory('${(await _rootDir()).path}/$lang');

  Future<Directory> _versionDir(String lang, String version) async =>
      Directory('${(await _langDir(lang)).path}/$version');

  void _setState(String lang, SpeechModelState state) {
    _states[lang] = state;
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final HttpClient client in _activeClients.values) {
      client.close(force: true);
    }
    super.dispose();
  }
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
