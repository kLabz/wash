package wash.app.system;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.construct;

import wasp.Fonts;
import wasp.Watch;
import wash.app.IApplication.ISettingsApplication;
import wash.app.system.settings.AppConfig;
import wash.app.system.settings.DateTimeConfig;
import wash.app.system.settings.SystemConfig;
import wash.app.system.settings.ThemeConfig;
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

	// System configuration
	public static var notificationLevel:NotificationLevel = Mid;
	public static var brightnessLevel:BrightnessLevel = Mid;
	public static var wakeMode:WakeMode = Button;

	static var settingsListChanged:Bool = false;
	static var systemSettings:Array<AppConfig> = [
		AppConfig.make("System", SystemConfig),
		AppConfig.make("Date/Time", DateTimeConfig),
		AppConfig.make("Theme", ThemeConfig)
	];

	static var applicationSettings:Array<AppConfig> = [];

	public static function registerApp(appName:String, configApp:Class<ISettingsApplication>):Void {
		applicationSettings.push(AppConfig.make(appName, configApp));
		applicationSettings.nativeSort(appConfigSort);
		settingsListChanged = true;
	}

	public static function unregisterApp(appName:String):Void {
		applicationSettings = applicationSettings.filter(a -> a.appName != appName);
		settingsListChanged = true;
	}

	var scroll:ScrollIndicator;
	var settingsPage:Int;
	var settingsPages:Int;
	var currentSettingsApp:Null<ISettingsApplication>;

	public function new() {
		super();
		NAME = "Settings";
		ICON = icon;

		settingsPage = 0;
		var nbButtons = systemSettings.length + applicationSettings.length;
		settingsPages = 1 + opCeilDiv(applicationSettings.length, 5);
		scroll = new ScrollIndicator(42, 0, settingsPages - 1, settingsPage);
	}

	override public function foreground():Void {
		settingsPage = 0;
		currentSettingsApp = null;
		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN | EventMask.SWIPE_LEFTRIGHT);
	}

	override public function swipe(event:TouchEvent):Bool {
		if (currentSettingsApp != null) {
			if (!currentSettingsApp.swipe(event)) return false;

			switch (event.type) {
				case LEFT | RIGHT:
					currentSettingsApp = null;
					draw();

				case _:
			}
		} else {
			switch (event.type) {
				case UP if (settingsPage < settingsPages - 1):
					settingsPage++;
					draw();

				case DOWN if (settingsPage > 0):
					settingsPage--;
					draw();

				case LEFT | RIGHT:
					return true;

				case _:
			}
		}


		return false;
	}

	override public function touch(event:TouchEvent):Void {
		if (currentSettingsApp != null) {
			currentSettingsApp.touch(event);
		} else {
			var index = opFloorDiv(event.y - 40, 40);

			switch (settingsPage) {
				case 0:
					if (index < 3) setApp(systemSettings[index]);

				case _:
					index += (settingsPage - 1) * 5;
					if (index < applicationSettings.length)
						setApp(applicationSettings[index]);
			}

		}

		update();
	}

	function setApp(app:AppConfig):Void {
		currentSettingsApp = construct(app.settingsCls, this);
		draw();
	}

	public function draw():Void {
		var draw = Watch.drawable;
		Watch.display.mute(true);

		if (settingsListChanged) {
			settingsPages = 1 + opCeilDiv(applicationSettings.length, 5);
			scroll.max = settingsPages - 1;
			settingsListChanged = false;
		}

		draw.fill(0);

		if (currentSettingsApp != null) {
			currentSettingsApp.draw();
		} else {
			Watch.display.mute(true);
			draw.fill(0);

			draw.set_color(Wash.system.theme.highlight);
			draw.set_font(Fonts.sans24);
			draw.string(switch (settingsPage) {
				case 0: "Watch Settings";
				case _: "App Settings";
			}, 0, 6, 240);

			draw.set_color(0, Wash.system.theme.primary);
			draw.set_font(Fonts.sans24);

			for (i in 0...5) {
				var index = settingsPage == 0 ? i : (settingsPage - 1) * 5 + i;
				if (index >= (settingsPage == 0 ? systemSettings : applicationSettings).length) break;
				var target = settingsPage == 0 ? systemSettings[index] : applicationSettings[index];

				draw.fill(Wash.system.theme.primary, 12, (i + 1) * 40 + 2, 216, 36);
				draw.string(target.appName, 12, (i + 1) * 40 + 7, 216);
			}
		}

		update();
		Watch.display.mute(false);
	}

	function update():Void {
		if (currentSettingsApp != null) {
			currentSettingsApp.update();
		} else {
			scroll.value = settingsPage;
			scroll.draw();
		}
	}

	static function appConfigSort(appConfig:AppConfig):String return appConfig.appName;
}
