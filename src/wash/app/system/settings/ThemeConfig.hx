package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Button;
import wash.widgets.ColorPicker;
import wasp.Watch;

class ThemeConfig extends BaseApplication implements ISettingsApplication {
	var settings:Settings;

	var themeColor:Int;
	var uiButton:Button;
	var midButton:Button;
	var brightButton:Button;
	var uiColorPicker:ColorPicker;
	var midColorPicker:ColorPicker;
	var brightColorPicker:ColorPicker;

	public function new(settings:Settings) {
		this.settings = settings;

		themeColor = 0;
		uiColorPicker = new ColorPicker(Wash.system.theme.ui);
		midColorPicker = new ColorPicker(Wash.system.theme.mid);
		brightColorPicker = new ColorPicker(Wash.system.theme.bright);
		uiButton = new Button(10, 90, 220, 40, "Set primary");
		midButton = new Button(10, 140, 220, 40, "Set secondary");
		brightButton = new Button(10, 190, 220, 40, "Set highlight");
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case LEFT | RIGHT:
				switch (themeColor) {
					case 1: Wash.system.theme.ui = uiColorPicker.color;
					case 2: Wash.system.theme.mid = midColorPicker.color;
					case 3: Wash.system.theme.bright = brightColorPicker.color;
					case _: return true;
				}

				themeColor = 0;
				settings.draw();
				return false;

			case _:
		}

		return true;
	}

	override public function touch(event:TouchEvent):Void {
		switch (themeColor) {
			case 0:
				if (uiButton.touch(event)) themeColor = 1;
				if (midButton.touch(event)) themeColor = 2;
				if (brightButton.touch(event)) themeColor = 3;
				if (themeColor > 0) settings.draw();

			case 1: uiColorPicker.touch(event);
			case 2: midColorPicker.touch(event);
			case 3: brightColorPicker.touch(event);
		}
	}

	public function draw():Void {
		switch (themeColor) {
			case 0:
				Watch.drawable.fill(Wash.system.theme.ui, 55, 35, 40, 40);
				Watch.drawable.fill(Wash.system.theme.mid, 100, 35, 40, 40);
				Watch.drawable.fill(Wash.system.theme.bright, 145, 35, 40, 40);
				uiButton.draw();
				midButton.draw();
				brightButton.draw();

			case 1: uiColorPicker.draw();
			case 2: midColorPicker.draw();
			case 3: brightColorPicker.draw();
		}
	}

	public function update():Void {}
}
