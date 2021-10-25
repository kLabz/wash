package wash.widgets;

import wash.event.TouchEvent;

class ToggleButton extends Button {
	public var state:Bool;

	public function new(x:Int, y:Int, w:Int, h:Int, label:String) {
		super(x, y, w, h, label);
		state = false;
	}

	override public function draw():Void {
		update(
			state ? Wash.system.theme.secondary : Wash.system.theme.primary,
			0
		);
	}

	override public function touch(event:TouchEvent):Bool {
		var ret = super.touch(event);

		if (ret) {
			state = !state;
			draw();
		}

		return ret;
	}
}
