package wash.app.watchface;

import python.Bytes;
import python.Syntax;
import python.Syntax.bytes;
import python.Syntax.opFloorDiv;

import wash.Wash;
import wasp.Watch;
import wasp.Fonts;
import wasp.driver.Draw565.Fill.fill;

using python.NativeStringTools;

class BatTri extends BaseWatchFace {
	static var days = ["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"];

	static var heartIcon:Bytes = bytes(
		'\\x02',
		'\\x12\\x10',
		'\\x01\\x01@TA\\x80\\xa2\\x81\\xc0\\xc6\\xc1\\x81@xA\\x01',
		'\\x02\\x80$\\x81A\\xc0\\xa2\\xc1@\\xc6A\\xc1\\x80T\\x81\\x01',
		'\\x01\\x01\\xc1E\\xc1\\xc0*\\xc1\\xc1AE@\\xa2A\\x01\\x81',
		'\\x80\\xc6\\x85AA\\x81\\x81\\x87\\xc0T\\xc1A\\x85@NA',
		'\\x80*\\x81\\xc0\\xc6\\xc9@\\xa2A\\xc1\\xc4\\xc1\\x01\\x01A\\xc8',
		'\\xc1A\\xc4A\\x01\\x01\\x80x\\x81\\xc1\\xc1\\xc0N\\xc1A@',
		"\\xc6D\\x80\\xa2\\x81\\xc0x\\xc1D\\xc1@$A\\x80N\\x81",
		'\\x81\\xc0\\xc6\\xc1@xA\\x01\\x81\\xc4A\\x80$\\x81D\\xc0',
		'*\\xc1@NA\\x80x\\x81\\x01\\xc0\\xc6\\xc1A\\x01\\x01\\x81',
		'\\x83\\x01\\x05\\x01\\x81@\\xa2A\\x01A\\x01\\x81\\x80*\\x81\\x07',
		'\\xc0N\\xc1@\\xc6AD\\x81\\x81\\x01\\x80\\xa2\\x81BA\\xc1',
		'\\x05\\xc1AC\\xc0T\\xc1\\x01@*A\\x80\\xc6\\x82\\x81\\xc0',
		'N\\xc1\\x07\\xc1\\x81\\x82@\\xa2A\\x01\\x80T\\x81\\xc0\\xc6\\xc1',
		'\\xc1@NA\\tA\\xc1\\xc1\\xc1A\\x80\\xa2\\x81\\xc1A\\x0b',
		'\\xc0*\\xc1@\\xc6ABA\\xc1\\r\\xc1AA\\xc1\\x0f\\xc1',
		'\\xc1\\x08'
	);

	static var stepsIcon:Bytes = bytes(
		'\\x02',
		'\\x17\\x13',
		'\\n\\x01@NA\\x80x\\x81\\xc0\\x9c\\xc1@\\x9dB\\xc1\\x81',
		'\\x80$\\x81\\t\\xc0N\\xc1@\\x9cAA\\x01\\x80\\x9d\\x81\\xc0',
		'\\xc1\\xc1\\xc7\\xc1\\x81@NA\\x06\\x80*\\x81\\xc1\\xc1\\xc1\\x01',
		'\\xcb\\xc1\\xc0x\\xc1\\x05\\xc1@\\xc1BA\\x01LA\\x81\\x04',
		'\\x80N\\x81BA\\x01M\\xc1\\x05\\xc1A\\xc0\\x9d\\xc1\\x01A',
		'AK@rA\\n\\x01\\x80x\\x81\\xc0\\xc1\\xc1\\xc8@\\x9c',
		'A\\x01\\x0c\\x01\\x81\\xc1\\xc1\\xc2\\xc1A\\x80N\\x81\\x11\\x01\\xc0',
		'$\\xc1\\x01%@*A\\x80x\\x81\\xc0\\x9c\\xc1\\xc1\\x81@',
		'NA\\x01\\x0e\\x80*\\x81\\xc0\\x9d\\xc1@\\xc1AEA\\x80',
		'x\\x81\\x07\\xc0N\\xc1\\x81@*A\\xc1\\x81\\x80\\x9d\\x81\\xc0',
		'\\xc1\\xc1\\xc9@\\x9cA\\x05\\x80x\\x81\\xc2\\x81A\\xcc\\xc1\\x05',
		'\\xc1\\xc2\\x81A\\xcc\\xc1\\x05\\xc1\\xc2\\x81A\\xcc\\xc0r\\xc1\\x05',
		'@NA\\x80\\xc1\\x81\\x81\\xc0x\\xc1@\\x9cA\\x8a\\x81\\xc1',
		'\\x07\\x01\\x80*\\x81\\x01\\xc0$\\xc1@xA\\x80\\x9d\\x81\\xc0',
		"\\xc1\\xc1\\xc4\\xc1\\x81A@$A\\x0fA\\x80N\\x81\\x81\\xc0",
		'*\\xc1\\x01\\n'
	);

	static var plugIcon:Bytes = bytes(
		'\\x02',
		'\\x12\\x12',
		'\\x0b@TA\\x80\\xa2\\x81\\xc0N\\xc1\\x0eA@\\xc6B\\x80',
		'x\\x81\\n\\x01\\x02\\xc0T\\xc1BA@*A\\t\\xc1\\x81',
		'\\x01\\xc1\\x80\\xc6\\x82\\x81A\\t\\xc1\\x82\\xc0\\xa2\\xc1\\x82\\x81A',
		'\\x03A@xA\\x80N\\x81\\x03\\xc0*\\xc1@\\xc6AD',
		'A\\xc1\\x03\\xc1AA\\x80\\xa2\\x81\\x03\\x81E\\x81\\x01\\x02\\xc1',
		"AB\\xc0T\\xc1\\x02@$A\\x80\\xc6\\x87\\xc0x\\xc1\\x01",
		'@*A\\x81\\x82\\x80T\\x81\\x03\\xc0N\\xc1@\\xc6H\\x80',
		'\\xa2\\x81AB\\xc0T\\xc1\\x04@NA\\x80\\xc6\\x8b\\xc1\\x05',
		'\\xc0*\\xc1\\x8a@\\xa2A\\x01\\x06A\\x8a\\x80x\\x81\\x01\\x05',
		'\\x81\\xc0\\xc6\\xca@TA\\x05\\x80N\\x81\\xc1\\xc8\\xc1A\\x05',
		'\\x81\\xc1\\xc1\\xc1\\xc0x\\xc1@\\xa2A\\x80\\xc6\\x84A\\xc0*',
		'\\xc1\\x05@NA\\x81\\x81\\x81A\\x02\\xc1\\xc1A\\x80$\\x81',
		'\\x07\\xc0\\xc6\\xc1\\xc1\\xc1A\\x0e\\xc1\\xc1A\\x0f'
	);

	static var bluetoothIcon:Bytes = bytes(
		'\\x02',
		'\\n\\x12',
		'\\x04@NA\\x01\\x08\\x80x\\x81\\xc0\\xa2\\xc1\\x01\\x07\\x81@',
		'\\xc6A\\xc1\\x01\\x06\\x81AA\\xc1\\x01\\x01\\x01\\x81\\x01\\x01\\x81',
		'A\\x80*\\x81A\\xc1\\x01\\xc0N\\xc1A@\\xa2A\\x01\\x80',
		'x\\x81\\xc0\\xc6\\xc1\\x01\\x81\\xc1\\x81\\x01@NA\\xc1\\x80\\xa2',
		'\\x81\\xc0x\\xc1@\\xc6A\\x80N\\x81A\\xc0\\xa2\\xc1\\x01\\x02',
		'\\x81AAAA\\xc1\\x01\\x04\\x81AA\\xc1\\x01\\x05\\x81A',
		'A\\xc1\\x01\\x04\\x81BAA\\xc1\\x01\\x02\\x81A\\xc1@x',
		'A\\x80\\xc6\\x81\\xc0N\\xc1\\x81@\\xa2A\\x01\\x80*\\x81\\xc0',
		'\\xc6\\xc1A\\x01@xA\\xc1\\x01A\\xc1A\\x01A\\x01\\x01',
		'A\\xc1\\x81\\xc1\\x80\\xa2\\x81\\x01\\x04A\\xc1\\xc1\\x81\\x01\\x05A',
		'\\xc1\\x81\\x01\\x06A\\x81\\x01\\x07\\xc0N\\xc1\\x01\\x04'
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
		var hi = Wash.system.theme.bright;
		var mid = Wash.system.theme.mid;
		var ui = Wash.system.theme.ui;

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
