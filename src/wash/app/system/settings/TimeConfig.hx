package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.util.TimeTuple;
import wash.widgets.Spinner;
import wasp.Fonts;
import wasp.Watch;

class TimeConfig extends BaseApplication implements ISettingsApplication {
	var HH:Spinner;
	var MM:Spinner;

	public function new(_) {
		super();
		NAME = "Time";

		HH = new Spinner(50, 60, 0, 23, 2);
		MM = new Spinner(130, 60, 0, 59, 2);
	}

	override public function touch(event:TouchEvent):Void {
		if (HH.touch(event) || MM.touch(event)) {
			var now = Watch.rtc.get_localtime();
			Watch.rtc.set_localtime(TimeTuple.make(now.yyyy, now.mm, now.dd, HH.value, MM.value, 0, now.wday, now.yday));
		}
	}

	public function draw():Void {
		var now = Watch.rtc.get_localtime();
		HH.value = now.HH;
		MM.value = now.MM;
		Watch.drawable.set_font(Fonts.sans28);
		Watch.drawable.string(':', 110, 120-14, 20);
		HH.draw();
		MM.draw();
	}

	public function update():Void {}
}
