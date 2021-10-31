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
		Settings.brightnessLevel = cast (slider.value + 1);

		if (!Wash.system.nightMode)
			Wash.system.brightnessLevel = Settings.brightnessLevel;
	}

	public function draw():Void {
		slider.value = Settings.brightnessLevel - 1;
	}

	public function update():Void {
		slider.update();
		Watch.drawable.string(Settings.brightnessLevel.toString(), 0, 150, 240);
	}
}
