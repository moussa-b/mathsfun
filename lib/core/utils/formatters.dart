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
