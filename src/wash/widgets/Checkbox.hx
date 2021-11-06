package wash.widgets;

import python.Syntax;
import python.Tuple;

import wasp.Fonts;
import wasp.Watch;
import wash.event.TouchEvent;
import wash.icon.CheckboxIcon;

class Checkbox implements IWidget {
	public var state:Bool;
	public var forcedChecked:Bool;
	var data:CheckboxData;
	var smallText:Bool;

	public function new(x:Int, y:Int, ?label:String, ?smallText:Bool = false) {
		data = CheckboxData.make(x, y, label);
		state = false;
		forcedChecked = false;
		this.smallText = smallText;
	}

	public function draw():Void {
		if (data.label != null) {
			var draw = Watch.drawable;
			draw.set_color(Wash.system.theme.highlight);
			draw.set_font(!smallText ? Fonts.sans24 : Fonts.sans18);
			draw.string(data.label, data.x + 32 + 6, data.y + 6);
		}

		update();
	}

	public function touch(event:TouchEvent):Bool {
		if (
			(data.label != null || (data.x <= event.x && event.x < data.x + 40))
			&& data.y <= event.y && event.y < data.y + 40
		) {
			state = !state;
			update();
			return true;
		}

		return false;
	}

	public function update():Void {
		var draw = Watch.drawable;
		var c1:Int = 0;
		var c2:Int = 0;
		var fg:Int = Wash.system.theme.primary;

		if (forcedChecked) {
			c2 = fg;
			fg = c1 = 0;
		} else if (state) {
			c1 = fg;
			c2 = 0;
		}

		draw.blit(CheckboxIcon, data.x, data.y, fg, c1, c2);
	}
}

@:native("tuple")
extern class CheckboxData extends Tuple<Dynamic> {
	static inline function make(x:Int, y:Int, ?label:String = null):CheckboxData
		return Syntax.tuple(x, y, label);

	var x(get, null):Int;
	inline function get_x():Int return this[0];

	var y(get, null):Int;
	inline function get_y():Int return this[1];

	var label(get, null):Null<String>;
	inline function get_label():Null<String> return this[2];
}
