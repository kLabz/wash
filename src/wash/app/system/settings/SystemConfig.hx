package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wash.widgets.ScrollIndicator;
import wash.widgets.Slider;
import wasp.Fonts;
import wasp.Watch;

class SystemConfig extends BaseApplication implements ISettingsApplication {
	static inline var NB_PAGES = 3;

	var page:Int; // TODO: enum abstract
	var scroll:ScrollIndicator;
	var brightnessSlider:Slider;
	var notifSlider:Slider;
	var wakeOnButton:Checkbox;
	var wakeOnTap:Checkbox;
	var wakeOnDoubleTap:Checkbox;

	public function new(_) {
		super();
		NAME = "Brightness";

		brightnessSlider = new Slider(3, 10, 90);
		notifSlider = new Slider(3, 10, 90);
		wakeOnButton = new Checkbox(6, 60, "Button");
		wakeOnTap = new Checkbox(6, 110, "Tap");
		wakeOnDoubleTap = new Checkbox(6, 160, "Double Tap");
		wakeOnButton.forcedChecked = true;

		page = 0;
		scroll = new ScrollIndicator(null, 0, NB_PAGES - 1, page);
	}

	override public function touch(event:TouchEvent):Void {
		switch (page) {
			case 0:
				brightnessSlider.touch(event);
				Settings.brightnessLevel = cast (brightnessSlider.value + 1);

				if (!Wash.system.nightMode)
					Wash.system.brightnessLevel = Settings.brightnessLevel;

			case 1:
				notifSlider.touch(event);
				Settings.notificationLevel = cast (notifSlider.value + 1);

				if (!Wash.system.nightMode)
					Wash.system.notificationLevel = Settings.notificationLevel;

			case 2:
				var hasChanged = false;

				if (wakeOnTap.touch(event)) {
					hasChanged = true;

					if (wakeOnTap.state) {
						wakeOnDoubleTap.state = false;
						Settings.wakeMode &= ~WakeMode.DoubleTap;
						Settings.wakeMode |= WakeMode.Tap;
					} else {
						Settings.wakeMode &= ~WakeMode.Tap;
					}
				} else if (wakeOnDoubleTap.touch(event)) {
					hasChanged = true;

					if (wakeOnDoubleTap.state) {
						wakeOnTap.state = false;
						Settings.wakeMode &= ~WakeMode.Tap;
						Settings.wakeMode |= WakeMode.DoubleTap;
					} else {
						Settings.wakeMode &= ~WakeMode.DoubleTap;
					}
				}

				if (hasChanged && !Wash.system.nightMode)
					Wash.system.wakeMode = Settings.wakeMode;

			case _:
		}
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case UP:
				page++;
				if (page >= NB_PAGES) page = NB_PAGES - 1;
				scroll.value = page;
				draw();

			case DOWN:
				page--;
				if (page < 0) page = 0;
				scroll.value = page;
				draw();

			case LEFT | RIGHT:
				return true;

			case _:
		}

		return false;
	}

	public function draw():Void {
		var draw = Watch.drawable;
		Watch.display.mute(true);
		draw.fill(0);

		draw.set_color(Wash.system.theme.highlight);
		draw.set_font(Fonts.sans24);
		draw.string(getTitle(), 0, 6, 240);

		switch (page) {
			case 0:
				brightnessSlider.value = Settings.brightnessLevel - 1;

			case 1:
				notifSlider.value = Settings.notificationLevel - 1;

			case _:
				wakeOnTap.state = Settings.wakeMode & WakeMode.Tap > 0;
				wakeOnDoubleTap.state = Settings.wakeMode & WakeMode.DoubleTap > 0;
				wakeOnButton.draw();
				wakeOnTap.draw();
				wakeOnDoubleTap.draw();
		}

		update();
		Watch.display.mute(false);
	}

	function getTitle():String {
		return switch (page) {
			case 0: "Brightness";
			case 1: "Notification level";
			case _: "Wake mode";
		};
	}

	public function update():Void {
		switch (page) {
			case 0:
				brightnessSlider.update();
				Watch.drawable.string(Settings.brightnessLevel.toString(), 0, 150, 240);

			case 1:
				notifSlider.update();
				Watch.drawable.string(Settings.notificationLevel.toString(), 0, 150, 240);

			case _:
				wakeOnTap.update();
				wakeOnDoubleTap.update();
		}

		scroll.draw();
	}
}
