package wash.widgets;

import wasp.Watch;
import wash.icon.BatteryIcon.icon as BatteryIcon;
import wash.icon.PlugIcon.icon as PlugIcon;

class BatteryMeter implements IWidget {
	var level:Int;

	public function new() {
		level = -1;
	}

	public function draw():Void {
		Watch.drawable.blit(
			BatteryIcon,
			238-BatteryIcon[1],
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
				PlugIcon,
				238-BatteryIcon[1]-2-PlugIcon[1],
				4,
				0,
				Wash.system.theme.primary,
				true
			);
		} else {
			draw.fill(
				Wash.system.theme.primary,
				238-BatteryIcon[1]-2-PlugIcon[1],
				4,
				PlugIcon[1],
				PlugIcon[2]
			);
		}

		var level = Watch.battery.level();
		if (level == this.level) return;

		draw.fill(
			Wash.system.theme.primary,
			238-BatteryIcon[1]+2,
			2 + 4,
			BatteryIcon[1]-4,
			BatteryIcon[2]-6
		);

		for (i in 0...5) {
			if (level >= 10 + i*20) {
				draw.fill(
					0,
					238-BatteryIcon[1]+3,
					2+BatteryIcon[2]-3-3*i-2,
					BatteryIcon[1]-6,
					2
				);
			}
		}

		this.level = level;
	}
}
