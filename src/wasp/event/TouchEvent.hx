package wasp.event;

import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class TouchEvent extends Tuple<Dynamic> {
	static inline function make(eventType:EventType, x:Int, y:Int):TouchEvent
		return Syntax.tuple(null, x, y);

	var type(get, set):EventType;
	inline function get_type():EventType return this[0];
	inline function set_type(t:EventType):EventType return this[0] = t;

	var x(get, null):Int;
	inline function get_x():Int return this[1];

	var y(get, null):Int;
	inline function get_y():Int return this[2];
}
