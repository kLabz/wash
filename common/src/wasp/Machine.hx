package wasp;

@:pythonImport('machine')
@:native('machine')
extern class Machine {
	static function deepsleep():Void;
}

@:pythonImport('machine', 'Timer')
extern class Timer {
	function new(id:Int, period:Int);
	function start():Void;
	function stop():Void;
	function time():Int;
	function period():Int;
}
