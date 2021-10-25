package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Button;
import wash.widgets.ColorPicker;
import wasp.Watch;

class ThemeConfig extends BaseApplication implements ISettingsApplication {
	var settings:Settings;

	var themeColor:Int;
	var primaryButton:Button;
	var secondaryButton:Button;
	var highlightButton:Button;
	var primaryColorPicker:ColorPicker;
	var secondaryColorPicker:ColorPicker;
	var highlightColorPicker:ColorPicker;

	public function new(settings:Settings) {
		NAME = "Theme";

		this.settings = settings;

		themeColor = 0;
		primaryColorPicker = new ColorPicker(Wash.system.theme.primary);
		secondaryColorPicker = new ColorPicker(Wash.system.theme.secondary);
		highlightColorPicker = new ColorPicker(Wash.system.theme.highlight);
		primaryButton = new Button(10, 90, 220, 40, "Set primary");
		secondaryButton = new Button(10, 140, 220, 40, "Set secondary");
		highlightButton = new Button(10, 190, 220, 40, "Set highlight");
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case LEFT | RIGHT:
				switch (themeColor) {
					case 1: Wash.system.theme.primary = primaryColorPicker.color;
					case 2: Wash.system.theme.secondary = secondaryColorPicker.color;
					case 3: Wash.system.theme.highlight = highlightColorPicker.color;
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
				if (primaryButton.touch(event)) themeColor = 1;
				if (secondaryButton.touch(event)) themeColor = 2;
				if (highlightButton.touch(event)) themeColor = 3;
				if (themeColor > 0) settings.draw();

			case 1: primaryColorPicker.touch(event);
			case 2: secondaryColorPicker.touch(event);
			case 3: highlightColorPicker.touch(event);
		}
	}

	public function draw():Void {
		switch (themeColor) {
			case 0:
				Watch.drawable.fill(Wash.system.theme.primary, 55, 35, 40, 40);
				Watch.drawable.fill(Wash.system.theme.secondary, 100, 35, 40, 40);
				Watch.drawable.fill(Wash.system.theme.highlight, 145, 35, 40, 40);
				primaryButton.draw();
				secondaryButton.draw();
				highlightButton.draw();

			case 1: primaryColorPicker.draw();
			case 2: secondaryColorPicker.draw();
			case 3: highlightColorPicker.draw();
		}
	}

	public function update():Void {}
}
