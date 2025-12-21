class AppDateUtils {
  static String formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }

  static String formatDateShort(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  static String weekday(DateTime date) {
    const weekdays = ["S", "M", "T", "W", "T", "F", "S"];
    return weekdays[date.weekday % 7];
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static List<DateTime> getDatesBetween(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      dates.add(DateTime(start.year, start.month, start.day + i));
    }
    return dates;
  }

  static DateTime combine(DateTime date, String time) {
    final parts = time.split(' ');
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final minute = int.parse(hm[1]);
    final isPM = parts.length > 1 && parts[1].toLowerCase() == 'pm';

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

