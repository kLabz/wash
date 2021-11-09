package wash.app.system.settings;

import python.Syntax;
import python.Tuple;

import wash.app.ISettingsApplication;

@:native("tuple")
extern class AppConfig extends Tuple<Dynamic> {
	static inline function make(appName:String, settingsCls:Class<ISettingsApplication>):AppConfig
		return Syntax.tuple(appName, settingsCls);

	var appName(get, null):String;
	inline function get_appName():String return this[0];

	var settingsCls(get, null):Class<ISettingsApplication>;
	inline function get_settingsCls():Class<ISettingsApplication> return this[1];
}
