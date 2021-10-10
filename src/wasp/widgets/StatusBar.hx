package wasp.widgets;

import wasp.util.TimeTuple;

class StatusBar implements IWidget {
	var clock:Clock;
	var meter:BatteryMeter;
	var notif:NotificationBar;

	public var displayClock(get, set):Bool;
	function get_displayClock():Bool return clock.enabled;
	function set_displayClock(v:Bool):Bool return clock.enabled = v;

	function new() {
		clock = new Clock();
		meter = new BatteryMeter();
		notif = new NotificationBar();
	}

	public function draw():Void {
		clock.draw();
		meter.draw();
		notif.draw();
	}

	public function update():Null<TimeTuple> {
		var now = clock.update();

		if (now != null) {
			meter.update();
			notif.update();
		}

		return now;
	}
}
