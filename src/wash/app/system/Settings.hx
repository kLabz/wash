package wash.app.system;

import python.Bytes;
import python.Syntax.bytes;

import wasp.Fonts;
import wasp.Watch;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.util.TimeTuple;
import wash.widgets.Button;
import wash.widgets.ColorPicker;
import wash.widgets.ScrollIndicator;
import wash.widgets.Slider;
import wash.widgets.Spinner;

private enum abstract SettingsPage(Int) {
	var Brightness;
	var NotificationLevel;
	var Time;
	var Date;
	var Theme;
	var Units;

	@:to public function toString():String {
		return switch (cast this:SettingsPage) {
			case Brightness: "Brightness";
			case NotificationLevel: "Notification Level";
			case Time: "Time";
			case Date: "Date";
			case Theme: "Theme";
			case Units: "Units";
		};
	}
}

@:native('SettingsApp')
class Settings extends BaseApplication {
	static var icon:Bytes = bytes(
		'\\x02',
		'@@',
		'?\\xff\\xffQ@\\xacD:H7J5D\\x04D4',
		'C\\x06C3C\\x08C2C\\x08C\\x9f\\x13C\\x08C',
		'\\x9f\\x13C\\x08C3C\\x06C4D\\x04D5J7',
		'H:D?\\\\\\xc4:\\xc87\\xca5\\xc4\\x04\\xc44\\xc3',
		'\\x06\\xc33\\xc3\\x08\\xc3\\x13\\x9f\\xc3\\x08\\xc3\\x13\\x9f\\xc3\\x08\\xc3',
		'2\\xc3\\x08\\xc33\\xc3\\x06\\xc34\\xc4\\x04\\xc45\\xca7\\xc8',
		':\\xc4?\\x1eD:H7J5D\\x04D4C\\x06',
		'C3C\\x08C2C\\x08C\\x9f\\x13C\\x08C\\x9f\\x13',
		'C\\x08C3C\\x06C4D\\x04D5J7H:',
		'D?\\xff\\xffq'
	);

	var scroll:ScrollIndicator;
	var slider:Slider;
	var nfySlider:Slider;
	var HH:Spinner;
	var MM:Spinner;
	var dd:Spinner;
	var mm:Spinner;
	var yy:Spinner;
	var units:Array<String>;
	var unitsToggle:Button;
	var settings:Array<SettingsPage>;
	var settingsIndex:Int; // TODO: enum abstract
	var currentSetting:SettingsPage;

	var themeColor:Int;
	var uiButton:Button;
	var midButton:Button;
	var brightButton:Button;
	var uiColorPicker:ColorPicker;
	var midColorPicker:ColorPicker;
	var brightColorPicker:ColorPicker;

	public function new() {
		NAME = "Settings";
		ICON = icon;

		slider = new Slider(3, 10, 90);
		nfySlider = new Slider(3, 10, 90);
		HH = new Spinner(50, 60, 0, 23, 2);
		MM = new Spinner(130, 60, 0, 59, 2);
		dd = new Spinner(20, 60, 1, 31, 1);
		mm = new Spinner(90, 60, 1, 12, 1);
		yy = new Spinner(160, 60, 21, 60, 2);
		units = ["Metric", "Imperial"];
		unitsToggle = new Button(32, 90, 176, 48, "Change");

		themeColor = 0;
		uiColorPicker = new ColorPicker(Wash.system.theme.ui);
		midColorPicker = new ColorPicker(Wash.system.theme.mid);
		brightColorPicker = new ColorPicker(Wash.system.theme.bright);
		uiButton = new Button(10, 90, 220, 40, "Set primary");
		midButton = new Button(10, 140, 220, 40, "Set secondary");
		brightButton = new Button(10, 190, 220, 40, "Set highlight");

		settingsIndex = 0;
		settings = [Brightness, NotificationLevel, Time, Date, Theme, Units];
		currentSetting = settings[settingsIndex];
		scroll = new ScrollIndicator(null, 0, settings.length - 1, settingsIndex);
	}

	override public function foreground():Void {
		slider.value = Wash.system.brightness - 1;
		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN | EventMask.SWIPE_LEFTRIGHT);
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case UP:
				// TODO: move to settingsIndex setter?
				settingsIndex++;
				if (settingsIndex >= settings.length) settingsIndex = 0;
				currentSetting = settings[settingsIndex];
				if (currentSetting == Theme) themeColor = 0;
				draw();

			case DOWN:
				// TODO: move to settingsIndex setter?
				settingsIndex--;
				if (settingsIndex < 0) settingsIndex = settings.length - 1;
				currentSetting = settings[settingsIndex];
				if (currentSetting == Theme) themeColor = 0;
				draw();

			case LEFT | RIGHT:
				if (currentSetting != Theme) return true;
				switch (themeColor) {
					case 1: Wash.system.theme.ui = uiColorPicker.color;
					case 2: Wash.system.theme.mid = midColorPicker.color;
					case 3: Wash.system.theme.bright = brightColorPicker.color;
					case _: return true;
				}
				themeColor = 0;
				draw();

			case _:
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		switch (currentSetting) {
			case Brightness:
				slider.touch(event);
				Wash.system.brightness = slider.value + 1;

			case NotificationLevel:
				nfySlider.touch(event);
				Wash.system.notifyLevel = nfySlider.value + 1;

			case Time:
				if (HH.touch(event) || MM.touch(event)) {
					var now = Watch.rtc.get_localtime();
					Watch.rtc.set_localtime(TimeTuple.make(now.yyyy, now.mm, now.dd, HH.value, MM.value, 0, now.wday, now.yday));
				}

			case Date:
				if (dd.touch(event) || mm.touch(event) || yy.touch(event)) {
					var now = Watch.rtc.get_localtime();
					Watch.rtc.set_localtime(TimeTuple.make(yy.value + 2000, mm.value, dd.value, now.HH, now.MM, now.SS, now.wday, now.yday));
				}

			case Theme:
				switch (themeColor) {
					case 0:
						if (uiButton.touch(event)) themeColor = 1;
						if (midButton.touch(event)) themeColor = 2;
						if (brightButton.touch(event)) themeColor = 3;
						if (themeColor > 0) draw();

					case 1: uiColorPicker.touch(event);
					case 2: midColorPicker.touch(event);
					case 3: brightColorPicker.touch(event);
				}


			case Units:
				if (unitsToggle.touch(event)) {
					var index = (units.indexOf(Wash.system.units) + 1) % units.length;
					Wash.system.units = units[index];
				}
		}

		update();
	}

	function draw():Void {
		var draw = Watch.drawable;
		Watch.display.mute(true);
		draw.fill();
		draw.set_color(Wash.system.theme.bright);
		draw.set_font(Fonts.sans24);
		draw.string(currentSetting, 0, 6, 240);

		switch (currentSetting) {
			case Brightness:
				slider.value = Wash.system.brightness - 1;

			case NotificationLevel:
				nfySlider.value = Wash.system.notifyLevel - 1;

			case Time:
				var now = Watch.rtc.get_localtime();
				HH.value = now.HH;
				MM.value = now.MM;
				draw.set_font(Fonts.sans28);
				draw.string(':', 110, 120-14, 20);
				HH.draw();
				MM.draw();

			case Date:
				var now = Watch.rtc.get_localtime();
				yy.value = now.yyyy - 2000;
				mm.value = now.mm;
				dd.value = now.dd;
				yy.draw();
				mm.draw();
				dd.draw();
				draw.set_font(Fonts.sans24);
				draw.string('DD    MM    YY', 0, 180, 240);

			case Theme:
				switch (themeColor) {
					case 0:
						draw.fill(Wash.system.theme.ui, 55, 35, 40, 40);
						draw.fill(Wash.system.theme.mid, 100, 35, 40, 40);
						draw.fill(Wash.system.theme.bright, 145, 35, 40, 40);
						uiButton.draw();
						midButton.draw();
						brightButton.draw();

					case 1: uiColorPicker.draw();
					case 2: midColorPicker.draw();
					case 3: brightColorPicker.draw();
				}

			case Units:
				unitsToggle.draw();
		}

		update();
		Watch.display.mute(false);
	}

	function update():Void {
		var draw = Watch.drawable;
		draw.set_color(Wash.system.theme.bright);

		switch (currentSetting) {
			case Brightness:
				var say = switch (Wash.system.brightness) {
					case 3: "High";
					case 2: "Mid";
					case _: "Low";
				};

				slider.update();
				draw.string(say, 0, 150, 240);

			case NotificationLevel:
				var say = switch (Wash.system.notifyLevel) {
					case 3: "High";
					case 2: "Mid";
					case _: "Silent";
				};

				nfySlider.update();
				draw.string(say, 0, 150, 240);

			case Units:
				draw.string(Wash.system.units, 0, 150, 240);

			case Date | Time | Theme:
		}

		scroll.value = settingsIndex;
		scroll.draw();
	}
}
