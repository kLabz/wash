package wash.app.system;

import python.Bytearray;
import python.Syntax;
import python.Tuple;
import python.lib.io.BufferedReader;
import python.lib.io.BufferedWriter;

import wasp.Builtins;
import wash.app.user.AlarmApp.AlarmDef;
import wash.app.system.settings.SystemConfig;

using python.NativeStringTools;
using wash.app.system.DataVault;

@:native('DataVault')
class DataVault {
	static inline var CONFIG_FILE:String = 'haxetime.conf';
	static var appConfigSerializers:Array<AppConfigSerializer> = [];

	public static function save():Void {
		var f = Builtins.openWrite(CONFIG_FILE);
		serialize(f);
		f.close();
		f = null;
		Syntax.delete(f);
	}

	public static function load():Void {
		try {
			var f = Builtins.openRead(CONFIG_FILE);
			deserialize(f);
			f.close();
			f = null;
			Syntax.delete(f);
		} catch (_) {}
	}

	public static function registerAppConfig(
		appName:String,
		appId:Int,
		serializer:BufferedWriter->Void,
		deserializer:BufferedReader->Void
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

	static function serialize(f:BufferedWriter):Void {
		// Quick Ring
		f.write1(SettingsCategory.SC_RootSettings);
		f.write1(RootSettings.QuickRing);
		for (app in Wash.system.quickRing) {
			if (app.ID == null) {
				trace('(QuickRing) Null appId for:');
				trace(app.NAME);
				continue;
			}
			f.write1(app.ID);
		}
		f.write1(0x00);

		// Enabled apps
		f.write1(RootSettings.EnabledApps);
		for (app in Wash.system.launcherRing) {
			if (app.ID == null) {
				trace('(Launcher) Null appId for:');
				trace(app.NAME);
				continue;
			}
			f.write1(app.ID);
		}
		f.write1(0x00);

		// Alarms
		var alarms = @:privateAccess wash.app.user.AlarmApp.alarms;
		if (alarms != null) {
			f.write1(RootSettings.Alarms);
			for (a in alarms) f.write(a);
			f.write1(0x00);

			alarms = null;
			Syntax.delete(alarms);
		}
		f.write1(0x00);

		// System settings
		f.write1(SettingsCategory.SC_SystemSettings);
		SystemConfig.serialize(f);
		f.write1(0x00);

		// Apps settings
		f.write1(SettingsCategory.SC_AppSettings);
		for (a in appConfigSerializers) {
			f.write1(a.appId);
			a.serializer(f);
			f.write1(0x00);
		}
		f.write1(0x00);
	}

	static function deserialize(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case SC_RootSettings:
					deserializeRootSettings(f);

				case SC_SystemSettings:
					SystemConfig.deserialize(f);

				case SC_AppSettings:
					deserializeAppSettings(f);
			}
		}
	}

	public static function write1(f:BufferedWriter, b:Int):Void {
		var bytes = new Bytearray(1);
		bytes.set(0, b);
		f.write(bytes);
		bytes = null;
		Syntax.delete(bytes);
	}

	static function deserializeRootSettings(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case QuickRing:
					var apps:Array<Class<IApplication>> = [];
					getApps(f, apps);

					if (apps.length > 0) {
						@:privateAccess Wash.system.quickRing = [];
						for (a in apps) Wash.system.register(a, true);
					}

					apps = null;
					Syntax.delete(apps);

				case EnabledApps:
					var apps:Array<Class<IApplication>> = [];
					getApps(f, apps);

					if (apps.length > 0) {
						for (a in apps) Wash.system.register(a, false);
					}

					apps = null;
					Syntax.delete(apps);

				case Alarms:
					var alarms:Array<AlarmDef> = [];

					while (true) {
						switch (f.read(1).get(0)) {
							case 0x00:
								break;

							case v:
								var alarmData = f.read(2);
								alarms.push(AlarmDef.make(v, alarmData.get(0), alarmData.get(1)));
								alarmData = null;
								Syntax.delete(alarmData);
						}
					}

					if (alarms.length > 0) wash.app.user.AlarmApp.init(alarms);
					alarms = null;
					Syntax.delete(alarms);

				case 0x00:
					break;
			}
		}
	}

	static function deserializeAppSettings(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case 0x00:
					break;

				case id:
					var appCS = Lambda.find(appConfigSerializers, a -> a.appId == id);
					if (appCS == null) {
						trace('Cannot deserialize app config for id $id');
						while (f.read(1).get(0) != 0x00) continue;
						break;
					} else {
						appCS.deserializer(f);
					}
			}
		}
	}

	static function getApps(f:BufferedReader, apps:Array<Class<IApplication>>):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case 0x00:
					break;

				case cls:
					apps.push(AppIdentifier.toCls(cls));
			}
		}
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
		serializer:BufferedWriter->Void,
		deserializer:BufferedReader->Void
	):AppConfigSerializer
		return Syntax.tuple(appName, appId, serializer, deserializer);

	var appName(get, null):String;
	inline function get_appName():String return this[0];

	var appId(get, null):Int;
	inline function get_appId():Int return this[1];

	var serializer(get, null):BufferedWriter->Void;
	inline function get_serializer():BufferedWriter->Void return this[2];

	var deserializer(get, null):BufferedReader->Void;
	inline function get_deserializer():BufferedReader->Void return this[3];
}
