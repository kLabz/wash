package wash.app;

import python.Bytes;

import wash.event.EventType;
import wash.event.TouchEvent;

@:dce @:remove
interface IApplication {
	public var NAME(default, null):String;
	public var ICON(default, null):Bytes;
	public var ID(default, null):Int;

	public function foreground():Void;
	public function background():Void;
	public function registered(quickRing:Bool):Void;
	public function unregistered():Void;
	public function sleep():Bool;
	public function wake():Void;
	public function tick(ticks:Int):Void; // Float?
	public function touch(event:TouchEvent):Void;
	public function swipe(event:TouchEvent):Bool;
	public function press(eventType:EventType, state:Bool):Bool;
}
