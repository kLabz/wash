package wash.widgets;

import wash.event.TouchEvent;
import wash.widgets.IWidget;

// TODO: remove wasp. once widgets are built separately
@:native('Wasp.Spinner')
// @:pythonImport('wasp', 'Spinner')
// @:pythonImport('widgets.spinner', 'Spinner')
extern class Spinner implements IWidget {
	var value:Int;
	function new(x:Int, y:Int, mn:Int, mx:Int, field:Int = 1);
	function dispose():Void;
	function draw():Void;
	function touch(event:TouchEvent):Bool;
	function update():Void;
}
