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

	public var bright(get, never):Int;
	inline function get_bright():Int return get(5);

	public var mid(get, never):Int;
	inline function get_mid():Int return get(6);

	public var ui(get, never):Int;
	inline function get_ui():Int return get(7);

	public var spot1(get, never):Int;
	inline function get_spot1():Int return get(8);

	public var spot2(get, never):Int;
	inline function get_spot2():Int return get(9);

	public var contrast(get, never):Int;
	inline function get_contrast():Int return get(10);

	function get(index:Int):Int {
		return this[(index * 2)] << 8 | this[index * 2 + 1];
	}
}
