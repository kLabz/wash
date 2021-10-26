package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Slider;
import wasp.Watch;

class BrightnessConfig extends BaseApplication implements ISettingsApplication {
	var slider:Slider;

	public function new(_) {
		super();
		NAME = "Brightness";

		slider = new Slider(3, 10, 90);
	}

	override public function touch(event:TouchEvent):Void {
		slider.touch(event);
		Wash.system.brightness = slider.value + 1;
	}

	public function draw():Void {
		slider.value = Wash.system.brightness - 1;
	}

	public function update():Void {
		var say = switch (Wash.system.brightness) {
			case 3: "High";
			case 2: "Mid";
			case _: "Low";
		};

		slider.update();
		Watch.drawable.string(say, 0, 150, 240);
	}
}