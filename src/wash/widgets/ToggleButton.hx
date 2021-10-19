package wash.widgets;

import wasp.Watch;
import wash.event.TouchEvent;

class ToggleButton extends Button {
	public var state:Bool;

	public function new(x:Int, y:Int, w:Int, h:Int, label:String) {
		super(x, y, w, h, label);
		state = false;
	}

	override public function draw():Void {
		update(
			Watch.drawable.darken(state ? Wash.system.theme.mid : Wash.system.theme.ui),
			Wash.system.theme.mid,
			Wash.system.theme.bright
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
