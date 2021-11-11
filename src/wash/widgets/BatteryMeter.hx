package wash.widgets;

import python.Bytes;
import python.Syntax;

import wasp.Watch;
import wash.icon.BatteryIcon;
import wash.icon.PlugIcon;

class BatteryMeter implements IWidget {
	var level:Int;
	var batteryIcon:Bytes;
	var plugIcon:Bytes;

	public function new() {
		level = -1;

		batteryIcon = BatteryIcon.getIcon();
		plugIcon = PlugIcon.getIcon();
	}

	public function dispose():Void {
		batteryIcon = null;
		plugIcon = null;
		Syntax.delete(batteryIcon);
		Syntax.delete(plugIcon);
	}

	public function draw():Void {
		Watch.drawable.blit(
			batteryIcon,
			238-batteryIcon[1],
			2,
			Wash.system.theme.primary,
			true
		);

		level = -1;
		update();
	}

	public function update():Void {
		var draw = Watch.drawable;

		if (Watch.battery.charging()) {
			Watch.drawable.blit(
				plugIcon,
				238-batteryIcon[1]-2-plugIcon[1],
				4,
				0,
				Wash.system.theme.primary,
				true
			);
		} else {
			draw.fill(
				Wash.system.theme.primary,
				238-batteryIcon[1]-2-plugIcon[1],
				4,
				plugIcon[1],
				plugIcon[2]
			);
		}

		var level = Watch.battery.level();
		if (level == this.level) return;

		draw.fill(
			Wash.system.theme.primary,
			238-batteryIcon[1]+2,
			2 + 4,
			batteryIcon[1]-4,
			batteryIcon[2]-6
		);

		for (i in 0...5) {
			if (level >= 10 + i*20) {
				draw.fill(
					0,
					238-batteryIcon[1]+3,
					2+batteryIcon[2]-3-3*i-2,
					batteryIcon[1]-6,
					2
				);
			}
		}

		this.level = level;
	}
}
