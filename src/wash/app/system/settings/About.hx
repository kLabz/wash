package wash.app.system.settings;

import python.Syntax;

import wash.app.ISettingsApplication;
import wash.util.Version;
import wasp.Builtins;
import wasp.BLE;
import wasp.Fonts;
import wasp.Gc;
import wasp.Time;
import wasp.Watch;

using python.NativeStringTools;

class About extends BaseApplication implements ISettingsApplication {
	public function new(_) {
		super();
		NAME = "About";
	}

	public function draw():Void {
		Gc.collect();

		var memfree = Gc.mem_free();
		var mac = BLE.address();
		var uptime = Time.printDuration(Watch.rtc.uptime);
		var batteryPct = Watch.battery.level();
		var batteryMV = Watch.battery.voltage_mv();
		var version = "dev-" + Syntax.substr(Version.getGitCommitHash(), 0, 8);

		Watch.drawable.set_font(Fonts.sans24);
		Watch.drawable.set_color(Wash.system.theme.highlight);
		Watch.drawable.string('About', 0, 2, 240);

		Watch.drawable.set_font(Fonts.sans18);
		Watch.drawable.set_color(Wash.system.theme.secondary);

		var x = 2;
		var y = 40;
		var line = -1;
		Watch.drawable.string('OS', x, y + (++line * 22));
		line++; y += 10;
		Watch.drawable.string('Version', x, y + (++line * 22));
		Watch.drawable.string('BLE', x, y + (++line * 22));
		Watch.drawable.string('Battery', x, y + (++line * 22));
		Watch.drawable.string('Uptime', x, y + (++line * 22));
		Watch.drawable.string('Mem free', x, y + (++line * 22));

		Watch.drawable.set_color(Wash.system.theme.highlight);

		x = 104;
		y = 40;
		line = -1;
		Watch.drawable.string("Haxe + wasp-os", x, y + (++line * 22), 240-x, true);
		Watch.drawable.string("github.com/kLabz/wash", 0, y + 22, 240);
		line++; y += 10;
		Watch.drawable.string(version, x, y + (++line * 22), 240-x, true);
		Watch.drawable.string(mac, x, y + (++line * 22), 240-x, true);
		Watch.drawable.string('{}% - {}mV'.format(batteryPct, batteryMV), x, y + (++line * 22), 240-x, true);
		Watch.drawable.string(uptime, x, y + (++line * 22), 240-x, true);
		Watch.drawable.string(Builtins.str(memfree), x, y + (++line * 22), 240-x, true);
	}

	public function update():Void {}
}
