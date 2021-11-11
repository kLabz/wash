package wash.app.watchface;

import wash.event.EventMask;
import wash.event.TouchEvent;
import python.Bytes;
import python.Syntax;
import python.Syntax.bytes;

import wash.Wash;
import wash.app.user.HeartApp;
import wash.app.system.Settings;
import wash.app.watchface.settings.WatchfaceConfig;
import wash.icon.PlugIcon;
import wash.icon.BleStatusIcon;
import wasp.Builtins;
import wasp.Fonts;
import wasp.Time;
import wasp.Watch;
import wasp.driver.Draw565.Fill.fill;

using python.NativeStringTools;

class BatTri extends BaseWatchFace {
	static var days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];

	var heartIcon:Bytes;
	var stepsIcon:Bytes;
	var plugIcon:Bytes;
	var bleIcon:Bytes;

	var doubleTap:Int = 0;
	var battery:Int = -1;
	var bluetooth:Bool = false;
	var plug:Bool = false;
	var dd:Int = -1;
	var hh:Int = -1;
	var mm:Int = -1;
	var ss:Int = -1;
	var st:Int = -2;
	var hr:Int = -2;

	public function new() {
		super();
		NAME = "BatTri";
		// TODO: ICON

		// Watchfaces start at 0xA1, but this probably won't be one of the default ones
		// 0xA0 is reserved for BaseWatchface for application settings
		ID = 0xAA;

		heartIcon = bytes(
			'\\x02',
			'\\x12\\x0f',
			'\\x02\\xc5\\x04\\xc5\\x03\\xc7\\x02\\xc7\\x01\\xd8\\x02\\xd0\\x02\\xd0\\x02\\xc3',
			'\\x01\\xcc\\x03\\xc2\\x02\\xc5\\x01\\xc4\\x02\\xc1\\x01\\xc1\\x03\\xc4\\x07\\xc2',
			'\\x01\\xc1\\x01\\xc1\\t\\xc5\\x03\\xc4\\x07\\xc4\\x03\\xc3\\t\\xc4\\x02\\xc2',
			'\\x0b\\xc3\\x01\\xc2\\r\\xc4\\x0f\\xc2\\x08'
		);

		stepsIcon = bytes(
			'\\x02',
			'\\x16\\x12',
			'\\x0c\\xc5\\x0b\\xc2\\x01\\xcb\\x07\\xc3\\x01\\xcc\\x06\\xc3\\x01\\xcd\\x05\\xc3',
			'\\x01\\xcd\\x06\\xc2\\x01\\xcd\\x0c\\xca\\x0e\\xc69\\xc3\\x10\\xc9\\x0b\\xcc',
			'\\x04\\xc3\\x01\\xce\\x04\\xc3\\x01\\xce\\x04\\xc3\\x01\\xcd\\x06\\xc2\\x01\\xcc',
			'\\x0c\\xc9\\x07'
		);

		plugIcon = PlugIcon.getIcon();
		bleIcon = BleStatusIcon.getIcon();
	}

	override function foreground():Void {
		draw(true);
		Wash.system.requestTick(1000);
		Wash.system.requestEvent(EventMask.TOUCH);
	}

	override function registered(quickRing:Bool):Void {
		Settings.registerApp(
			"Watchface",
			WatchfaceConfig,
			0xA0,
			WatchfaceConfig.serialize,
			WatchfaceConfig.deserialize
		);
	}

	override function unregistered():Void {
		Settings.unregisterApp(NAME);
	}

	override function sleep():Bool return true;
	override function wake():Void draw();
	override function tick(_):Void draw();

	override public function touch(event:TouchEvent):Void {
		switch (event.type) {
			case TOUCH if (BaseWatchFace.dblTapToSleep):
				var now = Watch.rtc.get_uptime_ms();
				var delta = now - doubleTap;

				if (delta < Manager.DOUBLE_TAP_MS) {
					doubleTap = 0;
					Wash.system.sleep();
				} else {
					doubleTap = now;
				}

			case _:
		}
	}

	override function preview():Void {
		Wash.system.bar.displayClock = false;
		draw(true);
	}

	function draw(redraw:Bool = false):Void {
		var draw = Watch.drawable;
		var hi = Wash.system.theme.highlight;
		var mid = Wash.system.theme.secondary;
		var ui = Wash.system.theme.primary;

		var now = Watch.rtc.get_localtime();
		var batteryLevel = Watch.battery.level();
		var battery = Builtins.int(batteryLevel / 100 * 240);
		var hr = try HeartApp.getRate() catch (_) -1;

		var plug = try Watch.battery.charging() catch (_) false;
		var bluetooth = try Watch.connected() catch (_) false;
		var st = try Watch.accel.steps catch (_) -1;

		if (redraw) {
			draw.fill(0);

			// Prepare heart rate / steps
			draw.blit(heartIcon, 4, 219, mid);
			draw.blit(stepsIcon, 217, 218, ui);

			// Prepare clock
			draw.set_color(mid);
			draw.set_font(Fonts.sans36);
			draw.string(':', 85, 91, 18);

			// Reset cached values to force redraw
			battery = -1;
			bluetooth = false;
			plug = false;
			dd = -1;
			hh = -1;
			mm = -1;
			ss = -1;
			st = -2;
			hr = -2;
		}

		// Redraw battery triangles if battery level changed
		if (this.battery != battery) {
			var display = draw._display;

			// Top "half" -- part with date
			display.set_window(210, 0, 30, 26);
			display.quick_start();
			for (i in 0...26) {
				var buf = display.linebuffer;
				var bgLen = opFloorDiv(i*240, 214);
				var bgPos = 30 - bgLen;
				var barLen = opFloorDiv(i*battery, 214);
				fill(buf, 0, bgPos, 0);
				fill(buf, mid, barLen, bgPos);
				fill(buf, ui, bgLen - barLen, bgPos + barLen);
				display.quick_write(Syntax.sub(buf,0,30*2));
			}
			display.quick_end();

			// Top "half" -- rest
			display.set_window(140, 26, 100, 82 - 26);
			display.quick_start();
			for (i in 0...(82-26)) {
				var buf = display.linebuffer;
				var bgLen = opFloorDiv((i+26)*240, 214);
				var bgPos = 100 - bgLen;
				var barLen = opFloorDiv((i+26)*battery, 214);
				fill(buf, 0, bgPos, 0);
				fill(buf, mid, barLen, bgPos);
				fill(buf, ui, bgLen - barLen, bgPos + barLen);
				display.quick_write(Syntax.sub(buf,0,100*2));
			}
			display.quick_end();

			// Bottom "half"
			display.set_window(0, 136, 240, 214 - 136);
			display.quick_start();
			for (i in 0...(214-136)) {
				var buf = display.linebuffer;
				var bgLen = opFloorDiv((i+136)*240, 214);
				var bgPos = 240 - bgLen;
				var barLen = opFloorDiv((i+136)*battery, 214);
				fill(buf, 0, bgPos, 0);
				fill(buf, mid, barLen, bgPos);
				fill(buf, ui, bgLen - barLen, bgPos + barLen);
				display.quick_write(Syntax.sub(buf,0,240*2));
			}
			display.quick_end();

			if (BaseWatchFace.displayBatteryPct && battery < 192) {
				draw.set_color(mid, ui);
				draw.set_font(Fonts.sans18);
				draw.string('{}%'.format(batteryLevel), 194, 196, 44, true);
			}
		}

		// Redraw date if date changed
		if (dd != now.dd) {
			draw.fill(0, 6, 6, 204, 20);

			draw.set_color(hi);
			draw.set_font(Fonts.sans24);
			var day = days[now.wday];
			draw.string(day, 6, 6);
			draw.set_color(mid);
			draw.string('{}'.format(now.dd), 10 + draw.bounding_box(day).x, 6);

			if (BaseWatchFace.displayWeekNb) {
				draw.set_font(Fonts.sans18);

				var x = 6;
				draw.set_color(hi);
				draw.string("WEEK", x, 28);
				x += draw.bounding_box("WEEK").x + 2;
				var week = '{}'.format(Time.weekNb(now.yyyy, now.mm, now.dd));
				draw.set_color(mid);
				draw.string(week, x, 28);
				x += draw.bounding_box(week).x + 8;
			}
		}

		if (hh != now.HH) {
			draw.set_color(hi);
			draw.set_font(Fonts.sans36);

			if (BaseWatchFace.hours12) {
				var h = now.HH;
				if (h > 12) h -= 12;
				else if (h == 0) h = 12;

				draw.string('{}'.format(h), 18, 91, 68, true);

				draw.set_color(mid);
				draw.set_font(Fonts.sans18);
				draw.string(now.HH >= 12 ? 'PM' : 'AM', 84, 73, 22);
			} else {
				draw.string('{:02}'.format(now.HH), 18, 91, 68, true);
			}
		}

		if (mm != now.MM) {
			draw.set_color(hi);
			draw.set_font(Fonts.sans36);
			draw.string('{:02}'.format(now.MM), 98, 91, 72);
		}

		if (ss != now.SS) {
			draw.set_color(mid);
			draw.set_font(Fonts.sans28);
			draw.string('{:02}'.format(now.SS), 167, 99, 56);
		}

		if (this.hr != hr) {
			draw.set_color(mid);
			draw.set_font(Fonts.sans18);
			draw.fill(0, 25, 219, 40, 20);
			if (hr < 0) draw.string('-', 25, 219);
			else draw.string('{}'.format(hr), 25, 219);
		}

		if (this.st != st) {
			draw.set_color(ui);
			draw.set_font(Fonts.sans18);
			if (st < 0) draw.string('-', 133, 219, 80, true);
			else draw.string('{}'.format(st), 133, 219, 80, true);
		}

		if (this.plug != plug) {
			var y = BaseWatchFace.displayWeekNb ? 46 : 28;
			if (plug) draw.blit(plugIcon, 6, y, mid, 0, true);
			// Clear bluetooth icon too if any
			else draw.fill(0, 6, y, 32, 18);
		}

		if (this.plug != plug || this.bluetooth != bluetooth) {
			var y = BaseWatchFace.displayWeekNb ? 46 : 28;
			if (bluetooth) draw.blit(bleIcon, plug ? 28 : 6, y, mid, 0, true);
			else draw.fill(0, plug ? 28 : 6, y, 10, 18);
		}

		// Update references
		this.battery = battery;
		this.bluetooth = bluetooth;
		this.plug = plug;
		dd = now.dd;
		hh = now.HH;
		mm = now.MM;
		ss = now.SS;
		this.hr = hr;
		this.st = st;
	}
}
