package wash.app.user;

import python.Bytes;
import python.Lib;
import python.Syntax.bytes;
import python.Syntax.delete;
import python.Syntax.positional;

import wash.app.system.Settings;
// import wash.app.user.settings.HeartConfig;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.Button;
import wasp.Fonts;
import wasp.Gc;
import wasp.Machine.Timer;
import wasp.Watch;

using python.NativeStringTools;

@:native('HeartApp')
class HeartApp extends BaseApplication {
	// Configuration
	static var debug(default, set):Bool = false;
	static var runInBackground(default, set):Bool = false;

	static var monitoring:Bool;
	static var lastRate:Int = -1;
	public static function getRate():Int {
		if (hrdata == null || !monitoring) {
			lastRate = -1;
			return -1;
		}

		var hr = hrdata.get_heart_rate();
		if (hr == null) return lastRate;
		lastRate = hr;
		return hr;
	}
	static var hrdata:PPG;

	var x:Int;
	var resumeButton:Button;

	public function new() {
		super();

		ID = 0x03;
		NAME = "Heart";
		ICON = bytes(
			'\\x02',
			'@@',
			'?\\xff\\xff\\x13@\\xc6H\\x10H H\\x10H\\x1cD\\x08',
			'D\\x08D\\x08D\\x18D\\x08D\\x08D\\x08D\\x16B\\x04',
			'\\x80\\xc1\\x88\\x04B\\x04B\\x04\\x88\\x04B\\x14B\\x04\\x88\\x04',
			'B\\x04B\\x04\\x88\\x04B\\x12B\\x02\\x90\\x02D\\x02\\x90\\x02',
			'B\\x10B\\x02\\x90\\x02D\\x02\\x90\\x02B\\x10B\\x02\\x92\\x04',
			'\\x92\\x02B\\x10B\\x02\\x92\\x04\\x92\\x02B\\x0eB\\x02\\xac\\x02',
			'B\\x0cB\\x02\\x97\\x04\\x91\\x02B\\x0cB\\x02\\x97\\x04\\x91\\x02',
			'B\\x0cB\\x02\\x96\\x06\\x90\\x02B\\x0cB\\x02\\x96\\x02\\xc2\\x02',
			'\\x90\\x02B\\x0cB\\x02\\x95\\x03\\xc2\\x03\\x8f\\x02B\\x0cB\\x02',
			'\\x95\\x02\\xc4\\x02\\x8f\\x02B\\x0cB\\x02\\x94\\x03\\xc4\\x02\\x8f\\x02',
			'B\\x0cB\\x02\\x94\\x02\\xc5\\x03\\x8e\\x02B\\x0cB\\x02\\x94\\x02',
			'\\xc6\\x02\\x8e\\x02B\\x0eB\\x02\\x91\\x02\\xc3\\x01\\xc3\\x02\\x8c\\x02',
			'B\\x10B\\x02\\x91\\x02\\xc2\\x02\\xc3\\x03\\x8b\\x02B\\x10B\\x02',
			'\\x90\\x02\\xc3\\x03\\xc3\\x02\\x8b\\x02B&\\xc2\\x04\\xc3\\x02\\x822',
			'\\xc3\\x05\\xc2\\x02\\x82\\x1b\\xd9\\x03\\x81\\x02\\xc2\\x05\\xce\\x0c\\xd9\\x02',
			"\\x82\\x02\\xc3\\x04\\xce\\'\\x82\\x03\\xc2\\x03\\xc32\\x84\\x02\\xc2\\x03",
			'\\xc2\\x1fB\\x02\\x94\\x02\\xc3\\x01\\xc3\\x05B\\x18B\\x02\\x94\\x03',
			'\\xc2\\x01\\xc2\\x03\\x81\\x02B\\x18B\\x02\\x95\\x02\\xc5\\x02\\x82\\x02',
			'B\\x1aB\\x02\\x93\\x02\\xc4\\x05B\\x1cB\\x02\\x94\\x02\\xc3\\x02',
			'\\x81\\x02B\\x1eB\\x02\\x92\\x02\\xc2\\x04B B\\x02\\x93\\x07',
			"B\"B\\x02\\x91\\x05B$B\\x02\\x94\\x02B&B\\x02",
			'\\x90\\x02B(B\\x02\\x90\\x02B*B\\x02\\x8c\\x02B,',
			'B\\x02\\x8c\\x02B.B\\x02\\x88\\x02B0B\\x02\\x88\\x02',
			'B2B\\x02\\x84\\x02B4B\\x02\\x84\\x02B6B\\x04',
			'B8B\\x04B:D<D?\\xff '
		);

		debug = false;
		hrdata = null;
	}

	override public function foreground():Void {
		Watch.hrs.enable();

		initialDraw();

		Wash.system.requestTick(125);
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.BUTTON);

		if (hrdata == null) hrdata = new PPG(Watch.hrs.read_hrs());
		if (debug) hrdata.enable_debug();
		x = 0;
		monitoring = true;
	}

	override public function background():Void {
		if (!runInBackground) stop(true);
	}

	static function stop(clear:Bool):Void {
		Watch.hrs.disable();
		monitoring = false;
		if (clear) hrdata = null;
	}

	function resume():Void {
		Watch.hrs.enable();
		monitoring = true;
		x = 0;
		initialDraw();
	}

	override function registered(_):Void {
		// Settings.registerApp(
		// 	NAME,
		// 	HeartConfig,
		// 	ID,
		// 	HeartConfig.serialize,
		// 	HeartConfig.deserialize
		// );
	}

	override function unregistered():Void {
		// Settings.unregisterApp(NAME);
	}

	override public function press(_, state:Bool):Bool {
		if (!state) return true;
		monitoring = !monitoring;

		if (!monitoring) {
			stop(false);
			resumeButton = new Button(40, 90, 160, 60, "Resume");
			resumeButton.draw();
		} else {
			resume();
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		if (!monitoring && resumeButton.touch(event)) resume();
	}

	function initialDraw():Void {
		var draw = Watch.drawable;
		draw.fill(0);
		draw.set_color(Wash.system.theme.highlight);
		draw.string('PPG graph', 0, 6, 240);
	}

	override public function tick(ticks:Int):Void {
		if (!monitoring) return;

		var t = new Timer(positional("id", 1), positional("period", 8000000));
		t.start();
		subtick(1);
		Wash.system.keepAwake();
		Gc.collect();

		while (t.time() < 41666) Lib.pass();
		subtick(1);
		Gc.collect();

		while (t.time() < 83332) Lib.pass();
		subtick(1);

		t.stop();
		delete(t);
		Gc.collect();
	}

	function subtick(ticks:Int):Void {
		var draw = Watch.drawable;
		var spl = hrdata.preprocess(Watch.hrs.read_hrs());

		if (hrdata.data.length > 240) {
			draw.set_font(Fonts.sans24);
			draw.set_color(Wash.system.theme.highlight);
			draw.string('{} bpm'.format(getRate()), 0, 6, 240);
		}

		var color = Wash.system.theme.secondary;

		// If the maths goes wrong lets show it in the chart
		if (spl > 100 || spl < -100) color = Wash.system.theme.highlight;
		if (spl > 104 || spl < -104) spl = 0;
		spl += 104;

		draw.fill(0, x, 32, 1, 208-spl);
		draw.fill(color, x, 240-spl, 1, spl);
		if (x < 238) draw.fill(0, x+1, 32, 2, 208);
		x += 2;
		if (x >= 240) x = 0;
	}

	static function set_debug(v:Bool):Bool {
		debug = v;
		if (debug && hrdata != null) hrdata.enable_debug();
		return debug;
	}

	static function set_runInBackground(v:Bool):Bool {
		runInBackground = v;
		if (!runInBackground && hrdata != null) stop(true);
		return runInBackground;
	}
}
