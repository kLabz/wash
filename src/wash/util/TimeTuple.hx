package wash.util;

import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class TimeTuple extends Tuple<Dynamic> {
	static inline function make(HH:Int, MM:Int, SS:Int):TimeTuple
		return Syntax.tuple(HH, MM, SS);

	var HH(get, null):Int;
	inline function get_HH():Int return this[0];

	var MM(get, null):Int;
	inline function get_MM():Int return this[1];

	var SS(get, null):Int;
	inline function get_SS():Int return this[2];
}
