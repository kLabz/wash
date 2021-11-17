package wash.app;

import python.Bytes;

import wash.app.IApplication;
import wash.event.EventType;
import wash.event.TouchEvent;

@:native('BaseApplication')
@:pythonImport('app.baseapplication', 'BaseApplication')
extern class BaseApplication implements IApplication {
	var NAME(default, null):String;
	var ICON(default, null):Bytes;
	var ID(default, null):Int;

	function new();
	function foreground():Void;
	function background():Void;
	function registered(quickRing:Bool):Void;
	function unregistered():Void;
	function sleep():Bool;
	function wake():Void;
	function tick(ticks:Int):Void;
	function touch(event:TouchEvent):Void;
	function swipe(event:TouchEvent):Bool;
	function press(eventType:EventType, state:Bool):Bool;
}
