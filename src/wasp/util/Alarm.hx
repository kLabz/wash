package wasp.util;

import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class Alarm extends Tuple<Dynamic> {
	static inline function make(time:Int, cb:Void->Void):Alarm
		return Syntax.tuple(time, cb);

	var time(get, null):Int;
	inline function get_time():Int return this[0];

	var cb(get, null):Void->Void;
	inline function get_cb():Void->Void return this[1];
}
