package wasp.util;

@:pythonImport("time")
extern class Time {
	static function time():Float;
	static function clock():Float;
	static function sleep(t:Float):Void;
	static function mktime(s:TimeTuple):Float;
	static function localtime(time:Float):TimeTuple;
}
