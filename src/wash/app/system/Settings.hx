package wash.app.system;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.construct;

import wasp.Fonts;
import wasp.Watch;
import wash.app.IApplication.ISettingsApplication;
import wash.app.system.settings.AppConfig;
import wash.app.system.settings.BrightnessConfig;
import wash.app.system.settings.DateConfig;
import wash.app.system.settings.NotificationLevelConfig;
import wash.app.system.settings.ThemeConfig;
import wash.app.system.settings.TimeConfig;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.ScrollIndicator;

using python.NativeArrayTools;

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

	static var systemSettings:Array<AppConfig> = [
		AppConfig.make("Brightness", BrightnessConfig),
		AppConfig.make("Notification Level", NotificationLevelConfig),
		AppConfig.make("Time", TimeConfig),
		AppConfig.make("Date", DateConfig),
		AppConfig.make("Theme", ThemeConfig),
	];

	static var applicationSettings:Array<AppConfig> = [];

	public static function registerApp(appName:String, configApp:Class<ISettingsApplication>):Void {
		applicationSettings.push(AppConfig.make(appName, configApp));
		applicationSettings.nativeSort(appConfigSort);
	}

	public static function unregisterApp(appName:String):Void {
		applicationSettings = applicationSettings.filter(a -> a.appName != appName);
	}

	var scroll:ScrollIndicator;
	var settingsIndex(default, set):Int;
	var currentSettingsApp:Null<ISettingsApplication>;

	public function new() {
		NAME = "Settings";
		ICON = icon;

		settingsIndex = 0;
		scroll = new ScrollIndicator(
			null,
			0,
			systemSettings.length + applicationSettings.length - 1,
			settingsIndex
		);
	}

	function set_settingsIndex(value:Int):Int {
		settingsIndex = value;

		if (settingsIndex < 0)
			settingsIndex = systemSettings.length + applicationSettings.length - 1;
		else if (settingsIndex >= systemSettings.length + applicationSettings.length)
			settingsIndex = 0;

		if (currentSettingsApp != null) {
			// TODO: some cleanup?
			currentSettingsApp = null;
		}

		var target = (settingsIndex < systemSettings.length)
			? systemSettings[settingsIndex].settingsCls
			: applicationSettings[settingsIndex - systemSettings.length].settingsCls;

		currentSettingsApp = construct(target, this);

		return value;
	}

	override public function foreground():Void {
		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN | EventMask.SWIPE_LEFTRIGHT);
	}

	override public function swipe(event:TouchEvent):Bool {
		if (currentSettingsApp != null) {
			if (!currentSettingsApp.swipe(event)) return false;
		}

		switch (event.type) {
			case UP:
				settingsIndex++;
				draw();

			case DOWN:
				settingsIndex--;
				draw();

			case LEFT | RIGHT:
				return true;

			case _:
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		if (currentSettingsApp != null) currentSettingsApp.touch(event);
		update();
	}

	public function draw():Void {
		var draw = Watch.drawable;
		Watch.display.mute(true);

		draw.fill(0);

		if (currentSettingsApp != null) {
			draw.set_color(Wash.system.theme.highlight);
			draw.set_font(Fonts.sans24);
			draw.string(currentSettingsApp.NAME, 0, 6, 240);
			currentSettingsApp.draw();
		}

		update();
		Watch.display.mute(false);
	}

	function update():Void {
		if (currentSettingsApp != null) currentSettingsApp.update();
		scroll.value = settingsIndex;
		scroll.draw();
	}

	static function appConfigSort(appConfig:AppConfig):String return appConfig.appName;
}
