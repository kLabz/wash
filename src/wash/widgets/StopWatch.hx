package wash.widgets;

import wasp.Fonts;
import wasp.Watch;

using python.NativeStringTools;

class StopWatch implements IWidget {
	public var startedAt:Int;
	public var count:Int;
	var inverted:Bool;

	public var started(get, null):Bool;
	function get_started():Bool return startedAt > 0;

	var y:Int;
	var lastCount:Int;

	public function new(y:Int, ?inverted = false) {
		this.y = y;
		this.inverted = inverted;
		reset();
	}

	public function start():Void {
		var uptime = opFloorDiv(Watch.rtc.get_uptime_ms(), 10);
		startedAt = uptime - count;
	}

	public function stop():Void {
		startedAt = 0;
	}

	public function reset():Void {
		count = 0;
		startedAt = 0;
		lastCount = -1;
	}

	public function draw():Void {
		lastCount = -1;

		if (inverted)
			Watch.drawable.fill(Wash.system.theme.secondary, 0, y-6, 240, 36+12);

		update();
	}

	public function update():Void {
		if (startedAt > 0) {
			var uptime = opFloorDiv(Watch.rtc.get_uptime_ms(), 10);
			count = uptime - startedAt;
			if (count > 999*60*100) reset();
		}

		if (lastCount != count) {
			var centisecs = count;
			var secs = opFloorDiv(centisecs, 100);
			centisecs = centisecs % 100;
			var minutes = opFloorDiv(secs, 60);
			secs = secs % 60;

			var t1 = '{}:{:02}'.format(minutes, secs);
			var t2 = '{:02}'.format(centisecs);

			var draw = Watch.drawable;
			draw.set_font(Fonts.sans36);

			if (inverted)
				draw.set_color(0, Wash.system.theme.secondary);
			else
				draw.set_color(Wash.system.theme.secondary);

			var w = Fonts.width(Fonts.sans36, t1);
			draw.string(t1, 180-w, y);
			if (!inverted) draw.fill(0, 0, y, 180-w, 36);
			draw.set_font(Fonts.sans24);
			draw.string(t2, 180, y+18, 46);

			lastCount = count;
		}
	}
}
