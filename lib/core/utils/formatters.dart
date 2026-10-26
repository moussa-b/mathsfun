import 'package:intl/intl.dart';

String formatDuration(Duration duration) {
  final int minutes = duration.inMinutes;
  final int seconds = duration.inSeconds.remainder(60);
  if (minutes <= 0) {
    return '${seconds}s';
  }
  return '${minutes}m ${seconds}s';
}

String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('dd MMM yyyy • HH:mm');
  return formatter.format(dateTime);
}

/// "71 Mo" in French, "71 MB" otherwise.
String formatMegabytes(int bytes, String languageCode) {
  final int megabytes = (bytes / 1000000).round();
  return languageCode == 'fr' ? '$megabytes Mo' : '$megabytes MB';
}

/// Seconds with one decimal, using the locale's decimal separator ("3,2").
String formatSecondsOneDecimal(int milliseconds, String languageCode) {
  final NumberFormat formatter = NumberFormat('0.0', languageCode);
  return formatter.format(milliseconds / 1000);
}
