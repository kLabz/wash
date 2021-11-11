package wash.widgets;

import python.Bytes;
import python.Syntax;

import wasp.Watch;
import wash.icon.BleStatusIcon;
import wash.icon.NotificationIcon;
import wash.util.PointTuple;

class NotificationBar implements IWidget {
	var pos:PointTuple;
	var bleIcon:Bytes;
	var notifIcon:Bytes;

	public function new(x:Int = 0, y:Int = 0) {
		pos = PointTuple.make(x, y);
		bleIcon = BleStatusIcon.getIcon();
		notifIcon = NotificationIcon.getIcon();
	}

	public function dispose():Void {
		bleIcon = null;
		notifIcon = null;
		Syntax.delete(bleIcon);
		Syntax.delete(notifIcon);
	}

	public function draw():Void update();

	public function update():Void {
		var draw = Watch.drawable;

		if (Watch.connected()) {
			draw.blit(
				bleIcon,
				pos.x,
				pos.y + 2,
				0,
				Wash.system.theme.primary,
				true
			);

			if (Wash.system.notifications.length > 0)
				draw.blit(
					notifIcon,
					pos.x+bleIcon[1]+4,
					pos.y + 1,
					0,
					Wash.system.theme.primary,
					Wash.system.theme.primary,
					true
				);
			else
				draw.fill(
					Wash.system.theme.primary,
					pos.x+bleIcon[1]+4,
					pos.y + 1,
					notifIcon[1],
					notifIcon[2]
				);
		} else if (Wash.system.notifications.length > 0) {
			draw.blit(
				notifIcon,
				pos.x,
				pos.y + 1,
				0,
				Wash.system.theme.primary,
				Wash.system.theme.primary,
				true
			);

			draw.fill(
				Wash.system.theme.primary,
				pos.x + notifIcon[1],
				pos.y + 1,
				bleIcon[1],
				notifIcon[2]
			);
		} else {
			draw.fill(
				Wash.system.theme.primary,
				pos.x,
				pos.y + 1,
				bleIcon[1]+notifIcon[1]+4,
				notifIcon[2]
			);
		}
	}
}
