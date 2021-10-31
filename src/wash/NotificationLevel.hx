package wash;

enum abstract NotificationLevel(Int) to Int {
	var Silent = 1;
	var Mid = 2;
	var High = 3;

	@:to
	public function toString():String {
		return switch (cast this:NotificationLevel) {
			case High: "High";
			case Mid: "Mid";
			case _: "Silent";
		};
	}
}
