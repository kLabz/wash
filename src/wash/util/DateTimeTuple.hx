package wash.util;

import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class DateTimeTuple extends Tuple<Dynamic> {
	static inline function make(
		yyyy:Int, mm:Int, dd:Int, HH:Int, MM:Int, SS:Int, wday:Int, yday:Int
	):DateTimeTuple
		return Syntax.tuple(yyyy, mm, dd, HH, MM, SS, wday, yday, 0);

	var yyyy(get, null):Int;
	inline function get_yyyy():Int return this[0];

	var mm(get, null):Int;
	inline function get_mm():Int return this[1];

	var dd(get, null):Int;
	inline function get_dd():Int return this[2];

	var HH(get, null):Int;
	inline function get_HH():Int return this[3];

	var MM(get, null):Int;
	inline function get_MM():Int return this[4];

	var SS(get, null):Int;
	inline function get_SS():Int return this[5];

	var wday(get, null):Int;
	inline function get_wday():Int return this[6];

	var yday(get, null):Int;
	inline function get_yday():Int return this[7];
}
