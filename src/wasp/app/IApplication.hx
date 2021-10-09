package wasp.app;

import python.Bytes;

@:dce @:remove
interface IApplication {
	public var NAME(default, null):String;
	public var ICON(default, null):Bytes;

	public function foreground():Void;
	public function background():Void;
}

// TODO: macro magic to check for signature instead?
// class Application {
// 	public function sleep():Void {}
// 	public function wake():Void {}
// 	public function tick(ticks:Int):Void {} // Float?
// 	public function touch(event:Any):Void {} // TODO: types
// 	public function swipe(event:Any):Void {} // TODO: types
// 	public function press(button:Any, state:Any):Void {} // TODO: types
// }
