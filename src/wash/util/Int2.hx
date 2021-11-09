package wash.util;

abstract Int2(Int) from Int to Int {
	public var _1(get,never):Int;
	function get__1():Int return this >> 8;

	public var _2(get,never):Int;
	function get__2():Int return this - (_1 << 8);

	public static function fromBytes(b1:Int, b2:Int):Int2 {
		return (b1 << 8 | b2 :Int2);
	}
}