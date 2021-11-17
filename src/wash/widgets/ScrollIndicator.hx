package wash.widgets;

import wasp.Builtins;
import wasp.Watch;

@:keep
@:native('ScrollIndicator')
class ScrollIndicator {
	var y:Int;
	public var value:Int;
	public var min:Int;
	public var max:Int;

	public function new(y:Int = 2, min:Int = 0, max:Int = 0, value:Int = 0) {
		this.y = y;
		this.min = min;
		this.max = max;
		this.value = value;
	}

	public function draw():Void {
		update();
	}

	public function update():Void {
		if (min == max) return;

		var draw = Watch.drawable;
		var size = 240-2-y;
		var trackSize = opFloorDiv(size, max - min + 1);
		var trackPos = Builtins.int((value - min) * trackSize);

		draw.fill(0, 240-5, y, 4, size);
		draw.fill(Wash.system.theme.shadow, 240-4, y, 2, size);
		draw.fill(Wash.system.theme.primary, 240-5, y + trackPos, 4, trackSize);
	}
}
