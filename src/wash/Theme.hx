package wash;

import python.Bytearray;

abstract Theme(Bytearray) from Bytearray {
	public var primary(get, set):Int;
	inline function get_primary():Int return Wash.system.nightMode ? primary_night : get(0);
	inline function set_primary(value:Int):Int return setColor(0, value);

	public var secondary(get, set):Int;
	inline function get_secondary():Int return Wash.system.nightMode ? secondary_night : get(1);
	inline function set_secondary(value:Int):Int return setColor(1, value);

	public var highlight(get, set):Int;
	inline function get_highlight():Int return Wash.system.nightMode ? highlight_night : get(2);
	inline function set_highlight(value:Int):Int return setColor(2, value);

	public var shadow(get, set):Int;
	inline function get_shadow():Int return get(3);
	inline function set_shadow(value:Int):Int return setColor(3, value);

	public var primary_night(get, never):Int;
	inline function get_primary_night():Int return get(4);

	public var secondary_night(get, never):Int;
	inline function get_secondary_night():Int return get(5);

	public var highlight_night(get, never):Int;
	inline function get_highlight_night():Int return get(6);

	function get(index:Int):Int {
		return this[index * 2] << 8 | this[index * 2 + 1];
	}

	function setColor(index:Int, value:Int):Int {
		this[index * 2] = value >> 8;
		this[index * 2 + 1] = value - ((value >> 8) << 8);
		return value;
	}
}
