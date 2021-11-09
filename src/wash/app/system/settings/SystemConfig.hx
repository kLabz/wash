package wash.app.system.settings;

import python.Bytearray;
import python.Bytes;

import wash.app.ISettingsApplication;
import wash.event.TouchEvent;
import wash.util.Int16;
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

	public static function serialize(bytes:Bytearray):Void {
		bytes.append(F_NotifLevel);
		bytes.append(Settings.notificationLevel);

		bytes.append(F_BrightnessLevel);
		bytes.append(Settings.brightnessLevel);

		bytes.append(F_WakeMode);
		bytes.append(Settings.wakeMode);

		bytes.append(F_Theme);
		bytes.append(Wash.system.theme.primary_theme._1);
		bytes.append(Wash.system.theme.primary_theme._2);
		bytes.append(Wash.system.theme.secondary_theme._1);
		bytes.append(Wash.system.theme.secondary_theme._2);
		bytes.append(Wash.system.theme.highlight_theme._1);
		bytes.append(Wash.system.theme.highlight_theme._2);
	}

	public static function deserialize(bytes:Bytes, i:Int):Int {
		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case F_NotifLevel:
					Settings.notificationLevel = cast bytes.get(i++);
					if (!Wash.system.nightMode) Wash.system.notificationLevel = Settings.notificationLevel;

				case F_BrightnessLevel:
					Settings.brightnessLevel = cast bytes.get(i++);
					if (!Wash.system.nightMode) Wash.system.brightnessLevel = Settings.brightnessLevel;

				case F_WakeMode:
					Settings.wakeMode = bytes.get(i++);
					if (!Wash.system.nightMode) Wash.system.wakeMode = Settings.wakeMode;

				case F_Theme:
					Wash.system.theme.primary = Int16.fromBytes(bytes.get(i++), bytes.get(i++));
					Wash.system.theme.secondary = Int16.fromBytes(bytes.get(i++), bytes.get(i++));
					Wash.system.theme.highlight = Int16.fromBytes(bytes.get(i++), bytes.get(i++));

				case 0x00:
					break;
			}
		}

		return i;
	}
}

private enum abstract Field(Int) to Int {
	var F_NotifLevel = 0x01;
	var F_BrightnessLevel = 0x02;
	var F_WakeMode = 0x03;
	var F_Theme = 0x04;
}
