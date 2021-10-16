package wasp.util;

import python.Bytearray;
import python.Bytes;
import python.Tuple;

@:pythonImport("builtins")
extern class Builtins {
	@:overload(function(x:Any, base:Int):Int {})
	static function int(x:Any):Int;
	static function str(o:Any):String;
	static function eval(expression:String):Any;
	static function print(o:Any):Void;
	static function type(o:Any):Class<Any>;
	static function chr(c:Int):String;

	// @:overload(function(f:Set<Dynamic>):Int {})
	// @:overload(function(f:StringBuf):Int {})
	@:overload(function(f:Array<Dynamic>):Int {})
	// @:overload(function(f:Dict<Dynamic, Dynamic>):Int {})
	@:overload(function(f:Bytes):Int {})
	// @:overload(function(f:DictView<Dynamic>):Int {})
	@:overload(function(f:Bytearray):Int {})
	@:overload(function(f:Tuple<Dynamic>):Int {})
	static function len(x:String):Int;
}
