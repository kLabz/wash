package wasp;

// TODO
private typedef Pin = {value:Void->Value};
private typedef Value = Any;

class PinHandler {
	var pin:Pin;
	var value:Value;

	public function new(pin:Pin) {
		this.pin = pin;
		value = pin.value();
	}

	public function get_event():Null<Value> {
		var newValue = pin.value();
		if (value == newValue) return null;

		value = newValue;
		return newValue;
	}
}
