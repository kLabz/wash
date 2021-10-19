package wash.app.user;

import python.Bytes;
import python.Syntax;
import python.Syntax.bytes;
import python.Syntax.opFloorDiv;

import wasp.Builtins;
import wasp.Watch;
import wash.event.EventMask;
import wash.event.TouchEvent;

using python.NativeStringTools;

@:native('CalcApp')
class Calc extends BaseApplication {
	static inline var BUTTON_Y:Int = 200;

	static var icon:Bytes = bytes(
		'\\x02',
		'@@',
		'?\\xff\\x89@\\xacW\\x04\\x97\\rY\\x02\\x99\\x0cY\\x02\\x99',
		'\\x0cY\\x02\\x99\\x0cY\\x02\\x99\\x0cK\\x03K\\x02\\x99\\x0cK',
		'\\x03K\\x02\\x99\\x0cK\\x03K\\x02\\x99\\x0cK\\x03K\\x02\\x99',
		'\\x0cK\\x03K\\x02\\x99\\x0cK\\x03K\\x02\\x99\\x0cE\\x0fE',
		'\\x02\\x85\\x0f\\x85\\x0cE\\x0fE\\x02\\x85\\x0f\\x85\\x0cE\\x0fE',
		'\\x02\\x85\\x0f\\x85\\x0cK\\x03K\\x02\\x99\\x0cK\\x03K\\x02\\x99',
		'\\x0cK\\x03K\\x02\\x99\\x0cK\\x03K\\x02\\x99\\x0cK\\x03K',
		'\\x02\\x99\\x0cK\\x03K\\x02\\x99\\x0cY\\x02\\x99\\x0cY\\x02\\x99',
		'\\x0cY\\x02\\x99\\x0cY\\x02\\x99\\rW\\x04\\x97?O\\x97\\x04',
		'\\xd7\\r\\x99\\x02\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x99\\x02',
		'\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x86\\x02\\x88\\x02\\x87\\x02\\xd9\\x0c\\x86\\x03',
		'\\x86\\x03\\x87\\x02\\xd9\\x0c\\x87\\x03\\x84\\x03\\x88\\x02\\xc5\\x0f\\xc5\\x0c',
		'\\x88\\x03\\x82\\x03\\x89\\x02\\xc5\\x0f\\xc5\\x0c\\x89\\x06\\x8a\\x02\\xc5\\x0f',
		'\\xc5\\x0c\\x8a\\x04\\x8b\\x02\\xd9\\x0c\\x8a\\x04\\x8b\\x02\\xd9\\x0c\\x89\\x06',
		'\\x8a\\x02\\xd9\\x0c\\x88\\x03\\x82\\x03\\x89\\x02\\xc5\\x0f\\xc5\\x0c\\x87\\x03',
		'\\x84\\x03\\x88\\x02\\xc5\\x0f\\xc5\\x0c\\x86\\x03\\x86\\x03\\x87\\x02\\xc5\\x0f',
		'\\xc5\\x0c\\x86\\x02\\x88\\x02\\x87\\x02\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x99\\x02',
		'\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x99\\x02\\xd9\\x0c\\x99\\x02',
		'\\xd9\\r\\x97\\x04\\xd7?\\xff\\t'
	);

	static var fields:Bytes = bytes(
		'789+(',
		'456-)',
		'123*^',
		'C0./='
	);

	var output:String;

	public function new() {
		NAME = "Calc";
		ICON = icon;

		output = "";
	}

	override public function foreground():Void {
		draw();
		update();
		Wash.system.requestEvent(EventMask.TOUCH);
	}

	override public function touch(event:TouchEvent):Void {
		if (event.y < 48) {
			// Undo button pressed
			if (event.x > 200) {
				if (output != "") output = Syntax.substr(output, null, -1);
			}
		} else {
			var x = opFloorDiv(event.x, 47);
			var y = opFloorDiv(event.y, 48) - 1;

			// Error handling for touching at the border
			if (x > 4) x = 4;
			if (y > 3) y = 3;

			var buttonPressed = fields[x + 5*y];
			switch (buttonPressed) {
				case 'C'.code: output = "";
				case '='.code:
					try {
						output = Syntax.substr(
							Builtins.str(Builtins.eval(output.replace('^', '**'))),
							null, 12
						);
					} catch (_) {
						Watch.vibrator.pulse();
					}

				case _: output += Builtins.chr(buttonPressed);
			}
		}

		update();
	}

	function update():Void {
		output = output.length < 12 ? output : Syntax.substr(output, output.length-12, null);
		Watch.drawable.string(output, 0, 14, 200, true);
	}

	function draw():Void {
		var draw = Watch.drawable;

		var hi = Wash.system.theme.bright;
		var lo = Wash.system.theme.mid;
		var mid = draw.lighten(lo, 2);
		var bg = draw.darken(Wash.system.theme.ui, Wash.system.theme.contrast);
		var bg2 = draw.darken(bg, 2);

		// Draw the background
		draw.fill(0, 0, 0, 239, 47);
		draw.fill(0, 236, 239, 3);
		draw.fill(bg, 141, 48, 239-141, 236-48);
		draw.fill(bg2, 0, 48, 141, 236-48);

		// Make grid
		draw.set_color(lo);
		for (i in 0...4) {
			draw.line(0, (i+1)*47, 239, (i+1)*47);
			draw.line((i+1)*47, 47, (i+1)*47, 235);
		}
		draw.line(0, 47, 0, 236);
		draw.line(239, 47, 239, 236);
		draw.line(0, 236, 239, 236);

		// Draw button labels
		draw.set_color(hi, bg2);
		for (x in 0...5) {
			if (x == 3) draw.set_color(mid, bg);

			for (y in 0...4) {
				var label = Builtins.chr(fields[x + 5*y]);
				if (x == 0) draw.string(label, x*47+14, y*47+60);
				else draw.string(label, x*47+16, y*47+60);
			}
		}
		draw.set_color(hi);
		draw.string("<", 215, 10);
	}
}
