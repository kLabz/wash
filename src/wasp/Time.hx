package wasp;

import wash.util.DateTimeTuple;
import wash.util.Math.opFloorDiv;
import wasp.Builtins;

using python.NativeStringTools;

@:pythonImport("time")
extern class Time {
	static function clock():Float;
	static function sleep(t:Float):Void;
	static function mktime(s:DateTimeTuple):Float;
	static function localtime(time:Float):DateTimeTuple;

	inline static function printHour(time:DateTimeTuple):String
		return '{:02d}:{:02d}'.format(time.HH, time.MM);

	inline static function printDuration(duration:Float):String
		return TimeUtils.printDuration(duration);

	inline static function weekNb(year:Int, month:Int, day:Int):Int
		return TimeUtils.isoWeekNumber(year, month, day);

	inline static function time():Float
		return TimeUtils.time();
}

@:publicFields
class TimeUtils {
	static var DAYS_IN_MONTH = [null, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
	static var DAYS_BEFORE_MONTH = [null];

	static function time():Float {
		var now = Watch.rtc.get_localtime();
		return Time.mktime(DateTimeTuple.make(now.yyyy, now.mm, now.dd, now.HH, now.MM, now.SS, 0, 0));
	}

	static function printDuration(duration:Float):String {
		var days = duration >= 60*60*24 ? opFloorDiv(duration, 60*60*24) : 0;
		var duration = duration - days;
		var hours = opFloorDiv(duration, 60*60);
		duration -= hours;
		var minutes = opFloorDiv(duration, 60);
		var seconds = Builtins.int(duration - minutes * 60);

		if (days > 0)
			return '{}d {:02}:{:02}:{:02}'.format(days, hours, minutes, seconds);

		return '{:02}:{:02}:{:02}'.format(hours, minutes, seconds);
	}

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
		var week = Builtins.divmod(today - week1monday, 7)._1;
		if (week < 0) {
			year--;
			week1monday = isoWeek1Monday(year);
			week = Builtins.divmod(today - week1monday, 7)._1;
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
