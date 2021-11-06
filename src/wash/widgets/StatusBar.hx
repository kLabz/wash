package wash.widgets;

import wash.util.DateTimeTuple;

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
		notif = new NotificationBar();
	}

	public function draw():Void {
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
