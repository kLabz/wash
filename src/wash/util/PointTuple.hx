package wash.util;

import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class PointTuple extends Tuple<Dynamic> {
	static inline function make(x:Int, y:Int):PointTuple
		return Syntax.tuple(x, y);

	var x(get, null):Int;
	inline function get_x():Int return this[0];

	var y(get, null):Int;
	inline function get_y():Int return this[1];
}
