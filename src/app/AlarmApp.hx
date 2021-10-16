package app;

import python.Bytearray;
import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.delete;
import python.Tuple;

import wasp.EventMask;
import wasp.Fonts;
import wasp.Wasp;
import wasp.Watch;
import wasp.app.BaseApplication;
import wasp.event.TouchEvent;
import wasp.util.Builtins;
import wasp.util.Time;
import wasp.util.TimeTuple;
import wasp.widgets.Button;
import wasp.widgets.Checkbox;
import wasp.widgets.Spinner;

import app.alarm.DayButtons;

using python.NativeStringTools;

enum abstract RepetitionFlag(Int) from Int to Int {
	var MONDAY = 0x01;
	var TUESDAY = 0x02;
	var WEDNESDAY = 0x04;
	var THURSDAY = 0x08;
	var FRIDAY = 0x10;
	var SATURDAY = 0x20;
	var SUNDAY = 0x40;
	var WEEKDAYS = 0x1F;
	var WEEKENDS = 0x20;
	var EVERYDAY = 0x7F;
	var IS_ACTIVE = 0x80;
}

enum abstract Page(Int) from Int to Int {
	var HOME_PAGE = -1;
	var RINGING_PAGE = -2;

	@:op(A > B) function gt(B:Int):Bool;
}

@:native('AlarmApp')
class AlarmApp extends BaseApplication {
	static var icon:Bytes = bytes(
		'\\x02',
		'`@',
		'\\x17@\\xd2G#G-K\\x1fK)O\\x1bO&O',
		"\\n\\x80\\xb4\\x89\\x0bN$N\\x08\\x91\\tM\"M\\x07\\x97",
		'\\x07M!L\\x06\\x9b\\x07K K\\x06\\x9f\\x06K\\x1fJ',
		'\\x05\\xa3\\x05J\\x1eJ\\x05\\x91\\xc0\\xd0\\xc3\\x91\\x05J\\x1dI',
		'\\x05\\x8c\\xcf\\x8c\\x05I\\x1dH\\x05\\x8b\\xd3\\x8b\\x05H\\x1dG',
		'\\x05\\x8a\\xd7\\x8a\\x05G\\x1dG\\x04\\x89\\xdb\\x89\\x05F\\x1dF',
		'\\x04\\x89\\xcc\\x05\\xcc\\x89\\x04F\\x1dE\\x04\\x89\\xcd\\x05\\xcd\\x89',
		'\\x04E\\x1eD\\x03\\x88\\xce\\x07\\xce\\x88\\x04C\\x1fC\\x04\\x88',
		'\\xce\\x07\\xce\\x88\\x04C\\x1fC\\x03\\x88\\xcf\\x07\\xcf\\x88\\x04A',
		'!A\\x04\\x87\\xd0\\x07\\xd0\\x87\\x04A%\\x87\\xd1\\x07\\xd1\\x87',
		')\\x87\\xd1\\x07\\xd1\\x87(\\x87\\xd2\\x07\\xd2\\x87\\\'\\x87\\xd2\\x07',
		'\\xd2\\x87\\\'\\x86\\xd3\\x07\\xd3\\x86&\\x87\\xd3\\x07\\xd3\\x87%\\x86',
		'\\xd4\\x07\\xd4\\x86%\\x86\\xd4\\x07\\xd4\\x86%\\x86\\xd4\\x07\\xd4\\x86',
		"$\\x87\\xd4\\x07\\xd4\\x87#\\x87\\xd4\\x07\\xd4\\x87#\\x87\\xd4\\x07",
		'\\xd4\\x87#\\x86\\xd4\\x08\\xd5\\x86#\\x86\\xd3\\t\\xd5\\x86#\\x86',
		'\\xd2\\t\\xd6\\x86#\\x87\\xd0\\n\\xd5\\x87#\\x87\\xcf\\n\\xd6\\x87',
		"#\\x87\\xce\\n\\xd7\\x87$\\x86\\xce\\t\\xd8\\x86%\\x86\\xce\\x08",
		'\\xd9\\x86%\\x86\\xcd\\x08\\xda\\x86%\\x87\\xcc\\x07\\xda\\x87%\\x87',
		'\\xcc\\x06\\xdb\\x86\\\'\\x87\\xcc\\x03\\xdc\\x87\\\'\\x87\\xeb\\x87(\\x87',
		'\\xe9\\x87)\\x87\\xe9\\x87*\\x87\\xe7\\x87+\\x88\\xe5\\x88,\\x87',
		'\\xe5\\x87-\\x88\\xe3\\x88.\\x88\\xe1\\x880\\x89\\xdd\\x892\\x89',
		'\\xdb\\x893\\x8b\\xd7\\x8b2\\x8d\\xd4\\x8e0\\x91\\xcf\\x91.\\x97',
		'\\xc5\\x97,\\xb5+\\x88\\x03\\x9f\\x03\\x88*\\x88\\x05\\x9d\\x05\\x88',
		')\\x87\\t\\x97\\t\\x87*\\x85\\x0c\\x93\\x0c\\x85,\\x83\\x11\\x8b',
		'\\x11\\x83\\x17'
	);

	var page:Page;
	var alarms:Array<AlarmDef>;
	var pendingAlarms:Array<Float>;
	var numAlarms:Int;

	var delAlarmButton:Button;
	var hoursSpinner:Spinner;
	var minutesSpinner:Spinner;
	var dayButtons:DayButtons;
	var alarmChecks:Tuple4<Checkbox, Checkbox, Checkbox, Checkbox>;

	public function new() {
		NAME = "Alarm";
		ICON = icon;

		page = HOME_PAGE;
		alarms = [
			AlarmDef.make(8, 0, WEEKDAYS),
			AlarmDef.make(8, 0, 0),
			AlarmDef.make(8, 0, 0),
			AlarmDef.make(8, 0, 0)
		];
		pendingAlarms = [0.0, 0.0, 0.0, 0.0];
		numAlarms = 1;
	}

	override public function foreground():Void {
		delAlarmButton = new Button(170, 204, 70, 35, "DEL");
		hoursSpinner = new Spinner(50, 30, 0, 24, 2);
		minutesSpinner = new Spinner(130, 30, 0, 59, 2);
		dayButtons = DayButtons.make();
		alarmChecks = Tuple4.make(
			new Checkbox(200, 57),
			new Checkbox(200, 102),
			new Checkbox(200, 147),
			new Checkbox(200, 192)
		);

		deactivatePendingAlarms();
		draw();

		Wasp.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_LEFTRIGHT | EventMask.BUTTON);
		Wasp.system.requestTick(1000);
	}

	override public function background():Void {
		if (page > HOME_PAGE) saveAlarm();

		page = HOME_PAGE;

		delAlarmButton = null;
		delete(delAlarmButton);
		hoursSpinner = null;
		delete(hoursSpinner);
		minutesSpinner = null;
		delete(minutesSpinner);
		alarmChecks = null;
		delete(alarmChecks);
		dayButtons = null;
		delete(dayButtons);

		setPendingAlarms();
	}

	override public function tick(ticks:Int):Void {
		if (page == RINGING_PAGE) {
			Watch.vibrator.pulse(50, 500);
			Wasp.system.keepAwake();
		} else {
			Wasp.system.bar.update();
		}
	}

	override public function press(_, state:Bool):Bool {
		if (page == RINGING_PAGE) snooze();
		Wasp.system.navigate(HOME);
		return false;
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (page) {
			case RINGING_PAGE: silenceAlarm();
			case i if (i > HOME_PAGE):
				saveAlarm();
				draw();
			case _:
				Wasp.system.navigate(event.type);
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		switch (page) {
			case RINGING_PAGE:
				silenceAlarm();

			case HOME_PAGE:
				// Avoid haxe iterator..
				for (i in 0...Builtins.len(alarmChecks)) {
					var checkbox = alarmChecks[i];
					if (i < numAlarms && checkbox.touch(event)) {
						if (checkbox.state) {
							alarms[i].mask |= IS_ACTIVE;
						} else {
							alarms[i].mask &= ~IS_ACTIVE;
						}

						draw(i);
						return;
					}
				}

				// Avoid haxe iterator..
				for (i in 0...Builtins.len(alarms)) {
					// Open edit page for clicked alarms
					if (
						i < numAlarms && event.x < 190
						&& 60 + (i*45) < event.y && event.y < 60 + ((i+1)*45)
					) {
						page = i;
						draw();
						return;


					// Add new alarm if plus clicked
					} else if (i == numAlarms && 60 + (i*45) < event.y) {
						numAlarms++;
						draw(i);
						return;
					}
				}

			case _:
				if (hoursSpinner.touch(event) || minutesSpinner.touch(event)) return;
				for (b in dayButtons) if (b.touch(event)) return;
				if (delAlarmButton.touch(event)) removeAlarm(page);
		}
	}

	function removeAlarm(index:Int):Void {
		// Shift alarm indices
		for (i in index...3) {
			alarms[i].HH = alarms[i+1].HH;
			alarms[i].MM = alarms[i+1].MM;
			alarms[i].mask = alarms[i+1].mask;
			pendingAlarms[i] = pendingAlarms[i+1];
		}

		// Set last alarm to default
		alarms[3].HH = 8;
		alarms[3].MM = 0;
		alarms[3].mask = 0;

		page = HOME_PAGE;
		numAlarms--;
		draw();
	}

	function saveAlarm():Void {
		var alarm = alarms[page];
		alarm.HH = hoursSpinner.value;
		alarm.MM = minutesSpinner.value;

		for (i => dayButton in dayButtons) {
			if (dayButton.state) alarm.mask = alarm.mask | (1 << i);
			else alarm.mask = alarm.mask & ~(1 << i);
		}

		page = HOME_PAGE;
	}

	function draw(?alarmRow:Int = -1):Void {
		switch (page) {
			case RINGING_PAGE: drawRingingPage();
			case HOME_PAGE: drawHomePage(alarmRow);
			case _: drawEditPage();
		}
	}

	function drawEditPage():Void {
		var draw = Watch.drawable;
		var alarm = alarms[page];

		draw.fill();
		drawSystemBar();

		hoursSpinner.value = alarm.HH;
		minutesSpinner.value = alarm.MM;
		draw.set_font(Fonts.sans28);
		draw.string(':', 110, 90-14, 20);

		delAlarmButton.draw();
		hoursSpinner.draw();
		minutesSpinner.draw();

		for (i => btn in dayButtons) {
			btn.state = alarm.mask & (1 << i) > 0;
			btn.draw();
		}
	}

	function drawHomePage(?alarmRow:Int = HOME_PAGE):Void {
		var draw = Watch.drawable;

		if (alarmRow == HOME_PAGE) {
			draw.set_color(Wasp.system.theme.bright);
			draw.fill();
			drawSystemBar();
			draw.line(0, 50, 239, 50, 1, Wasp.system.theme.bright);
		}

		// Avoid haxe iterator..
		for (i in 0...Builtins.len(alarms)) {
			if (i < numAlarms && (alarmRow == HOME_PAGE || alarmRow == i)) {
				drawAlarmRow(i);
			} else if (i == numAlarms) {
				// Draw the add button
				draw.set_color(Wasp.system.theme.bright);
				draw.set_font(Fonts.sans28);
				draw.string('+', 100, 60+(i*45));
			}
		}
	}

	function drawAlarmRow(index:Int):Void {
		var draw = Watch.drawable;
		var alarm = alarms[index];
		var alarmCheck:Checkbox = alarmChecks[index];

		alarmCheck.state = alarm.mask & IS_ACTIVE > 0;
		alarmCheck.draw();

		draw.set_color(alarmCheck.state ? Wasp.system.theme.bright : Wasp.system.theme.mid);

		draw.set_font(Fonts.sans28);
		draw.string('{:02d}:{:02d}'.format(alarm.HH, alarm.MM), 10, 60+index*45, 120);

		draw.set_font(Fonts.sans18);
		draw.string(getRepeatCode(alarm.mask), 130, 70+index*45, 60);

		draw.line(0, 95+index*45, 239, 95+index*45, 1, Wasp.system.theme.bright);
	}

	function drawRingingPage():Void {
		var draw = Watch.drawable;

		draw.set_color(Wasp.system.theme.bright);
		draw.fill();
		draw.set_font(Fonts.sans24);
		draw.string("Alarm", 0, 150, 240);
		draw.blit(icon, 73, 50, Wasp.system.theme.bright, Wasp.system.theme.mid, Wasp.system.theme.ui, true);
		draw.line(35, 1, 35, 239);
		draw.string('Z', 10, 80);
		draw.string('z', 10, 110);
		draw.string('z', 10, 140);
	}

	function drawSystemBar():Void {
		Wasp.system.bar.displayClock = true;
		Wasp.system.bar.draw();
	}

	function alert():Void {
		page = RINGING_PAGE;
		Wasp.system.wake();
		if (Wasp.system.isActive(this)) draw();
		else Wasp.system.switchApp(this);
	}

	function snooze():Void {
		var now = Watch.rtc.get_localtime();
		var alarm = TimeTuple.make(now.yyyy, now.mm, now.dd, now.HH, now.MM + 10, now.SS, 0, 0, 0);
		Wasp.system.setAlarm(Time.mktime(alarm), alert);
	}

	function silenceAlarm():Void {
		Watch.display.mute(true);
		draw();
		Watch.display.mute(false);
		Wasp.system.navigate(HOME);
	}

	function setPendingAlarms():Void {
		var now = Watch.rtc.get_localtime();

		// Avoid haxe iterator..
		for (index in 0...Builtins.len(alarms)) {
			var alarm = alarms[index];
			if (index < numAlarms && (alarm.mask & IS_ACTIVE) > 0) {
				var dd = now.dd;

				// If next alarm is tomorrow, increment the day
				if (alarm.HH < now.HH || (alarm.HH == now.HH && alarm.MM <= now.MM)) {
					dd++;
				}

				var pendingTime = Time.mktime(
					TimeTuple.make(now.yyyy, now.mm, dd, alarm.HH, alarm.MM, 0, 0, 0, 0)
				);

				// If this is not a one time alarm find the next day of the week
				// that is enabled
				if (alarm.mask & ~IS_ACTIVE != 0) {
					for (_ in 0...7) {
						if ((1 << Time.localtime(pendingTime).wday) & alarm.mask == 0) {
							dd++;
							pendingTime = Time.mktime(
								TimeTuple.make(now.yyyy, now.mm, dd, alarm.HH, alarm.MM, 0, 0, 0, 0)
							);
						} else {
							break;
						}
					}
				}

				pendingAlarms[index] = pendingTime;
				Wasp.system.setAlarm(pendingTime, alert);
			} else {
				pendingAlarms[index] = 0.0;
			}
		}
	}

	function deactivatePendingAlarms():Void {
		var now = Watch.rtc.get_localtime();
		var now = Time.mktime(TimeTuple.make(now.yyyy, now.mm, now.dd, now.HH, now.MM, now.SS, 0, 0, 0));

		// Avoid haxe iterator..
		for (i in 0...Builtins.len(alarms)) {
			var alarm = alarms[i];
			var pendingAlarm = pendingAlarms[i];
			if (pendingAlarm != 0.0) {
				Wasp.system.cancelAlarm(pendingAlarm, alert);

				// If this is a one time alarm and in the past, disable it
				if (alarm.mask & IS_ACTIVE == 0 && pendingAlarm <= now)
					alarm.mask = 0;
			}
		}
	}

	static function getRepeatCode(days):String {
		return switch (days & ~IS_ACTIVE) {
			case WEEKDAYS: "wkds";
			case WEEKENDS: "wkns";
			case EVERYDAY: "evry";
			case 0: "once";
			case _: "cust";
		};
	}
}

extern class AlarmDef extends Bytearray {
	static inline function make(HH:Int, MM:Int, mask:RepetitionFlag):AlarmDef
		return cast new Bytearray([HH, MM, mask]);

	var HH(get, set):Int;
	inline function get_HH():Int return this[0];
	inline function set_HH(v:Int):Int return this[0] = v;

	var MM(get, set):Int;
	inline function get_MM():Int return this[1];
	inline function set_MM(v:Int):Int return this[1] = v;

	var mask(get, set):RepetitionFlag;
	inline function get_mask():RepetitionFlag return this[2];
	inline function set_mask(v:RepetitionFlag):RepetitionFlag return this[2] = v;
}
