package wash.widgets;

import wash.event.TouchEvent;
import wash.widgets.IWidget;

@:pythonImport('wasp', 'Button')
// @:pythonImport('widgets.button', 'Button')
extern class Button implements IWidget {
	function new(x:Int, y:Int, w:Int, h:Int, label:String);
	function dispose():Void;
	function draw():Void;
	function touch(event:TouchEvent):Bool;
	function update(bg:Int, txt:Int):Void;
}
