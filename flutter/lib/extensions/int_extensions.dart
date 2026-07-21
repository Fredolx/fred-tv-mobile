extension IntExtensions on int {
  DateTime get _asDateTime => DateTime.fromMillisecondsSinceEpoch(this);

  String toTimeAgo() {
    final seconds = DateTime.now().difference(_asDateTime).inSeconds;
    if (seconds < 29) return 'Just now';

    final interval = _formatInterval(seconds, _timeAgoIntervals);
    return interval != null ? '$interval ago' : toString();
  }

  String toTimeUntil() {
    final targetDate = _asDateTime;
    final seconds = targetDate.difference(DateTime.now()).inSeconds;
    final formattedDate = _formatExactDate(targetDate);

    if (seconds < 0) return 'Expired ($formattedDate)';

    final interval = _formatInterval(seconds, _timeUntilIntervals);
    final relativeText = interval != null
        ? 'In $interval'
        : 'In less than an hour';

    return '$relativeText ($formattedDate)';
  }

  static const _timeAgoIntervals = <String, int>{
    'day': 86400,
    'hour': 3600,
    'minute': 60,
    'second': 1,
  };

  static const _timeUntilIntervals = <String, int>{
    'year': 31536000,
    'month': 2592000,
    'week': 604800,
    'day': 86400,
    'hour': 3600,
  };

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String? _formatInterval(int seconds, Map<String, int> intervals) {
    for (final entry in intervals.entries) {
      final counter = seconds ~/ entry.value;
      if (counter > 0) {
        return '$counter ${entry.key}${counter == 1 ? '' : 's'}';
      }
    }
    return null;
  }

  static String _formatExactDate(DateTime date) {
    final month = _months[date.month - 1];
    final day = date.day;
    return '$month $day${_getOrdinalSuffix(day)} ${date.year}';
  }

  static String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    return switch (day % 10) {
      1 => 'st',
      2 => 'nd',
      3 => 'rd',
      _ => 'th',
    };
  }
}
