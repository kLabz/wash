package wash.widgets;

import python.Syntax;
import python.Tuple;

import wasp.Fonts;
import wasp.Watch;
import wash.event.TouchEvent;

class Button implements IWidget {
	var data:ButtonData;

	public function new(x:Int, y:Int, w:Int, h:Int, label:String) {
		data = ButtonData.make(x, y, w, h, label);
	}

	public function draw():Void {
		update(
			Watch.drawable.darken(Wash.system.theme.ui),
			Wash.system.theme.mid,
			Wash.system.theme.bright
		);
	}

	public function touch(event:TouchEvent):Bool {
		var x1 = data.x - 10;
		var x2 = x1 + data.w + 20;
		var y1 = data.y - 10;
		var y2 = y1 + data.h + 20;

		return event.x >= x1 && event.x < x2 && event.y >= y1 && event.y < y2;
	}

	public function update(bg:Int, frame:Int, txt:Int):Void {
		var draw = Watch.drawable;

		draw.fill(frame, data.x, data.y, data.w, data.h);
		draw.fill(bg, data.x+2, data.y+2, data.w-4, data.h-4);
		draw.set_color(txt, bg);
		draw.set_font(Fonts.sans24);
		draw.string(data.label, data.x+2, data.y+opFloorDiv(data.h, 2)-12, data.w-4);
	}
}

@:native("tuple")
extern class ButtonData extends Tuple<Dynamic> {
	static inline function make(
		x:Int, y:Int, w:Int, h:Int, label:String
	):ButtonData
		return Syntax.tuple(x, y, w, h, label);

	var x(get, null):Int;
	inline function get_x():Int return this[0];

	var y(get, null):Int;
	inline function get_y():Int return this[1];

	var w(get, null):Int;
	inline function get_w():Int return this[2];

	var h(get, null):Int;
	inline function get_h():Int return this[3];

	var label(get, null):String;
	inline function get_label():String return this[4];
}
