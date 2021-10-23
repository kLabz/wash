package wash;

import python.Bytearray;

abstract Theme(Bytearray) from Bytearray {
	public var ble(get, never):Int;
	inline function get_ble():Int return get(0);

	public var scrollIndicator(get, never):Int;
	inline function get_scrollIndicator():Int return get(1);

	public var battery(get, never):Int;
	inline function get_battery():Int return get(2);

	public var statusClock(get, never):Int;
	inline function get_statusClock():Int return get(3);

	public var notifyIcon(get, never):Int;
	inline function get_notifyIcon():Int return get(4);

	public var bright(get, set):Int;
	inline function get_bright():Int return get(5);
	inline function set_bright(value:Int):Int return setColor(5, value);

	public var mid(get, set):Int;
	inline function get_mid():Int return get(6);
	inline function set_mid(value:Int):Int return setColor(6, value);

	public var ui(get, set):Int;
	inline function get_ui():Int return get(7);
	inline function set_ui(value:Int):Int return setColor(7, value);

	// TODO: remove
	public var spot1(get, never):Int;
	inline function get_spot1():Int return get(8);

	// TODO: remove
	public var spot2(get, never):Int;
	inline function get_spot2():Int return get(9);

	// TODO: remove (still used by Checkbox before redesign)
	public var contrast(get, never):Int;
	inline function get_contrast():Int return get(10);

	function get(index:Int):Int {
		return this[index * 2] << 8 | this[index * 2 + 1];
	}

	function setColor(index:Int, value:Int):Int {
		this[index * 2] = value >> 8;
		this[index * 2 + 1] = value - ((value >> 8) << 8);
		return value;
	}
}
