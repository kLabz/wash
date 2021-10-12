package wasp.widgets;

import wasp.event.TouchEvent;

class ConfirmationView {
	var active:Bool;
	var value:Bool;
	var yesButton:Button;
	var noButton:Button;

	public function new() {
		active = false;
		value = false;
		yesButton = new Button(20, 140, 90, 45, 'Yes');
		noButton = new Button(130, 140, 90, 45, 'No');
	}

	public function draw(message:String):Void {
		var draw = Watch.drawable;

		// TODO: check if mute is needed
		Watch.display.mute(true);
		draw.set_color(Wasp.system.theme.bright);
		draw.set_font(Fonts.sans24);
		draw.fill();
		draw.string(message, 0, 60);
		yesButton.draw();
		noButton.draw();
		Watch.display.mute(false);

		active = true;
	}

	public function touch(event:TouchEvent):Bool {
		if (!active) return false;

		if (yesButton.touch(event)) {
			active = false;
			value = true;
			return true;
		}

		if (noButton.touch(event)) {
			active = false;
			value = false;
			return true;
		}

		return false;
	}
}
