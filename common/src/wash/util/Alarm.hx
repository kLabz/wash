package wash.util;

import python.Syntax.tuple;
import python.Tuple;

@:native("tuple")
extern class Alarm extends Tuple<Dynamic> {
	static inline function make(time:Float, cb:Void->Void):Alarm
		return tuple(time, cb);

	var time(get, null):Float;
	inline function get_time():Float return this[0];

	var cb(get, null):Void->Void;
	inline function get_cb():Void->Void return this[1];
}
