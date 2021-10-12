package wasp.widgets;

import wasp.event.TouchEvent;

class ToggleButton extends Button {
	var state:Bool;

	public function new(x:Int, y:Int, w:Int, h:Int, label:String) {
		super(x, y, w, h, label);
		state = false;
	}

	override public function draw():Void {
		update(
			Watch.drawable.darken(state ? Wasp.system.theme.ui : Wasp.system.theme.mid),
			Wasp.system.theme.mid,
			Wasp.system.theme.bright
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
