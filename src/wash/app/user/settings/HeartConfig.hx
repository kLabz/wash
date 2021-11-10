package wash.app.user.settings;

import python.Bytearray;
import python.Syntax;
import python.lib.io.BufferedReader;
import python.lib.io.BufferedWriter;

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

	public static function serialize(f:BufferedWriter):Void {
		var bytes = new Bytearray(4);
		var i = 0;

		bytes[i++] = F_LogData;
		bytes[i++] = HeartApp.debug ? 0x01 : 0x00;

		bytes[i++] = F_RunInBg;
		bytes[i++] = HeartApp.runInBackground ? 0x01 : 0x00;

		f.write(bytes);
		bytes = null;
		Syntax.delete(bytes);
	}

	public static function deserialize(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case F_LogData:
					HeartApp.debug = f.read(1).get(0) == 0x01;

				case F_RunInBg:
					HeartApp.runInBackground = f.read(1).get(0) == 0x01;

				case 0x00:
					break;
			}
		}
	}
}

private enum abstract Field(Int) to Int {
	var F_LogData = 0x01;
	var F_RunInBg = 0x02;
}
