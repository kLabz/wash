package wash.widgets;

// TODO: remove wasp. once widgets are built separately
@:native('Wasp.ScrollIndicator')
// @:pythonImport('wasp', 'ScrollIndicator')
// @:pythonImport('widgets.scrollindicator', 'ScrollIndicator')
extern class ScrollIndicator {
	var value:Int;
	var min:Int;
	var max:Int;

	function new(y:Int, min:Int, max:Int, value:Int);
	function draw():Void;
	function update():Void;
}
