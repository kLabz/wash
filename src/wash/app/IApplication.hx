package wash.app;

import python.Bytes;

import wasp.Watch.WatchButton;
import wash.event.EventType;
import wash.event.TouchEvent;

@:dce @:remove
interface IApplication {
	public var NAME(default, null):String;
	public var ICON(default, null):Bytes;

	public function foreground():Void;
	public function background():Void;
	public function sleep():Bool;
	public function wake():Void;
	public function tick(ticks:Int):Void; // Float?
	public function touch(event:TouchEvent):Void;
	public function swipe(event:TouchEvent):Bool;
	public function press(eventType:EventType, state:Bool):Bool;
}

@:dce @:remove
interface ISettingsApplication extends IApplication {
	public function draw():Void;
	public function update():Void;
}
