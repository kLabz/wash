package wash.widgets;

import wash.event.TouchEvent;
import wash.widgets.IWidget;

@:pythonImport('wasp', 'ToggleButton')
// @:pythonImport('widgets.togglebutton', 'ToggleButton')
extern class ToggleButton extends Button {
	var state:Bool;
}
