package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.util.TimeTuple;
import wash.widgets.Spinner;
import wasp.Fonts;
import wasp.Watch;

class DateConfig extends BaseApplication implements ISettingsApplication {
	var dd:Spinner;
	var mm:Spinner;
	var yy:Spinner;

	public function new(_) {
		NAME = "Date";

		dd = new Spinner(20, 60, 1, 31, 1);
		mm = new Spinner(90, 60, 1, 12, 1);
		yy = new Spinner(160, 60, 21, 60, 2);
	}

	override public function touch(event:TouchEvent):Void {
		if (dd.touch(event) || mm.touch(event) || yy.touch(event)) {
			var now = Watch.rtc.get_localtime();
			Watch.rtc.set_localtime(TimeTuple.make(yy.value + 2000, mm.value, dd.value, now.HH, now.MM, now.SS, now.wday, now.yday));
		}
	}

	public function draw():Void {
		var now = Watch.rtc.get_localtime();
		yy.value = now.yyyy - 2000;
		mm.value = now.mm;
		dd.value = now.dd;
		yy.draw();
		mm.draw();
		dd.draw();
		Watch.drawable.set_font(Fonts.sans24);
		Watch.drawable.string('DD    MM    YY', 0, 180, 240);
	}

	public function update():Void {}
}
