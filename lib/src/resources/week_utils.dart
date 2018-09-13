import 'package:intl/intl.dart';

class Week {
  final DateTime date;
  final int dayOfWeek;
  final int year;
  final int week;

  Week({this.date,this.dayOfWeek, this.week, this.year});

  int getWeekOfYear() {
    final weekYearStartDate = _getWeekYearStartDateForDate(date);

    final dayDiff = date
        .difference(weekYearStartDate)
        .inDays;

    return ((dayDiff + 1) / 7).ceil();
  }

  DateTime _getWeekYearStartDateForDate(DateTime date) {
    int weekYear = _getWeekYear(date);
    return _getWeekYearStartDate(weekYear);
  }

  int getWeekYear() {
    return _getWeekYear(date);
  }

  DateTime getDayFromWeek () {

    DateTime day = _getWeekYearStartDate(year);
    day = _addDays(day, (week -1) * 7);
    day = _addDays(day, dayOfWeek - 1);
    return day;

  }

  int _getWeekYear(DateTime date) {
  //  assert(date.isUtc);

    final weekYearStartDate = _getWeekYearStartDate(date.year);

    // in previous week year?
    if (weekYearStartDate.isAfter(date)) {
      return date.year - 1;
    }

    // in next week year?
    final nextWeekYearStartDate = _getWeekYearStartDate(date.year + 1);
    if (!nextWeekYearStartDate.isAfter(date)) {
      return date.year + 1;
    }

    return date.year;
  }

  DateTime _getWeekYearStartDate(int year) {
    final firstDayOfYear = DateTime.utc(year, 1, 1);
    final dayOfWeek = firstDayOfYear.weekday;

    if (dayOfWeek <= DateTime.thursday) {
      return _addDays(firstDayOfYear, 1 - dayOfWeek);
    }
    else {
      return _addDays(firstDayOfYear, 8 - dayOfWeek);
    }
  }

  DateTime _addDays(DateTime date, int days) {
    return date.add(new Duration(days: days));
  }
}
