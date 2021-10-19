package wash.app.system;

import python.Bytes;
import python.Syntax.bytes;

import wasp.Fonts;
import wasp.Watch;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.util.TimeTuple;
import wash.widgets.Button;
import wash.widgets.ScrollIndicator;
import wash.widgets.Slider;
import wash.widgets.Spinner;

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
	var settings:Array<String>;
	var settingsIndex:Int; // TODO: enum abstract
	var currentSetting:String;

	public function new() {
		NAME = "Settings";
		ICON = icon;

		scroll = new ScrollIndicator();
		slider = new Slider(3, 10, 90);
		nfySlider = new Slider(3, 10, 90);
		HH = new Spinner(50, 60, 0, 23, 2);
		MM = new Spinner(130, 60, 0, 59, 2);
		dd = new Spinner(20, 60, 1, 31, 1);
		mm = new Spinner(90, 60, 1, 12, 1);
		yy = new Spinner(160, 60, 21, 60, 2);
		units = ["Metric", "Imperial"];
		unitsToggle = new Button(32, 90, 176, 48, "Change");
		settings = ["Brightness", "Notification Level", "Time", "Date", "Units"];
		settingsIndex = 0;
		currentSetting = settings[settingsIndex];
	}

	override public function foreground():Void {
		slider.value = Wash.system.brightness - 1;
		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN);
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case UP:
				// TODO: move to settingsIndex setter?
				settingsIndex++;
				if (settingsIndex >= settings.length) settingsIndex = 0;
				currentSetting = settings[settingsIndex];
				draw();

			case DOWN:
				// TODO: move to settingsIndex setter?
				settingsIndex--;
				if (settingsIndex < 0) settingsIndex = settings.length - 1;
				currentSetting = settings[settingsIndex];
				draw();

			case _:
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		switch (settingsIndex) {
			case 0: // Brightness
				slider.touch(event);
				Wash.system.brightness = slider.value + 1;

			case 1: // Notification Level
				nfySlider.touch(event);
				Wash.system.notifyLevel = nfySlider.value + 1;

			case 2: // Time
				if (HH.touch(event) || MM.touch(event)) {
					var now = Watch.rtc.get_localtime();
					Watch.rtc.set_localtime(TimeTuple.make(now.yyyy, now.mm, now.dd, HH.value, MM.value, 0, now.wday, now.yday));
				}

			case 3: // Date
				if (dd.touch(event) || mm.touch(event) || yy.touch(event)) {
					var now = Watch.rtc.get_localtime();
					Watch.rtc.set_localtime(TimeTuple.make(yy.value + 2000, mm.value, dd.value, now.HH, now.MM, now.SS, now.wday, now.yday));
				}

			case 4: // Units
				if (unitsToggle.touch(event)) {
					var index = (units.indexOf(Wash.system.units) + 1) % units.length;
					Wash.system.units = units[index];
				}

			case _:
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

		switch (settingsIndex) {
			case 0: // Brightness
				slider.value = Wash.system.brightness - 1;

			case 1: // Notification Level
				nfySlider.value = Wash.system.notifyLevel - 1;

			case 2: // Time
				var now = Watch.rtc.get_localtime();
				HH.value = now.HH;
				MM.value = now.MM;
				draw.set_font(Fonts.sans28);
				draw.string(':', 110, 120-14, 20);
				HH.draw();
				MM.draw();

			case 3: // Date
				var now = Watch.rtc.get_localtime();
				yy.value = now.yyyy - 2000;
				mm.value = now.mm;
				dd.value = now.dd;
				yy.draw();
				mm.draw();
				dd.draw();
				draw.set_font(Fonts.sans24);
				draw.string('DD    MM    YY', 0, 180, 240);

			case 4: // Units
				unitsToggle.draw();

			case _:
		}

		scroll.draw();
		update();
		Watch.display.mute(false);
	}

	function update():Void {
		var draw = Watch.drawable;
		draw.set_color(Wash.system.theme.bright);

		switch (settingsIndex) {
			case 0: // Brightness
				var say = switch (Wash.system.brightness) {
					case 3: "High";
					case 2: "Mid";
					case _: "Low";
				};

				slider.update();
				draw.string(say, 0, 150, 240);

			case 1: // Notification Level
				var say = switch (Wash.system.notifyLevel) {
					case 3: "High";
					case 2: "Mid";
					case _: "Silent";
				};

				nfySlider.update();
				draw.string(say, 0, 150, 240);

			case 4: // Units
				draw.string(Wash.system.units, 0, 150, 240);

			case _:
		}
	}
}
