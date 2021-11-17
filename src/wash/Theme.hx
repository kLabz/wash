package wash;

import python.Bytearray;

import wash.util.Int16;

@:native('Theme')
abstract Theme(Bytearray) from Bytearray {
	public var primary(get, set):Int16;
	inline function get_primary():Int16 return Wash.system.nightMode ? primary_night : get(0);
	inline function set_primary(value:Int16):Int16 return setColor(0, value);

	public var secondary(get, set):Int16;
	inline function get_secondary():Int16 return Wash.system.nightMode ? secondary_night : get(1);
	inline function set_secondary(value:Int16):Int16 return setColor(1, value);

	public var highlight(get, set):Int16;
	inline function get_highlight():Int16 return Wash.system.nightMode ? highlight_night : get(2);
	inline function set_highlight(value:Int16):Int16 return setColor(2, value);

	public var shadow(get, set):Int16;
	inline function get_shadow():Int16 return get(3);
	inline function set_shadow(value:Int16):Int16 return setColor(3, value);

	public var primary_theme(get, never):Int16;
	inline function get_primary_theme():Int16 return get(0);

	public var secondary_theme(get, never):Int16;
	inline function get_secondary_theme():Int16 return get(1);

	public var highlight_theme(get, never):Int16;
	inline function get_highlight_theme():Int16 return get(2);

	public var primary_night(get, never):Int16;
	inline function get_primary_night():Int16 return get(4);

	public var secondary_night(get, never):Int16;
	inline function get_secondary_night():Int16 return get(5);

	public var highlight_night(get, never):Int16;
	inline function get_highlight_night():Int16 return get(6);

	function get(index:Int):Int16 {
		return this[index * 2] << 8 | this[index * 2 + 1];
	}

	function setColor(index:Int, value:Int16):Int16 {
		this[index * 2] = value >> 8;
		this[index * 2 + 1] = value - ((value >> 8) << 8);
		return value;
	}
}
