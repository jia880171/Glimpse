class TimeUtils {
  /// 取得當前年
  static int get currentYear => DateTime.now().year;

  /// 取得當前月
  static int get currentMonth => DateTime.now().month;

  /// 取得當前日
  static int get currentDay => DateTime.now().day;

  /// 取得當前時間（DateTime 物件）
  static DateTime get currentDateTime => DateTime.now();

  /// 取得當月天數
  static int get daysInCurrentMonth {
    final now = DateTime.now();
    final firstDayNextMonth = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 1)
        : DateTime(now.year + 1, 1, 1);
    return firstDayNextMonth.subtract(const Duration(days: 1)).day;
  }

  static int daysInTargetMonth(int targetYear, int targetMonth) {
    final firstDayOfNextMonth = (targetMonth < 12)
        ? DateTime(targetYear, targetMonth + 1, 1)
        : DateTime(targetYear + 1, 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }

  // 24-hour
  String get currentTimeHms {
    final String hh = _twoDigits(DateTime.now().hour);
    final String mm = _twoDigits(DateTime.now().minute);
    final String ss = _twoDigits(DateTime.now().second);
    return "$hh:$mm:$ss";
  }

  String _twoDigits(int v) {
    if (v >= 10) {
      return "$v";
    } else {
      return "0$v";
    }
  }

  static String weekdayLabel(int year, int month, int day) {
    final dt = DateTime(year, month, day);
    const jpWeek = ['月', '火', '水', '木', '金', '土', '日'];
    return jpWeek[dt.weekday - 1];
  }
}
