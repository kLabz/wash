package wash;

enum abstract BrightnessLevel(Int) to Int {
	var Low = 1;
	var Mid = 2;
	var High = 3;

	@:to
	public function toString():String {
		return switch (cast this:BrightnessLevel) {
			case High: "High";
			case Mid: "Mid";
			case _: "Low";
		};
	}
}
