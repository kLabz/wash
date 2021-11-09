package wash.app.user;

import python.Bytes;
import python.Syntax.bytes;

import wash.Wash;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.icon.AppIcon;
import wash.widgets.Button;
import wasp.Fonts;
import wasp.Time;
import wasp.Watch;

@:native('NightModeApp')
class NightMode extends BaseApplication {
	static var dayBg:Bytes = bytes(
		'\\x02',
		'dS',
		'@\\xacv\\xcc\\x7f\\x15\\xd4\\x7f\\x0f\\xd8\\x7f\\x0b\\xdc\\x7f\\x07\\xe0',
		'\\x7f\\x03\\xe4\\x7f\\x00\\xe6}\\xe8z\\xecw\\xeeu\\xf0t\\xf0',
		's\\xf2q\\xf4o\\xf6n\\xf6m\\xf8l\\xf8k\\xfaj\\xfa',
		'i\\xfch\\xfcg\\xfef\\xfef\\xfef\\xfee\\xff\\x01d',
		'\\xef\\x87\\xcad\\xec\\x8d\\xc7d\\xea\\x91\\xc5d\\xe9\\x93\\xc4d',
		'\\xe8\\x95\\xc3d\\xe7\\x97\\xc2d\\xe6\\x99\\xc1d\\xe5\\x9bd\\xe4',
		'\\x9dc\\xe4\\x9dc\\xe3\\x9fc\\xce\\x8a\\xca\\x9fc\\xcb\\x90\\xc6',
		'\\xa1b\\xc9\\x94\\xc4\\xa1b\\xc8\\x96\\xc3\\xa1c\\xc6\\x98\\xc1\\xa3',
		'b\\xc5\\xbdc\\xc3\\xbec\\xc2\\xbf\\x00T\\x8aF\\xc1\\xbf\\x00',
		'P\\x92B\\xbf\\x01N\\xbf\\x17A\\x83H\\xbf\\x1dG\\xbf\\x1e',
		'F\\xbf\\x1fE\\xbf D\\xbf!C\\xbf"B\\xbf#B',
		"\\xbf#A\\xbf$A\\xbf\\xff\\xff\\xffGA\\xbf$A\\xbf",
		"$B\\xbf#B\\xbf#C\\xbf\"D\\xbf\\x15A\\x8bE",
		'\\xbf\\x13C\\x8aF\\xbf\\x11E\\x89G\\xbf\\x0fH\\x87H\\xbf',
		'\\x0cK\\x86J\\xbf\\tO\\x83L\\xbf\\x04e\\x8aF\\xadz',
		'\\xa7\\x7f\\x02\\x9f\\x7f\\r\\x91e'
	);

	static var nightBg:Bytes = bytes(
		'\\x02',
		'\\xf0h',
		'?\\xff\\xff\\x12\\xc1?b\\xc1?\\r\\xc3?`\\xc3?\\r',
		'\\xc1?b\\xc1?\\xff-\\xc3+\\xc1?\\x81\\xc5)\\xc3\\x12',
		'\\xc1?m\\xc5*\\xc1\\x12\\xc3?l\\xc5>\\xc1?n\\xc3',
		'$\\xc1?%\\xc1?J\\xc3?#\\xc3?J\\xc1?%',
		'\\xc1?\\xffy\\xc1?\\xaf\\xc3?\\xaf\\xc1?\\xff0\\xc1?',
		'\\xaf\\xc3\\x19\\xc1?\\x95\\xc1\\x19\\xc3?\\xaf\\xc1?\\xffM\\xc1',
		"?D\\xc3?)\\xc3?*\\xc1\\x17\\xc5?)\\xc1?\\'",
		'\\xc4\\x18\\xc5?\\x8e\\xc5\\x19\\xc5.\\xc3?[\\xc6\\x1b\\xc3.',
		'\\xc5?X\\xc7?\\x0e\\xc5?V\\xc8?\\x0f\\xc5?U\\xc8',
		'?\\x11\\xc3?\\x1a\\xc1:\\xc8?+\\xc1?\\x02\\xc37\\xca',
		'?*\\xc3?\\x02\\xc17\\xca?,\\xc1?:\\xca?\\xa7',
		'\\xca?\\xa6\\xcb?\\xa5\\xcb?\\xa5\\xcc/\\xc1?\\x13\\xc1?',
		'"\\xcb/\\xc3?\\x11\\xc3? \\xcc0\\xc1?\\x13\\xc1?',
		'!\\xcc?\\xa4\\xcd??\\xc1?%\\xcc??\\xc3?#',
		'\\xcd?@\\xc1?\\x07\\xc1\\x1c\\xcd?Y\\xc1,\\xc3\\x1a\\xce',
		'?X\\xc3,\\xc1\\x1b\\xce?Y\\xc1?\\n\\xce?\\xa3\\xce',
		'?\\xa2\\xcf? \\xc1?B\\xcf?\\x1f\\xc3?A\\xcf?',
		' \\xc1?B\\xcf?\\xa2\\xd0?\\xa1\\xd0?\\xa1\\xd0?\\xa1',
		'\\xd0?\\xa1\\xd1?\\xa0\\xd1?\\x02\\xc1?^\\xd2?\\x00\\xc3',
		'?]\\xd2?\\x01\\xc1?_\\xd1?\\xa0\\xd2?\\x19\\xc3?',
		'D\\xd3?\\x17\\xc5?C\\xd3?\\x17\\xc5?\\x17\\xc1,\\xd3',
		'?\\x16\\xc5?\\x16\\xc3+\\xd4?\\x16\\xc3?\\x18\\xc1-\\xd4',
		'?\\x9d\\xd5?\\x9d\\xd5%\\xc1?v\\xd6#\\xc3?v\\xd6',
		'#\\xc1?w\\xd7?\\x9b\\xd8?\\x9a\\xd8?\\x9a\\xda?\\x97',
		'\\xdc\\x13\\xc1?\\x82\\xdf\\x0b\\xc4?\\x84\\xec?\\x87\\xe8?\\x8a',
		'\\xe6?\\x8c\\xe4?\\x8f\\xe0?\\x93\\xdc?\\x85\\xc1\\x11\\xd8?',
		'\\x86\\xc3\\x12\\xd4?\\x89\\xc1\\x17\\xcc?\\xdf\\xc3?\\xad\\xc5\\x13',
		'\\xc1?\\x98\\xc5\\x12\\xc3?4\\xc1?\\x10\\xc1\\x12\\xc5\\x13\\xc1',
		'?4\\xc3?\\x0e\\xc3\\x12\\xc3?J\\xc1?\\x10\\xc1?\\xff',
		'\\x95\\xc1?\\xaf\\xc3?\\xaf\\xc1?\\x16\\xc3?\\xad\\xc5?\\xac',
		'\\xc5?\\xac\\xc5?\\xad\\xc3?\\xff]'
	);

	var toggleButton:Button;
	var alarmsButton:Button;

	public function new() {
		super();

		NAME = "NightMode";
		ICON = AppIcon;
		ID = 0x04;
	}

	override public function foreground():Void {
		toggleButton = new Button(8, 78, 120, 28, "TOGGLE");
		alarmsButton = new Button(10, 194, 220, 34, "EDIT ALARMS");
		draw();
		Wash.system.requestEvent(EventMask.TOUCH);
	}

	override public function background():Void {
		toggleButton = null;
		alarmsButton = null;
	}

	override public function touch(event:TouchEvent):Void {
		if (toggleButton.touch(event)) {
			Wash.system.nightMode = !Wash.system.nightMode;
			return draw();
		}

		if (alarmsButton.touch(event)) {
			Wash.system.switchApp(AlarmApp.getInstance());
		}
	}

	function draw():Void {
		var draw = Watch.drawable;
		Watch.display.mute(true);

		if (Wash.system.nightMode) {
			draw.fill(0);
			draw.fill(Wash.system.theme.primary, 0, 113, 240, 2);
			draw.recolor(nightBg, 0, 0);
		} else {
			draw.fill(Wash.system.theme.secondary, 0, 0, 240, 113);
			draw.fill(Wash.system.theme.primary, 0, 113, 240, 2);
			draw.fill(0, 0, 115, 240, 240 - 115);
			draw.recolor(dayBg, 140, 25);
		}

		toggleButton.draw();

		draw.set_color(Wash.system.theme.secondary);
		draw.set_font(Fonts.sans24);
		draw.string('Next alarm:', 0, 130, 240);

		draw.set_color(Wash.system.theme.highlight);
		var next = AlarmApp.nextAlarm();

		var txt = "None";
		if (next != null) {
			if (next - Time.time() > 86400) txt = 'None in 24h';
			else txt = Time.printHour(Time.localtime(next));
		}

		draw.string(txt, 0, 160, 240);
		alarmsButton.draw();

		Watch.display.mute(false);
	}
}
