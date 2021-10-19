package wash.widgets;

import python.Tuple;

import wasp.Fonts;
import wasp.Watch;
import wash.util.TimeTuple;

using python.NativeStringTools;

class Clock implements IWidget {
	public var enabled:Bool;
	var displayedTime:Null<Tuple2<Int, Int>>;

	public function new(enabled:Bool = true) {
		this.enabled = enabled;
		displayedTime = null;
	}

	public function draw():Void {
		displayedTime = null;
		update();
	}

	public function update():Null<TimeTuple> {
		var now = Watch.rtc.get_localtime();

		if (
			displayedTime != null
			&& displayedTime._1 == now.HH
			&& displayedTime._2 == now.MM
		)
			return null;

		if (enabled && (
			displayedTime == null
			|| displayedTime._1 != now.HH
			|| displayedTime._2 != now.MM
		)) {
			var t = '{:02}:{:02}'.format(now.HH, now.MM);
			Watch.drawable.set_font(Fonts.sans28);
			Watch.drawable.set_color(Wash.system.theme.statusClock);
			Watch.drawable.string(t, 52, 4, 138);
		}

		displayedTime = Tuple2.make(now.HH, now.MM);
		return now;
	}
}
