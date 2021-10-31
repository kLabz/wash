package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Slider;
import wasp.Watch;

class NotificationLevelConfig extends BaseApplication implements ISettingsApplication {
	var slider:Slider;

	public function new(_) {
		super();
		NAME = "Notification Level";

		slider = new Slider(3, 10, 90);
	}

	override public function touch(event:TouchEvent):Void {
		slider.touch(event);
		Settings.notificationLevel = cast (slider.value + 1);

		if (!Wash.system.nightMode)
			Wash.system.notificationLevel = Settings.notificationLevel;
	}

	public function draw():Void {
		slider.value = Settings.notificationLevel - 1;
	}

	public function update():Void {
		slider.update();
		Watch.drawable.string(Settings.notificationLevel.toString(), 0, 150, 240);
	}
}
