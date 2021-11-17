package wash.util;

class Math {
	public static inline function opFloorDiv(a:Float, b:Float):Int
		return python.Syntax.opFloorDiv(a, b);

	public static inline function opCeilDiv(a:Float, b:Float):Int
		return -opFloorDiv(-a, b);
}
