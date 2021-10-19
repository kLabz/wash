package wash.widgets;

import python.Syntax;
import python.Tuple;

import wasp.Fonts;
import wasp.Watch;
import wash.event.TouchEvent;
import wash.icon.CheckboxIcon;

class Checkbox implements IWidget {
	public var state:Bool;
	var data:CheckboxData;

	public function new(x:Int, y:Int, ?label:String) {
		data = CheckboxData.make(x, y, label);
		state = false;
	}

	public function draw():Void {
		if (data.label != null) {
			var draw = Watch.drawable;
			draw.set_color(Wash.system.theme.bright);
			draw.set_font(Fonts.sans24);
			draw.string(data.label, data.x, data.y + 6);
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
		var fg:Int = Wash.system.theme.mid;

		if (state) {
			c1 = Wash.system.theme.ui;
			c2 = draw.lighten(c1, Wash.system.theme.contrast);
			fg = c2;
		}

		// Draw checkbox on the right margin if there is a label, otherwise
		// draw at the natural location
		var x = data.label != null ? 239 - 32 - 4 : data.x;
		draw.blit(CheckboxIcon, x, data.y, fg, c1, c2);
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
