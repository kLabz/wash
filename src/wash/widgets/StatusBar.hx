package wash.widgets;

import python.Syntax;

import wash.util.DateTimeTuple;
import wasp.Watch;

class StatusBar implements IWidget {
	var clock:Clock;
	var meter:BatteryMeter;
	var notif:NotificationBar;

	public var displayClock(get, set):Bool;
	function get_displayClock():Bool return clock.enabled;
	function set_displayClock(v:Bool):Bool return clock.enabled = v;

	public function new() {
		clock = new Clock();
		meter = new BatteryMeter();
		notif = new NotificationBar(2, 2);
	}

	public function dispose():Void {
		clock.dispose();
		meter.dispose();
		notif.dispose();

		clock = null;
		meter = null;
		notif = null;

		Syntax.delete(clock);
		Syntax.delete(meter);
		Syntax.delete(notif);
	}

	public function draw():Void {
		Watch.drawable.fill(Wash.system.theme.primary, 0, 0, 240, 26);

		clock.draw();
		meter.draw();
		notif.draw();
	}

	public function update():Null<DateTimeTuple> {
		var now = clock.update();

		if (now != null) {
			meter.update();
			notif.update();
		}

		return now;
	}
}
