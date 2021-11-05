package wash;

enum abstract WakeMode(Int) to Int {
	var Button = 1;
	var Tap = 2;
	var DoubleTap = 3;

	@:to
	public function toString():String {
		return switch (cast this:WakeMode) {
			case Tap: "Tap";
			case DoubleTap: "Double tap";
			case _: "Button";
		};
	}
}
