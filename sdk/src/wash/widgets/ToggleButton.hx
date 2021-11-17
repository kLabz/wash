package wash.widgets;

import wash.event.TouchEvent;
import wash.widgets.IWidget;

// TODO: remove wasp. once widgets are built separately
@:native('Wasp.ToggleButton')
// @:pythonImport('wasp', 'ToggleButton')
// @:pythonImport('widgets.togglebutton', 'ToggleButton')
extern class ToggleButton extends Button {
	var state:Bool;
}
