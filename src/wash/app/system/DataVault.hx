package wash.app.system;

import python.Bytearray;
import python.Bytes;
import python.Syntax;
import python.Syntax.bytes;
import python.Tuple;
// import python.Syntax.sub;

import wasp.Builtins;
import wash.app.user.AlarmApp.AlarmDef;
import wash.app.system.settings.SystemConfig;

using python.NativeStringTools;

@:native('DataVault')
class DataVault {
	static var appConfigSerializers:Array<AppConfigSerializer> = [];

	public static function save():Void {
		var f = Builtins.openWrite('.settings');
		f.write(serialize());
		f.close();
	}

	public static function load():Void {
		try {
			var f = Builtins.openRead('.settings');
			var b = f.peek();
			deserialize(b);
		} catch (_) {}
	}

	public static function registerAppConfig(
		appName:String,
		appId:Int,
		serializer:Bytearray->Void,
		deserializer:(bytes:Bytes, i:Int)->Int
	):Void {
		unregisterAppConfig(appName);
		appConfigSerializers.push(AppConfigSerializer.make(
			appName,
			appId,
			serializer,
			deserializer
		));
	}

	public static function unregisterAppConfig(appName:String):Void {
		appConfigSerializers = Lambda.filter(appConfigSerializers, a -> a.appName != appName);
	}

	static function serialize():Bytearray {
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
		SystemConfig.serialize(ret);
		ret.append(0x00);

		// Apps settings
		ret.append(SettingsCategory.SC_AppSettings);
		for (a in appConfigSerializers) {
			ret.append(a.appId);
			a.serializer(ret);
			ret.append(0x00);
		}
		ret.append(0x00);

		return ret;
	}

	static function deserialize(bytes:Bytes):Void {
		var i = 0;

		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case SC_RootSettings:
					i = deserializeRootSettings(bytes, i);

				case SC_SystemSettings:
					i = SystemConfig.deserialize(bytes, i);

				case SC_AppSettings:
					i = deserializeAppSettings(bytes, i);
			}
		}
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

	static function deserializeAppSettings(bytes:Bytes, i:Int):Int {
		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case 0x00:
					break;

				case id:
					var appCS = Lambda.find(appConfigSerializers, a -> a.appId == id);
					if (appCS == null) {
						trace('Cannot deserialize app config for id $id');
						while (bytes.get(i++) != 0x00) continue;
						break;
					} else {
						i = appCS.deserializer(bytes, i);
					}
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

@:native("tuple")
extern class AppConfigSerializer extends Tuple<Dynamic> {
	static inline function make(
		appName:String,
		appId:Int,
		serializer:Bytearray->Void,
		deserializer:(bytes:Bytes, i:Int)->Int
	):AppConfigSerializer
		return Syntax.tuple(appName, appId, serializer, deserializer);

	var appName(get, null):String;
	inline function get_appName():String return this[0];

	var appId(get, null):Int;
	inline function get_appId():Int return this[1];

	var serializer(get, null):Bytearray->Void;
	inline function get_serializer():Bytearray->Void return this[2];

	var deserializer(get, null):Bytes->Int->Int;
	inline function get_deserializer():Bytes->Int->Int return this[3];
}
