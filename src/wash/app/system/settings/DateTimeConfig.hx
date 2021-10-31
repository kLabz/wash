package wash.app.system.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.util.TimeTuple;
import wash.widgets.ScrollIndicator;
import wash.widgets.Spinner;
import wasp.Fonts;
import wasp.Watch;

class DateTimeConfig extends BaseApplication implements ISettingsApplication {
	var HH:Spinner;
	var MM:Spinner;
	var dd:Spinner;
	var mm:Spinner;
	var yy:Spinner;

	var scroll:ScrollIndicator;
	var page:Int;

	public function new(_) {
		super();
		NAME = "Date/Time";

		HH = new Spinner(50, 60, 0, 23, 2);
		MM = new Spinner(130, 60, 0, 59, 2);
		dd = new Spinner(20, 60, 1, 31, 1);
		mm = new Spinner(90, 60, 1, 12, 1);
		yy = new Spinner(160, 60, 21, 60, 2);

		page = 0;
		scroll = new ScrollIndicator(null, 0, 1, page);
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case UP | DOWN:
				page = page == 0 ? 1 : 0;
				scroll.value = page;
				draw();

			case LEFT | RIGHT:
				return true;

			case _:
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		if (page == 0) {
			if (HH.touch(event) || MM.touch(event)) {
				var now = Watch.rtc.get_localtime();
				Watch.rtc.set_localtime(TimeTuple.make(now.yyyy, now.mm, now.dd, HH.value, MM.value, 0, now.wday, now.yday));
			}
		} else {
			if (dd.touch(event) || mm.touch(event) || yy.touch(event)) {
				var now = Watch.rtc.get_localtime();
				Watch.rtc.set_localtime(TimeTuple.make(yy.value + 2000, mm.value, dd.value, now.HH, now.MM, now.SS, now.wday, now.yday));
			}
		}
	}

	public function draw():Void {
		var draw = Watch.drawable;
		Watch.display.mute(true);
		draw.fill(0);

		draw.set_color(Wash.system.theme.highlight);
		draw.set_font(Fonts.sans24);
		draw.string(page == 0 ? "Time" : "Date", 0, 6, 240);

		var now = Watch.rtc.get_localtime();

		if (page == 0) {
			HH.value = now.HH;
			MM.value = now.MM;
			draw.set_font(Fonts.sans28);
			draw.string(':', 110, 120-14, 20);
			HH.draw();
			MM.draw();
		} else {
			yy.value = now.yyyy - 2000;
			mm.value = now.mm;
			dd.value = now.dd;
			yy.draw();
			mm.draw();
			dd.draw();
			draw.set_font(Fonts.sans24);
			draw.string('DD    MM    YY', 0, 180, 240);
		}

		scroll.draw();
		Watch.display.mute(false);
	}

	public function update():Void {}
}
