package wash.app.system;

import python.Bytearray;
import python.Bytes;
import python.Syntax;
import python.Syntax.bytes;
// import python.Syntax.sub;

import wash.app.user.AlarmApp.AlarmDef;
import wash.util.Int2;

using python.NativeStringTools;

class DataVault {
	public static function serialize():Bytearray {
		var ret = new Bytearray();

		// Quick Ring
		ret.append(SettingsCategory.SC_RootSettings);
		ret.append(RootSettings.QuickRing);
		for (app in Wash.system.quickRing) {
			if (app.ID == null) {
				trace(app.NAME);
				continue;
			}
			ret.append(app.ID);
		}
		ret.append(0x00);

		// Enabled apps
		ret.append(RootSettings.EnabledApps);
		for (app in Wash.system.launcherRing) {
			if (app.ID == null) {
				trace(app.NAME);
				continue;
			}
			ret.append(app.ID);
		}
		ret.append(0x00);

		// Alarms
		var alarms = @:privateAccess wash.app.user.AlarmApp.alarms;
		if (alarms != null) {
			ret.append(RootSettings.Alarms);
			for (a in alarms) ret.extend(a);
			ret.append(0x00);

			alarms = null;
			Syntax.delete(alarms);
		}
		ret.append(0x00);

		// System settings
		ret.append(SettingsCategory.SC_SystemSettings);
		ret.append(SystemSettings.NotifLevel);
		ret.append(Settings.notificationLevel);
		ret.append(SystemSettings.BrightnessLevel);
		ret.append(Settings.brightnessLevel);
		ret.append(SystemSettings.WakeMode);
		ret.append(Settings.wakeMode);
		ret.append(SystemSettings.Theme);
		ret.append(Wash.system.theme.primary_theme._1);
		ret.append(Wash.system.theme.primary_theme._2);
		ret.append(Wash.system.theme.secondary_theme._1);
		ret.append(Wash.system.theme.secondary_theme._2);
		ret.append(Wash.system.theme.highlight_theme._1);
		ret.append(Wash.system.theme.highlight_theme._2);
		ret.append(0x00);

		// TODO: Apps settings

		return ret;
	}

	// TODO: remove or hide behind a compilation flag
	public static function testDeserialize():Void {
		var b = bytes('\\x01\\x01\\xaa\\x04\\x08\\x00\\x02\\x01\\x02\\x03\\x05\\x06\\x07\\x00\\x03\\x06\\x1e\\x9f\\x07-\\xe0\\x08\\x00\\x00\\x08\\x00\\x00\\x00\\x00\\x02\\x01\\x02\\x02\\x02\\x03\\x05\\x04\\xfb\\x80\\xfe \\xff\\xff\\x00');
		deserialize(b);
	}


	public static function deserialize(bytes:Bytes):Void {
		var i = 0;

		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case SC_RootSettings:
					i = deserializeRootSettings(bytes, i);

				case SC_SystemSettings:
					i = deserializeSystemSettings(bytes, i);

				case SC_AppSettings:
					trace('TODO: App settings');
					break;
			}
		}

		trace('Done.');
	}

	static function deserializeRootSettings(bytes:Bytes, i:Int):Int {
		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case QuickRing:
					var apps:Array<Class<IApplication>> = [];
					i = getApps(bytes, i, apps);

					if (apps.length > 0) {
						@:privateAccess Wash.system.quickRing = [];
						for (a in apps) Wash.system.register(a, true);
					}

					apps = null;
					Syntax.delete(apps);

				case EnabledApps:
					var apps:Array<Class<IApplication>> = [];
					i = getApps(bytes, i, apps);

					if (apps.length > 0) {
						for (a in apps) Wash.system.register(a, false);
					}

					apps = null;
					Syntax.delete(apps);

				case Alarms:
					var alarms:Array<AlarmDef> = [];
					while (i < bytes.length) {
						switch (bytes.get(i)) {
							case 0x00:
								i++;
								break;

							case _:
								alarms.push(AlarmDef.make(bytes[i], bytes[i+1], bytes[i+2]));
								i += 3;
						}
					}

					if (alarms.length > 0) wash.app.user.AlarmApp.init(alarms);
					alarms = null;
					Syntax.delete(alarms);

				case 0x00:
					break;
			}
		}

		return i;
	}

	static function deserializeSystemSettings(bytes:Bytes, i:Int):Int {
		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case NotifLevel:
					Settings.notificationLevel = cast bytes.get(i++);
					if (!Wash.system.nightMode) Wash.system.notificationLevel = Settings.notificationLevel;

				case BrightnessLevel:
					Settings.brightnessLevel = cast bytes.get(i++);
					if (!Wash.system.nightMode) Wash.system.brightnessLevel = Settings.brightnessLevel;

				case WakeMode:
					Settings.wakeMode = bytes.get(i++);
					if (!Wash.system.nightMode) Wash.system.wakeMode = Settings.wakeMode;

				case Theme:
					Wash.system.theme.primary = Int2.fromBytes(bytes.get(i++), bytes.get(i++));
					Wash.system.theme.secondary = Int2.fromBytes(bytes.get(i++), bytes.get(i++));
					Wash.system.theme.highlight = Int2.fromBytes(bytes.get(i++), bytes.get(i++));

				case 0x00:
					break;
			}
		}

		return i;
	}

	static function getApps(bytes:Bytes, i:Int, apps:Array<Class<IApplication>>):Int {
		while (i < bytes.length) {
			switch (bytes.get(i)) {
				case 0x00:
					i++;
					break;

				case cls:
					apps.push(AppIdentifier.toCls(cls));
					i++;
			}
		}

		return i;
	}
}

enum abstract SettingsCategory(Int) to Int {
	var SC_RootSettings = 0x01;
	var SC_SystemSettings = 0x02;
	var SC_AppSettings = 0x03;
}

enum abstract RootSettings(Int) to Int {
	var QuickRing = 0x01;
	var EnabledApps = 0x02;
	var Alarms = 0x03;
}

enum abstract SystemSettings(Int) to Int {
	var NotifLevel = 0x01;
	var BrightnessLevel = 0x02;
	var WakeMode = 0x03;
	var Theme = 0x04;
}

class AppIdentifier {
	// TODO: macro to keep in sync with IApplication.ID
	public static function toCls(cls:Int):Class<IApplication> {
		return switch (cls) {
			case 0x01: wash.app.user.AlarmApp;
			case 0x02: wash.app.user.Calc;
			case 0x03: wash.app.user.HeartApp;
			case 0x04: wash.app.user.NightMode;
			case 0x05: wash.app.user.StepCounter;
			case 0x06: wash.app.user.Stopclock;
			case 0x07: wash.app.user.Timer;
			case 0x08: wash.app.user.Torch;

			// Watchfaces
			case 0xAA: wash.app.watchface.BatTri;

			case _:
				trace('Unknown app');
				trace(cls);
				wash.app.BaseApplication;
		}
	}
}
