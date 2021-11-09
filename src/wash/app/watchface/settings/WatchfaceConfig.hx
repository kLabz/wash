package wash.app.watchface.settings;

import wash.app.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wasp.Fonts;
import wasp.Watch;

class WatchfaceConfig extends BaseApplication implements ISettingsApplication {
	var hours12:Checkbox;
	var weekNb:Checkbox;
	var batteryPct:Checkbox;
	var dblTapSleep:Checkbox;

	public function new(_) {
		super();
		NAME = "Watchface";

		hours12 = new Checkbox(6, 50, "12 Hours");
		weekNb = new Checkbox(6, 90, "Week nb");
		batteryPct = new Checkbox(6, 130, "Battery %");
		dblTapSleep = new Checkbox(6, 170, "Dbl tap to sleep");
	}

	override public function touch(event:TouchEvent):Void {
		if (hours12.touch(event)) BaseWatchFace.hours12 = hours12.state;
		if (weekNb.touch(event)) BaseWatchFace.displayWeekNb = weekNb.state;
		if (batteryPct.touch(event)) BaseWatchFace.displayBatteryPct = batteryPct.state;
		if (dblTapSleep.touch(event)) BaseWatchFace.dblTapToSleep = dblTapSleep.state;
	}

	public function draw():Void {
		var draw = Watch.drawable;
		draw.set_color(Wash.system.theme.highlight);
		draw.set_font(Fonts.sans24);
		draw.string(NAME, 0, 6, 240);

		hours12.state = BaseWatchFace.hours12;
		weekNb.state = BaseWatchFace.displayWeekNb;
		batteryPct.state = BaseWatchFace.displayBatteryPct;
		dblTapSleep.state = BaseWatchFace.dblTapToSleep;

		hours12.draw();
		weekNb.draw();
		batteryPct.draw();
		dblTapSleep.draw();
	}

	public function update():Void {}
}
