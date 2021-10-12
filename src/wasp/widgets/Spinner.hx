package wasp.widgets;

import python.Syntax;
import python.Tuple;

import wasp.event.TouchEvent;
import wasp.icon.DownArrow;
import wasp.icon.UpArrow;

class Spinner implements IWidget {
	var data:SpinnerData;
	var value:Int;

	public function new(x:Int, y:Int, mn:Int, mx:Int, field:Int = 1) {
		data = SpinnerData.make(x, y, mn, mx, field);
		value = mn;
	}

	public function draw():Void {
		var draw = Watch.drawable;
		var fg = draw.lighten(Wasp.system.theme.ui, Wasp.system.theme.contrast);
		draw.blit(UpArrow, data.x+30-8, data.y+20, fg);
		draw.blit(DownArrow, data.x+30-8, data.y+120-20-9, fg);
		update();
	}

	public function update():Void {
		var draw = Watch.drawable;
		draw.set_color(Wasp.system.theme.bright);
		draw.set_font(Fonts.sans28);
		var s = "" + value;
		while (s.length < data.field) s = '0' + s;
		draw.string(s, data.x, data.y+60-14, 60);
	}

	public function touch(event:TouchEvent):Bool {
		if (
			event.x >= data.x && event.x < data.x+60
			&& event.y >= data.y && event.y < data.y + 120
		) {
			if (event.y < data.y + 60) {
				value++;
				if (value > data.mx) value = data.mn;
			} else {
				value--;
				if (value < data.mn) value = data.mx;

			}

			update();
			return true;
		}

		return false;
	}
}

@:native("tuple")
extern class SpinnerData extends Tuple<Dynamic> {
	static inline function make(
		x:Int, y:Int, mn:Int, mx:Int, field:Int
	):SpinnerData
		return Syntax.tuple(x, y, mn, mx, field);

	var x(get, null):Int;
	inline function get_x():Int return this[0];

	var y(get, null):Int;
	inline function get_y():Int return this[1];

	var mn(get, null):Int;
	inline function get_mn():Int return this[2];

	var mx(get, null):Int;
	inline function get_mx():Int return this[3];

	var field(get, null):Int;
	inline function get_field():Int return this[4];
}
