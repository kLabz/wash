package wasp.widgets;

import python.Syntax.opFloorDiv;

import wasp.event.TouchEvent;
import wasp.icon.Knob;

class Slider implements IWidget {
	static inline var KNOB_DIAMETER:Int = 40;
	static inline var KNOB_RADIUS:Int = KNOB_DIAMETER >> 1;
	static inline var WIDTH:Int = 220;
	static inline var TRACK:Int = WIDTH - KNOB_DIAMETER;
	static inline var TRACK_HEIGHT:Int = 8;
	static inline var TRACK_Y1:Int = KNOB_RADIUS - (TRACK_HEIGHT >> 1);
	static inline var TRACK_Y2:Int = TRACK_Y1 + TRACK_HEIGHT;

	var value:Int;
	var steps:Int;
	var stepSize:Float;
	var x:Int;
	var y:Int;
	var color:Null<Int>;
	var lowLight:Null<Int>;

	public function new(steps:Int, ?x:Int = 10, y:Int = 90, ?color:Int) {
		value = 0;
		this.steps = steps;
		this.stepSize = TRACK / (steps - 1);
		this.x = x;
		this.y = y;
		this.color = color;
		this.lowLight = null;
	}

	public function draw():Void {
		var draw = Watch.drawable;

		if (color == null) color = Manager.theme('ui');
		if (lowLight == null)
			lowLight = draw.lighten(color, Manager.theme('contrast'));

		var knobX:Int = x + opFloorDiv(TRACK * value, steps - 1);
		draw.blit(Knob, knobX, this.y, color);

		var w = knobX - x;
		if (w > 0) {
			draw.fill(0, x, y, w, TRACK_Y1);
			if (w > KNOB_RADIUS) {
				draw.fill(0, x, y+TRACK_Y1, KNOB_RADIUS, TRACK_HEIGHT);
				draw.fill(color, x+KNOB_RADIUS, y+TRACK_Y1, w-KNOB_RADIUS, TRACK_HEIGHT);
			} else {
				draw.fill(0, x, y+TRACK_Y1, w, TRACK_HEIGHT);
			}

			draw.fill(0, x, y+TRACK_Y2, w, TRACK_Y1);
		}

		var sx = knobX + KNOB_DIAMETER;
		w = WIDTH - KNOB_DIAMETER - w;
		if (w > 0) {
			draw.fill(0, sx, y, w, TRACK_Y1);
			if (w > KNOB_RADIUS) {
				draw.fill(0, sx+w-KNOB_RADIUS, y+TRACK_Y1,KNOB_RADIUS, TRACK_HEIGHT);
				draw.fill(lowLight, sx, y+TRACK_Y1, w-KNOB_RADIUS, TRACK_HEIGHT);
			} else {
				draw.fill(0, sx, y+TRACK_Y1, w, TRACK_HEIGHT);
			}

			draw.fill(0, sx, y+TRACK_Y2, w, TRACK_Y1);
		}
	}

	public function update():Void draw();

	public function touch(event:TouchEvent):Void {
		var threshold = x + 20 - stepSize / 2;
		var v = opFloorDiv(event.x - threshold, stepSize);

		if (v < 0) v = 0;
		else if (v >= steps) v = steps - 1;
		value = v;
	}
}
