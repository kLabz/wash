package wash.app.watchface.settings;

import python.Bytearray;
import python.lib.io.BufferedReader;

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

	public static function serialize(bytes:Bytearray):Void {
		bytes.append(F_12H);
		bytes.append(BaseWatchFace.hours12 ? 0x01 : 0x00);

		bytes.append(F_WeekNb);
		bytes.append(BaseWatchFace.displayWeekNb ? 0x01 : 0x00);

		bytes.append(F_BatteryPct);
		bytes.append(BaseWatchFace.displayBatteryPct ? 0x01 : 0x00);

		bytes.append(F_DblTapToSleep);
		bytes.append(BaseWatchFace.dblTapToSleep ? 0x01 : 0x00);
	}

	public static function deserialize(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case F_12H:
					BaseWatchFace.hours12 = f.read(1).get(0) == 0x01;

				case F_WeekNb:
					BaseWatchFace.displayWeekNb = f.read(1).get(0) == 0x01;

				case F_BatteryPct:
					BaseWatchFace.displayBatteryPct = f.read(1).get(0) == 0x01;

				case F_DblTapToSleep:
					BaseWatchFace.dblTapToSleep = f.read(1).get(0) == 0x01;

				case 0x00:
					break;
			}
		}
	}
}

private enum abstract Field(Int) to Int {
	var F_12H = 0x01;
	var F_WeekNb = 0x02;
	var F_BatteryPct = 0x03;
	var F_DblTapToSleep = 0x04;
}
