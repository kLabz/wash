package wash.app.user.settings;

import python.Bytearray;
import python.Bytes;

import wash.app.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wasp.Fonts;
import wasp.Watch;

@:access(wash.app.user.HeartApp)
class HeartConfig extends BaseApplication implements ISettingsApplication {
	var debug:Checkbox;
	var runInBackground:Checkbox;

	public function new(_) {
		super();
		NAME = "Heart App";

		debug = new Checkbox(6, 90, "Log data");
		runInBackground = new Checkbox(6, 140, "Run in background", true);
	}

	override public function touch(event:TouchEvent):Void {
		if (debug.touch(event)) HeartApp.debug = debug.state;
		if (runInBackground.touch(event)) HeartApp.runInBackground = runInBackground.state;
	}

	public function draw():Void {
		var draw = Watch.drawable;
		draw.set_color(Wash.system.theme.highlight);
		draw.set_font(Fonts.sans24);
		draw.string(NAME, 0, 6, 240);

		debug.state = HeartApp.debug;
		runInBackground.state = HeartApp.runInBackground;

		debug.draw();
		runInBackground.draw();
	}

	public function update():Void {}

	public static function serialize(bytes:Bytearray):Void {
		bytes.append(F_LogData);
		bytes.append(HeartApp.debug ? 0x01 : 0x00);

		bytes.append(F_RunInBg);
		bytes.append(HeartApp.runInBackground ? 0x01 : 0x00);
	}

	public static function deserialize(bytes:Bytes, i:Int):Int {
		while (i < bytes.length) {
			switch (bytes.get(i++)) {
				case F_LogData:
					HeartApp.debug = bytes.get(i++) == 0x01;

				case F_RunInBg:
					HeartApp.runInBackground = bytes.get(i++) == 0x01;

				case 0x00:
					break;
			}
		}

		return i;
	}
}

private enum abstract Field(Int) to Int {
	var F_LogData = 0x01;
	var F_RunInBg = 0x02;
}
