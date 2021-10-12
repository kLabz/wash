package wasp.widgets;

import wasp.Watch.Button as Pin;

class PinHandler {
	var pin:Pin;
	var value:Null<Bool>;

	public function new(pin:Pin) {
		this.pin = pin;
		value = pin.value();
	}

	public function get_event():Null<Bool> {
		var newValue = pin.value();
		if (value == newValue) return null;

		value = newValue;
		return newValue;
	}
}
