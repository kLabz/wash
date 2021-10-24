package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Slider;
import wasp.Watch;

class NotificationLevelConfig extends BaseApplication implements ISettingsApplication {
	var slider:Slider;

	public function new() {
		slider = new Slider(3, 10, 90);
	}

	override public function touch(event:TouchEvent):Void {
		slider.touch(event);
		Wash.system.notifyLevel = slider.value + 1;
	}

	public function draw():Void {
		slider.value = Wash.system.notifyLevel - 1;
	}

	public function update():Void {
		var say = switch (Wash.system.notifyLevel) {
			case 3: "High";
			case 2: "Mid";
			case _: "Silent";
		};

		slider.update();
		Watch.drawable.string(say, 0, 150, 240);
	}
}
