package wasp;

import wasp.app.IApplication;

// TODO: replace with HxManager below when ready
@:native('wasp.system')
extern class Manager {
	static var quick_ring:Array<IApplication>;
	static var launcher_ring:Array<IApplication>;
	static var brightness:Int; // TODO: enum abstract
	static var notifications:Array<Notification>;

	static function request_tick(ticks:Int):Void;
	static function request_event(event:Int):Void; // TODO: EventMask combination
	static function keep_awake():Void;
	static function theme(color:String):Int;
	@:native("switch") static function switchApp(app:IApplication):Void;
	// TODO: other methods / variables
}

// class HxManager {
// 	var app:IApplication;
// 	var brightness:Int; // TODO: enum abstract
// 	// var bar:StatusBar; // TODO: widget
// 	// var launcher:Launcher;

// 	function request_tick(ticks:Int):Void;
// 	function request_event(event:Int):Void; // TODO: EventMask combination
// 	function keep_awake():Void;
// 	function theme(color:String):Int;
// 	// TODO: other methods / variables
// }

// TODO: move
typedef Notification = {
	var title:String;
	var body:String;
}
