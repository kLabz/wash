package app.alarm;

import python.Syntax.tuple;
import python.Tuple;

import wasp.widgets.ToggleButton;

@:native("tuple")
extern class DayButtons extends Tuple<Dynamic> {
	static inline function make():DayButtons
		return tuple(
			new ToggleButton(10, 145, 40, 35, "Mo"),
			new ToggleButton(55, 145, 40, 35, "Tu"),
			new ToggleButton(100, 145, 40, 35, "We"),
			new ToggleButton(145, 145, 40, 35, "Th"),
			new ToggleButton(190, 145, 40, 35, "Fr"),
			new ToggleButton(10, 185, 40, 35, "Sa"),
			new ToggleButton(55, 185, 40, 35, "Su")
		);

	inline function iterator():DayButtonsIterator return new DayButtonsIterator(this);
	inline function keyValueIterator():DayButtonsKVIterator return new DayButtonsKVIterator(this);
}

class DayButtonsIterator {
	var index:Int;
	var buttons:DayButtons;

	public inline function new(buttons:DayButtons) {
		index = 0;
		this.buttons = buttons;
	}

	public inline function hasNext():Bool return index < 7;
	public inline function next():ToggleButton return buttons[index++];
}

class DayButtonsKVIterator {
	var index:Int;
	var buttons:DayButtons;

	public inline function new(buttons:DayButtons) {
		index = 0;
		this.buttons = buttons;
	}

	public inline function hasNext():Bool return index < 7;

	public inline function next():{key:Int, value:ToggleButton} {
		return {
			value: buttons[index],
			key: index++
		};
	}
}
