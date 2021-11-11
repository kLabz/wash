package wash.app.user;

// import python.Bytes;
// import python.Syntax.bytes;

import wasp.Builtins;
import wash.Wash;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.icon.AppIcon;
import wash.util.DateTimeTuple;
import wash.widgets.ScrollIndicator;
import wasp.Fonts;
import wasp.Time;
import wasp.Watch;

using python.NativeStringTools;

@:native('StepCounter')
class StepCounter extends BaseApplication {
	var scroll:ScrollIndicator;
	var wakeTime:Float;
	var page:Int;

	public function new() {
		super();

		ID = 0x05;
		NAME = "Steps";
		ICON = AppIcon.getIcon();

		Watch.accel.reset();
		scroll = new ScrollIndicator(28, 0, 7, 0);
		wakeTime = 0;
	}

	override public function foreground():Void {
		Wash.system.cancelAlarm(wakeTime, reset);
		Wash.system.bar.displayClock = true;
		page = -1;
		draw();
		Wash.system.requestEvent(SWIPE_UPDOWN);
		Wash.system.requestTick(1000);
	}

	override public function background():Void {
		var now = Watch.rtc.get_localtime();
		var then = DateTimeTuple.make(now.yyyy, now.mm, now.dd + 1, 0, 0, 0, 0, 0);
		wakeTime = Time.mktime(then);
		Wash.system.setAlarm(wakeTime, reset);
	}

	function reset():Void {
		Watch.accel.steps = 0;
		wakeTime += 24 * 60 * 60;
		Wash.system.setAlarm(wakeTime, reset);
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case DOWN if (page == -1):
				Watch.vibrator.pulse();
				return false;

			case UP if (page >= 6):
				Watch.vibrator.pulse();
				return false;

			case DOWN: page--;
			case UP: page++;
			case _:
		}

		Watch.display.mute(true);
		draw();
		Watch.display.mute(false);
		return false;
	}

	override public function tick(_):Void if (page == -1) update();

	function draw():Void {
		Watch.drawable.fill(0);

		if (page == -1) {
			update();
			Wash.system.bar.draw();
		} else {
			updateGraph();
		}
	}

	function update():Void {
		var draw = Watch.drawable;
		Wash.system.bar.update();

		draw.recolor(ICON, 4, 132-32);

		var count = Watch.accel.steps;
		var t = Builtins.str(count);
		var w = Fonts.width(Fonts.sans36, t);
		draw.set_font(Fonts.sans36);
		draw.set_color(Wash.system.theme.secondary);
		draw.string(t, 228-w, 132-18); // TODO: use right align?

		scroll.value = 0;
		scroll.draw();
	}

	function updateGraph():Void {
		var draw = Watch.drawable;
		draw.set_font(Fonts.sans24);
		draw.set_color(Wash.system.theme.highlight);

		// Draw the date
		var now = Builtins.int(Watch.rtc.time());
		var then = now - ((24*60*60) * page);
		var walltime = Time.localtime(then);
		draw.string('Steps for {:02d}/{:02d}'.format(walltime.dd, walltime.mm), 10, 10, 220);

		var data = null; // logger.data(then); // TODO
		if (data == null) {
			draw.set_color(Wash.system.theme.secondary);
			draw.string('No data', 10, 110, 220);
		}

		// TODO: display graph, but will need logger first..

		scroll.value = page + 1;
		scroll.draw();
	}
}
