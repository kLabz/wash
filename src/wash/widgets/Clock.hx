package wash.widgets;

import python.Tuple;

import wasp.Fonts;
import wasp.Watch;
import wash.util.DateTimeTuple;

using python.NativeStringTools;

class Clock implements IWidget {
	public var enabled:Bool;
	var displayedTime:Null<Tuple2<Int, Int>>;

	public function new(enabled:Bool = true) {
		this.enabled = enabled;
		displayedTime = null;
	}

	public function dispose():Void {}

	public function draw():Void {
		displayedTime = null;
		update();
	}

	public function update():Null<DateTimeTuple> {
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
			Watch.drawable.set_font(Fonts.sans24);
			Watch.drawable.set_color(0, Wash.system.theme.primary);
			Watch.drawable.string(t, 52, 2, 138);
		}

		displayedTime = Tuple2.make(now.HH, now.MM);
		return now;
	}
}
