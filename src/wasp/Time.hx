package wasp;

import wash.util.TimeTuple;
import wash.util.Math.opFloorDiv;
import wasp.Builtins.divmod;

@:pythonImport("time")
extern class Time {
	static function time():Float;
	static function clock():Float;
	static function sleep(t:Float):Void;
	static function mktime(s:TimeTuple):Float;
	static function localtime(time:Float):TimeTuple;

	inline static function weekNb(year:Int, month:Int, day:Int):Int
		return TimeUtils.isoWeekNumber(year, month, day);
}

@:publicFields
class TimeUtils {
	static var DAYS_IN_MONTH = [null, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	static var DAYS_BEFORE_MONTH = [null];

	static function isoWeek1Monday(year:Int):Int {
		var firstday = ymd2ord(year, 1, 1);
		var firstweekday = (firstday + 6) % 7;
		var week1monday = firstday - firstweekday;
		if (firstweekday > 3) week1monday += 7;
		return week1monday;
	}

	static function isoWeekNumber(year:Int, month:Int, day:Int):Int {
		var week1monday = isoWeek1Monday(year);
		var today = ymd2ord(year, month, day);
		var week = divmod(today - week1monday, 7)._1;
		if (week < 0) {
			year--;
			week1monday = isoWeek1Monday(year);
			week = divmod(today - week1monday, 7)._1;
		} else if (week >= 52) {
			if (today >= isoWeek1Monday(year + 1)) {
				year += 1;
				week = 0;
			}
		}

		return week + 1;
	}

	static function ymd2ord(year:Int, month:Int, day:Int):Int {
		return daysBeforeYear(year) + daysBeforeMonth(year, month) + day;
	}

	static function daysInMonth(year:Int, month:Int):Int {
		if (month == 2 && isLeap(year)) return 29;
		return DAYS_IN_MONTH[month];
	}

	static function isLeap(year:Int):Bool {
		return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
	}

	static function daysBeforeYear(year:Int):Int {
		var y = year - 1;
		return y * 365 + opFloorDiv(y, 4) - opFloorDiv(y, 100) + opFloorDiv(y, 400);
	}

	static function prepareDaysBeforeMonth():Void {
		if (DAYS_BEFORE_MONTH.length > 1) return;

		var acc = 0;
		for (dim in DAYS_IN_MONTH) {
			if (dim == null) continue;
			DAYS_BEFORE_MONTH.push(acc);
			acc += dim;
		}
	}

	static function daysBeforeMonth(year:Int, month:Int):Int {
		prepareDaysBeforeMonth();
		return DAYS_BEFORE_MONTH[month] + (month > 2 && isLeap(year) ? 1 : 0);
	}
}
