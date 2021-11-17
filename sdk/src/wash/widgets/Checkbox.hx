package wash.widgets;

import wash.event.TouchEvent;
import wash.widgets.IWidget;

// TODO: remove wasp. once widgets are built separately
@:native('Wasp.Checkbox')
// @:native('wasp.Checkbox')
// @:pythonImport('wasp', 'Checkbox')
// @:pythonImport('widgets.checkbox', 'Checkbox')
extern class Checkbox implements IWidget {
	var state:Bool;
	var forcedChecked:Bool;
	function new(x:Int, y:Int, ?label:String, ?smallText:Bool = false);
	function dispose():Void;
	function draw():Void;
	function touch(event:TouchEvent):Bool;
	function update():Void;
}
