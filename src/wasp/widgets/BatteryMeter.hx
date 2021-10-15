package wasp.widgets;

import python.Syntax.opFloorDiv;

import wasp.icon.BatteryIcon.icon as BatteryIcon;

class BatteryMeter implements IWidget {
	var level:Int;

	public function new() {
		level = -2;
	}

	public function draw():Void {
		level = -2;
		update();
	}

	public function update():Void {
		var draw = Watch.drawable;

		if (Watch.battery.charging()) {
			if (this.level != -1) {
				draw.blit(BatteryIcon, 239-BatteryIcon[1], 0, Wasp.system.theme.battery);
				level = -1;
			}
		} else {
			var level = Watch.battery.level();
			if (level == this.level) return;

			var green = opFloorDiv(level, 3);
			if (green > 31) green = 31;
			var red = 31 - green;
			var rgb = (red << 11) + (green << 6);

			if (this.level < 0 || ((level > 5) != (this.level > 5))) {
				if (level > 5) {
					draw.blit(BatteryIcon, 239-BatteryIcon[1], 0, Wasp.system.theme.battery);
				} else {
					rgb = 0xf800;
					draw.blit(BatteryIcon, 239-BatteryIcon[1], 0, rgb);
				}
			}

			var w = BatteryIcon[1] - 10;
			var x = 239 - 5 - w;
			var h = opFloorDiv(2 * level, 11);
			if (h > 18) draw.fill(0, x, 9, w, 18 - h);
			else draw.fill(rgb, x, 27 - h, w, h);
			this.level = level;
		}
	}
}
