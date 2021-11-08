package wash.widgets;

import wasp.Watch;
import wash.icon.BleStatusIcon.icon as BleStatusIcon;
import wash.icon.NotificationIcon.icon as NotificationIcon;
import wash.util.PointTuple;

class NotificationBar implements IWidget {
	var pos:PointTuple;

	public function new(x:Int = 0, y:Int = 0) {
		pos = PointTuple.make(x, y);
	}

	public function draw():Void update();

	public function update():Void {
		var draw = Watch.drawable;

		if (Watch.connected()) {
			draw.blit(
				BleStatusIcon,
				pos.x,
				pos.y + 2,
				0,
				Wash.system.theme.primary,
				true
			);

			if (Wash.system.notifications.length > 0)
				draw.blit(
					NotificationIcon,
					pos.x+BleStatusIcon[1]+4,
					pos.y + 1,
					0,
					Wash.system.theme.primary,
					Wash.system.theme.primary,
					true
				);
			else
				draw.fill(
					Wash.system.theme.primary,
					pos.x+BleStatusIcon[1]+4,
					pos.y + 1,
					NotificationIcon[1],
					NotificationIcon[2]
				);

		} else if (Wash.system.notifications.length > 0) {
			draw.blit(
				NotificationIcon,
				pos.x,
				pos.y + 1,
				0,
				Wash.system.theme.primary,
				Wash.system.theme.primary,
				true
			);

			draw.fill(
				Wash.system.theme.primary,
				pos.x + NotificationIcon[1],
				pos.y + 1,
				BleStatusIcon[1],
				NotificationIcon[2]
			);
		} else {
			draw.fill(
				Wash.system.theme.primary,
				pos.x,
				pos.y + 1,
				BleStatusIcon[1]+NotificationIcon[1]+4,
				NotificationIcon[2]
			);
		}
	}
}
