package wash.app.watchface.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;

@:access(wash.app.watchface.BatTri)
class BatTriConfig extends BaseApplication implements ISettingsApplication {
	var hours12:Checkbox;
	var weekNb:Checkbox;
	var batteryPct:Checkbox;

	public function new(_) {
		super();
		NAME = "BatTri Watchface";

		hours12 = new Checkbox(6, 60, "12 Hours");
		weekNb = new Checkbox(6, 110, "Week nb");
		batteryPct = new Checkbox(6, 160, "Battery %");
	}

	override public function touch(event:TouchEvent):Void {
		if (hours12.touch(event)) BatTri.hours12 = hours12.state;
		if (weekNb.touch(event)) BatTri.displayWeekNb = weekNb.state;
		if (batteryPct.touch(event)) BatTri.displayBatteryPct = batteryPct.state;
	}

	public function draw():Void {
		hours12.state = BatTri.hours12;
		weekNb.state = BatTri.displayWeekNb;
		batteryPct.state = BatTri.displayBatteryPct;

		hours12.draw();
		weekNb.draw();
		batteryPct.draw();
	}

	public function update():Void {}
}
