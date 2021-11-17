package wash;

import wash.app.IApplication;
import wash.event.EventType;
import wash.widgets.StatusBar;

@:native('Manager')
@:pythonImport('wasp', 'Manager')
extern class Manager {
	static var DOUBLE_TAP_MS:Int;

	var theme:Theme;
	var bar:StatusBar;
	var nightMode:Bool;

	function registerApp(path:String):Void;
	function unregisterApp(path:String):Void;
	function hasQuickRingApplication(cls:Class<IApplication>):Bool;
	function hasApplication(path:String):Bool;
	function isActive(app:IApplication):Bool;
	function requestEvent(event:Int):Void;
	function requestTick(periodMs:Int):Void;
	function wake():Void;
	function sleep():Void;
	function keepAwake():Void;
	function switchApp(app:IApplication):Void;
	function navigate(direction:EventType):Void;
	function setAlarm(time:Float, cb:Void->Void):Void;
	function cancelAlarm(time:Float, cb:Void->Void):Bool;
}
