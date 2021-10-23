package wash.widgets;

import wasp.Watch;
import wash.event.TouchEvent;

using python.NativeStringTools;

class ColorPicker implements IWidget {
	public var color:Int;
	var sliderR:Slider;
	var sliderG:Slider;
	var sliderB:Slider;

	public function new(?color:Int = 0) {
		this.color = color;

		sliderR = new Slider(32, 10, 90, 0xF800);
		sliderG = new Slider(64, 10, 140, 0x27E4);
		sliderB = new Slider(32, 10, 190, 0x211F);

		if (color > 0) {
			sliderR.value = color >> 11;
			sliderG.value = (color - (sliderR.value << 11)) >> 5;
			sliderB.value = color - (sliderR.value << 11) - (sliderG.value << 5);
		}
	}

	public function touch(event:TouchEvent):Void {
		if (event.y > 90) {
			var sliderIndex = opFloorDiv(event.y - 90, 50);
			var slider = switch (sliderIndex) {
				case 0: sliderR;
				case 1: sliderG;
				case _: sliderB;
			};

			slider.touch(event);
			slider.update();
			updateColors();
		}
	}

	public function draw():Void {
		sliderR.draw();
		sliderG.draw();
		sliderB.draw();
		updateColors();
	}

	function updateColors():Void {
		var r = sliderR.value;
		var g = sliderG.value;
		var b = sliderB.value;
		color = (r << 11) + (g << 5) + b;

		var draw = Watch.drawable;
		draw.string('RGB565 #{:04x}'.format(color), 0, 6, 240);
		draw.fill(color, 60, 35, 120, 50);
	}
}
