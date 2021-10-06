package wasp;

extern class Manager {
	var brightness:Int; // TODO: enum abstract
	function request_tick(ticks:Int):Void;
	function request_event(event:Int):Void; // TODO: EventMask combination
	function keep_awake():Void;
	function theme(color:String):Int;
	// TODO: other methods / variables
}
