package wash.app.system.settings;

import python.Syntax;
import python.Tuple;

import wash.app.ISettingsApplication;

@:native("tuple")
extern class AppConfig extends Tuple<Dynamic> {
	static inline function make(
		appName:String,
		settingsCls:String,
		settingsModule:String
	):AppConfig
		return Syntax.tuple(appName, settingsCls, settingsModule);

	var appName(get, null):String;
	inline function get_appName():String return this[0];

	var settingsCls(get, null):String;
	inline function get_settingsCls():String return this[1];

	var settingsModule(get, null):String;
	inline function get_settingsModule():String return this[2];
}
