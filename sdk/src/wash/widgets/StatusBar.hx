package wash.widgets;

import wash.util.DateTimeTuple;
import wash.widgets.IWidget;

@:native('StatusBar')
@:pythonImport('widgets.statusbar', 'StatusBar')
extern class StatusBar implements IWidget {
	var displayClock:Bool;

	function new();
	function dispose():Void;
	function draw():Void;
	function update():Null<DateTimeTuple>;
}
