package wash.app.user;

import python.Bytearray;
import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.delete;
import python.Tuple;

import wash.Wash;
import wash.app.user.alarm.DayButtons;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.util.DateTimeTuple;
import wash.widgets.Button;
import wash.widgets.Checkbox;
import wash.widgets.Spinner;
import wasp.Fonts;
import wasp.Watch;
import wasp.Builtins;
import wasp.Time;

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
		'@@',
		'?\\xff\\xffQ\\xc5\\x08\\x8a\\x08\\xc5\\x1a\\xc7\\x05\\x90\\x05\\xc7\\x17',
		'\\xc7\\x04\\x94\\x04\\xc7\\x16\\xc6\\x03\\x87\\n\\x87\\x03\\xc6\\x15\\xc6\\x03',
		'\\x85\\x10\\x85\\x03\\xc6\\x14\\xc5\\x03\\x84\\t@\\xacB\\t\\x84\\x03',
		'\\xc5\\x14\\xc4\\x03\\x83\\x0bB\\x0b\\x83\\x03\\xc4\\x14\\xc3\\x03\\x83\\x1a',
		'\\x83\\x03\\xc3\\x14\\xc2\\x03\\x83\\x1c\\x83\\x03\\xc2\\x18\\x83\\x0e\\xc2\\x0e',
		'\\x83\\x1b\\x83\\x0f\\xc2\\x0f\\x83\\x1a\\x83\\x0f\\xc2\\x0f\\x83\\x19\\x83\\x10',
		'\\xc2\\x10\\x83\\x18\\x83\\x10\\xc2\\x10\\x83\\x17\\x83\\x11\\xc2\\x11\\x83\\x16',
		'\\x83\\x11\\xc2\\x11\\x83\\x16\\x83\\x11\\xc2\\x11\\x83\\x15\\x83\\x12\\xc2\\x12',
		'\\x83\\x14\\x83\\x12\\xc2\\x12\\x83\\x14\\x83\\x12\\xc2\\x12\\x83\\x14\\x83\\x02',
		'B\\x06\\xca\\x0eB\\x02\\x83\\x14\\x83\\x02B\\x06\\xca\\x0eB\\x02',
		'\\x83\\x14\\x83&\\x83\\x14\\x83&\\x83\\x14\\x83&\\x83\\x14\\x83&',
		'\\x83\\x15\\x83$\\x83\\x16\\x83$\\x83\\x16\\x83$\\x83\\x17\\x83"',
		'\\x83\\x18\\x83"\\x83\\x19\\x83 \\x83\\x1a\\x83 \\x83\\x1b\\x83\\x1e',
		'\\x83\\x1d\\x83\\x1c\\x83\\x1f\\x83\\x1a\\x83!\\x83\\x0b\\xc2\\x0b\\x83#',
		'\\x84\\t\\xc2\\t\\x84%\\x85\\x10\\x85&A\\x87\\n\\x87A%',
		'D\\x94D#D\\x03\\x90\\x03D!D\\x07\\x8a\\x07D\\x1f',
		'D\\x1aD\\x1dD\\x1cD?\\xff\\xff\\x11'
	);

	static var instance:AlarmApp;
	static var alarms:Array<AlarmDef>;
	static var pendingAlarms:Array<Float>;
	static var numAlarms:Int;

	var page:Page;
	var delAlarmButton:Button;
	var hoursSpinner:Spinner;
	var minutesSpinner:Spinner;
	var dayButtons:DayButtons;
	var alarmChecks:Tuple4<Checkbox, Checkbox, Checkbox, Checkbox>;

	public static function init(?alarms:Array<AlarmDef>):Void {
		AlarmApp.alarms = alarms != null ? alarms : [
			AlarmDef.make(8, 0, WEEKDAYS),
			AlarmDef.make(8, 0, 0),
			AlarmDef.make(8, 0, 0),
			AlarmDef.make(8, 0, 0)
		];

		pendingAlarms = [0.0, 0.0, 0.0, 0.0];
		numAlarms = 0;
		for (a in AlarmApp.alarms) if ((a.mask:Int) > 0) numAlarms++;
		setPendingAlarms();
	}

	public function new() {
		super();
		NAME = "Alarm";
		ICON = icon;
		ID = 0x01;

		page = HOME_PAGE;
		instance = this;
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

		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_LEFTRIGHT | EventMask.BUTTON);
		Wash.system.requestTick(1000);
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
			Wash.system.keepAwake();
		} else {
			Wash.system.bar.update();
		}
	}

	override public function press(_, state:Bool):Bool {
		if (page == RINGING_PAGE) snooze();
		Wash.system.navigate(HOME);
		return false;
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (page) {
			case RINGING_PAGE: silenceAlarm();
			case i if (i > HOME_PAGE):
				saveAlarm();
				draw();
			case _:
				Wash.system.navigate(event.type);
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

		draw.fill(0);
		drawSystemBar();

		hoursSpinner.value = alarm.HH;
		minutesSpinner.value = alarm.MM;
		draw.set_color(Wash.system.theme.highlight);
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
			draw.set_color(Wash.system.theme.highlight);
			draw.fill();
			drawSystemBar();
			draw.line(0, 50, 239, 50, 1, Wash.system.theme.highlight);
		}

		// Avoid haxe iterator..
		for (i in 0...Builtins.len(alarms)) {
			if (i < numAlarms && (alarmRow == HOME_PAGE || alarmRow == i)) {
				drawAlarmRow(i);
			} else if (i == numAlarms) {
				// Draw the add button
				draw.set_color(Wash.system.theme.highlight);
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

		draw.set_color(alarmCheck.state ? Wash.system.theme.highlight : Wash.system.theme.secondary);

		draw.set_font(Fonts.sans28);
		draw.string(alarm.formatHour(), 10, 60+index*45, 120);

		draw.set_font(Fonts.sans18);
		draw.string(getRepeatCode(alarm.mask), 130, 70+index*45, 60);

		draw.line(0, 95+index*45, 239, 95+index*45, 1, Wash.system.theme.highlight);
	}

	function drawRingingPage():Void {
		var draw = Watch.drawable;

		draw.set_color(Wash.system.theme.highlight);
		draw.fill();
		draw.set_font(Fonts.sans24);
		draw.string("Alarm", 0, 150, 240);
		draw.blit(icon, 73, 50, Wash.system.theme.highlight, Wash.system.theme.secondary, Wash.system.theme.primary, true);
		draw.line(35, 1, 35, 239);
		draw.string('Z', 10, 80);
		draw.string('z', 10, 110);
		draw.string('z', 10, 140);
	}

	function drawSystemBar():Void {
		Wash.system.bar.displayClock = true;
		Wash.system.bar.draw();
	}

	function alert():Void {
		page = RINGING_PAGE;
		Wash.system.wake();
		if (Wash.system.isActive(this)) draw();
		else Wash.system.switchApp(this);
	}

	function snooze():Void {
		var now = Watch.rtc.get_localtime();
		var alarm = DateTimeTuple.make(now.yyyy, now.mm, now.dd, now.HH, now.MM + 10, now.SS, 0, 0);
		Wash.system.setAlarm(Time.mktime(alarm), alert);
	}

	function silenceAlarm():Void {
		Watch.display.mute(true);
		draw();
		Watch.display.mute(false);
		Wash.system.navigate(HOME);
	}

	static function setPendingAlarms():Void {
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
					DateTimeTuple.make(now.yyyy, now.mm, dd, alarm.HH, alarm.MM, 0, 0, 0)
				);

				// If this is not a one time alarm find the next day of the week
				// that is enabled
				if (alarm.mask & ~IS_ACTIVE != 0) {
					for (_ in 0...7) {
						if ((1 << Time.localtime(pendingTime).wday) & alarm.mask == 0) {
							dd++;
							pendingTime = Time.mktime(
								DateTimeTuple.make(now.yyyy, now.mm, dd, alarm.HH, alarm.MM, 0, 0, 0)
							);
						} else {
							break;
						}
					}
				}

				pendingAlarms[index] = pendingTime;
				Wash.system.setAlarm(pendingTime, instance.alert);
			} else {
				pendingAlarms[index] = 0.0;
			}
		}
	}

	function deactivatePendingAlarms():Void {
		var now = Time.time();

		// Avoid haxe iterator..
		for (i in 0...Builtins.len(alarms)) {
			var alarm = alarms[i];
			var pendingAlarm = pendingAlarms[i];
			if (pendingAlarm != 0.0) {
				Wash.system.cancelAlarm(pendingAlarm, alert);

				// If this is a one time alarm and in the past, disable it
				if (alarm.mask & IS_ACTIVE == 0 && pendingAlarm <= now)
					alarm.mask = 0;
			}
		}
	}

	public static function getInstance():AlarmApp {
		if (instance == null) new AlarmApp();
		return instance;
	}

	public static function nextAlarm():Null<Float> {
		var next = 0.0;

		// Avoid haxe iterator..
		for (i in 0...Builtins.len(pendingAlarms)) {
			var val = pendingAlarms[i];
			if (val == 0) continue;
			if (next == 0 || next > val) next = val;
		}

		if (next == 0) return null;
		return next;
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

	inline function formatHour():String return '{:02d}:{:02d}'.format(this.HH, this.MM);
}
