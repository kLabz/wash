package wasp.event;

import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class TouchEvent extends Tuple<Dynamic> {
	// TODO: check what first element is and if there are more
	static inline function make(_:Any, x:Int, y:Int):TouchEvent
		return Syntax.tuple(null, x, y);

	var x(get, null):Int;
	inline function get_x():Int return this[1];

	var y(get, null):Int;
	inline function get_y():Int return this[2];
}
