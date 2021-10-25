package wash.app.user;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.delete;

import wasp.Fonts;
import wasp.Watch;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.StopWatch;

using python.NativeStringTools;

@:native('StopclockApp')
class Stopclock extends BaseApplication {
	static var icon:Bytes = bytes(
		'\\x02',
		'@@',
		'?\\xff\\xdd\\x8a6\\x8a6\\x8a9\\x84<\\x84<\\x84<\\x84',
		'9\\x8a\\x08\\xc2)\\x90\\x05\\xc3&\\x94\\x04\\xc3#\\x87\\n\\x87',
		'\\x03\\xc3!\\x85\\x10\\x85\\x03\\xc3\\x1f\\x84\\t@\\xacE\\x06\\x84',
		'\\x03\\xc3\\x1d\\x83\\x0bH\\x05\\x83\\x03\\xc3\\x1b\\x83\\x0cJ\\x04\\x83',
		'\\x03\\xc3\\x19\\x83\\rK\\x04\\x83\\x03\\xc2\\x18\\x83\\x03\\xc2\\tL',
		'\\x04\\x83\\x1b\\x83\\x04\\xc3\\x08M\\x04\\x83\\x1a\\x83\\x05\\xc3\\x07N',
		'\\x03\\x83\\x19\\x83\\x07\\xc3\\x06O\\x03\\x83\\x18\\x83\\x08\\xc2\\x06P',
		'\\x02\\x83\\x17\\x83\\x11P\\x03\\x83\\x16\\x83\\x11Q\\x02\\x83\\x16\\x83',
		'\\x11Q\\x02\\x83\\x15\\x83\\x12Q\\x03\\x83\\x14\\x83\\x12R\\x02\\x83',
		'\\x14\\x83\\x12R\\x02\\x83\\x14\\x83\\x02\\xc6\\nR\\x02\\x83\\x14\\x83',
		'\\x02\\xc6\\nR\\x02\\x83\\x14\\x83\\x13Q\\x02\\x83\\x14\\x83\\x14P',
		'\\x02\\x83\\x14\\x83\\x15O\\x02\\x83\\x14\\x83\\x16M\\x03\\x83\\x15\\x83',
		'\\x16L\\x02\\x83\\x16\\x83\\x17K\\x02\\x83\\x16\\x83\\t\\xc2\\rI',
		'\\x03\\x83\\x17\\x83\\x07\\xc3\\x0eH\\x02\\x83\\x18\\x83\\x06\\xc3\\x10F',
		'\\x03\\x83\\x19\\x83\\x04\\xc3\\x12D\\x03\\x83\\x1a\\x83\\x04\\xc2\\t\\xc2',
		'\\tB\\x04\\x83\\x1b\\x83\\x0e\\xc2\\x0e\\x83\\x1d\\x83\\r\\xc2\\r\\x83',
		'\\x1f\\x83\\x0c\\xc2\\x0c\\x83!\\x83\\x0b\\xc2\\x0b\\x83#\\x84\\t\\xc2',
		'\\t\\x84%\\x85\\x10\\x85\\\'\\x87\\n\\x87*\\x94.\\x903\\x8a',
		'?\\xff]'
	);

	var timer:StopWatch;
	var splits:Array<Int>;
	var nsplits:Int;

	public function new() {
		NAME = "Stopclock";
		ICON = icon;

		timer = new StopWatch(120-36, true);
		reset();
	}

	override public function foreground():Void {
		Wash.system.bar.displayClock = true;
		draw();
		Wash.system.requestTick(97);
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.BUTTON | EventMask.NEXT);
	}

	override function sleep():Bool return true;
	override function wake():Void update();
	override public function tick(_):Void update();

	override public function swipe(event:TouchEvent):Bool {
		if (timer.startedAt <= 0) reset();
		return true;
	}

	override public function touch(event:TouchEvent):Void {
		if (timer.started) {
			splits.insert(0, timer.count);
			delete(splits.slice(4));
			nsplits++;
		} else {
			reset();
		}

		update();
		drawSplits();
	}

	override public function press(_, state:Bool):Bool {
		if (!state) return true;

		if (timer.started) timer.stop();
		else timer.start();

		return false;
	}

	function reset():Void {
		timer.reset();
		splits = [];
		nsplits = 0;
	}

	function update():Void {
		Wash.system.bar.update();
		timer.update();
	}

	function draw():Void {
		Watch.drawable.fill();
		Wash.system.bar.draw();
		timer.draw();
		drawSplits();
	}

	function drawSplits():Void {
		var draw = Watch.drawable;
		if (splits.length == 0) {
			draw.fill(0, 0, 120+12, 240, 120-12);
			return;
		}

		draw.set_font(Fonts.sans24);
		draw.set_color(Wash.system.theme.primary);
		var y = 240 - 6 - splits.length * 24;

		var n = nsplits;
		for (i => s in splits) {
			var centisecs = s;
			var secs = opFloorDiv(centisecs, 100);
			centisecs = centisecs % 100;
			var minutes = opFloorDiv(secs, 60);
			secs = secs % 60;

			var t = '# {}   {:02}:{:02}.{:02}'.format(n, minutes, secs, centisecs);
			n--;

			draw.string(t, 0, y+i*24, 240);
		}
	}
}
