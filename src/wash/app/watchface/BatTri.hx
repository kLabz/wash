package wash.app.watchface;

import python.Bytes;
import python.Syntax;
import python.Syntax.bytes;

import wash.Wash;
import wasp.Watch;
import wasp.Fonts;
import wasp.driver.Draw565.Fill.fill;

using python.NativeStringTools;

class BatTri extends BaseWatchFace {
	static var days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];

	static var heartIcon:Bytes = bytes(
		'\\x02',
		'\\x12\\x0f',
		'\\x02\\xc5\\x04\\xc5\\x03\\xc7\\x02\\xc7\\x01\\xd8\\x02\\xd0\\x02\\xd0\\x02\\xc3',
		'\\x01\\xcc\\x03\\xc2\\x02\\xc5\\x01\\xc4\\x02\\xc1\\x01\\xc1\\x03\\xc4\\x07\\xc2',
		'\\x01\\xc1\\x01\\xc1\\t\\xc5\\x03\\xc4\\x07\\xc4\\x03\\xc3\\t\\xc4\\x02\\xc2',
		'\\x0b\\xc3\\x01\\xc2\\r\\xc4\\x0f\\xc2\\x08'
	);

	static var stepsIcon:Bytes = bytes(
		'\\x02',
		'\\x16\\x12',
		'\\x0c\\xc5\\x0b\\xc2\\x01\\xcb\\x07\\xc3\\x01\\xcc\\x06\\xc3\\x01\\xcd\\x05\\xc3',
		'\\x01\\xcd\\x06\\xc2\\x01\\xcd\\x0c\\xca\\x0e\\xc69\\xc3\\x10\\xc9\\x0b\\xcc',
		'\\x04\\xc3\\x01\\xce\\x04\\xc3\\x01\\xce\\x04\\xc3\\x01\\xcd\\x06\\xc2\\x01\\xcc',
		'\\x0c\\xc9\\x07'
	);

	static var plugIcon:Bytes = bytes(
		'\\x02',
		'\\x12\\x12',
		'\\x05\\xc2\\x04\\xc2\\n\\xc2\\x04\\xc2\\n\\xc2\\x04\\xc2\\n\\xc2\\x04\\xc2',
		'\\n\\xc2\\x04\\xc2\\x19\\xce\\x04\\xce\\x06\\xca\\x08\\xca\\x08\\xca\\x08\\xca',
		'\\t\\xc8\\x0b\\xc6\\r\\xc4\\x0f\\xc2\\x10\\xc2\\x10\\xc2\\x08'
	);

	static var bluetoothIcon:Bytes = bytes(
		'\\x02',
		'\\t\\x11',
		'\\x04\\xc1\\x08\\xc2\\x07\\xc3\\x06\\xc4\\x01\\xc2\\x02\\xc2\\x01\\xc2\\x01\\xc2',
		'\\x01\\xc2\\x01\\xc2\\x02\\xc6\\x04\\xc4\\x06\\xc2\\x06\\xc4\\x04\\xc6\\x02\\xc2',
		'\\x01\\xc2\\x01\\xc4\\x02\\xc2\\x01\\xc2\\x04\\xc4\\x05\\xc3\\x06\\xc2\\x07\\xc1',
		'\\x04'
	);

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
		NAME = "BatTri";
	}

	override function foreground():Void {
		draw(true);
		Wash.system.requestTick(1000);
	}

	override function sleep():Bool return true;
	override function wake():Void draw();
	override function tick(_):Void draw();

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
		// TODO: check output
		// TODO: check if 240 instead of 239 is fine
		var battery = Std.int(batteryLevel / 100 * 240);
		var hr = -1; // TODO: fetch heart rate somehow...

		var plug = try Watch.battery.charging() catch (_) false;
		var bluetooth = try Watch.connected() catch (_) false;
		var st = try Watch.accel.steps catch (_) -1;

		if (redraw) {
			draw.fill();

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
			display.set_window(80, 26, 160, 82 - 26);
			display.quick_start();
			for (i in 0...(82-26)) {
				var buf = display.linebuffer;
				var bgLen = opFloorDiv((i+26)*240, 214);
				var bgPos = 160 - bgLen;
				var barLen = opFloorDiv((i+26)*battery, 214);
				fill(buf, 0, bgPos, 0);
				fill(buf, mid, barLen, bgPos);
				fill(buf, ui, bgLen - barLen, bgPos + barLen);
				display.quick_write(Syntax.sub(buf,0,160*2));
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

			if (battery < 192) {
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
		}

		if (hh != now.HH) {
			draw.set_color(hi);
			draw.set_font(Fonts.sans36);
			draw.string('{:02}'.format(now.HH), 18, 91, 72);
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
			if (hr < 0) draw.string('-', 25, 219);
			else draw.string('{}'.format(hr), 25, 219);
		}

		if (this.st != st) {
			draw.set_color(ui);
			draw.set_font(Fonts.sans18);
			if (st < 0) draw.string('-', 133, 219, 80, true);
			else draw.string('{}'.format(st), 133, 219, 80, true);
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
