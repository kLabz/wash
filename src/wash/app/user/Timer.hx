package wash.app.user;

import python.Syntax.bytes;

import wasp.Fonts;
import wasp.Watch;
import wasp.Builtins;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.Spinner;

using python.NativeStringTools;

private enum abstract State(Int) to Int {
	var Stopped = 0;
	var Running = 1;
	var Ringing = 2;
}

@:native('TimerApp')
class Timer extends BaseApplication {
	static inline var BUTTON_Y:Int = 180;

	var minutes:Spinner;
	var seconds:Spinner;
	var currentAlarm:Null<Int>;
	var state:State;

	public function new() {
		super();

		ID = 0x07;
		NAME = "Timer";
		ICON = bytes(
			'\\x02',
			'@@',
			"?\\xff\\xd4\\x9c$\\x9c&\\x84\\x10\\x84(\\x83\\x12\\x83\\'\\x83",
			'\\x14\\x83%\\x83\\x16\\x83$\\x82\\x18\\x82$\\x82\\x18\\x82$\\x82',
			'\\x18\\x82$\\x82\\x18\\x82$\\x82\\x18\\x82$\\x83\\x16\\x83$\\x83',
			"\\x16\\x83%\\x83\\x14\\x83&\\x83\\x14\\x83\\'\\x83\\x01@\\xacP",
			'\\x01\\x83)\\x83\\x01N\\x01\\x83+\\x83\\x01L\\x01\\x83-\\x83',
			'\\x01J\\x01\\x83/\\x83\\x01H\\x01\\x831\\x83\\x01F\\x01\\x83',
			'3\\x83\\x01D\\x01\\x835\\x82\\x01D\\x01\\x827\\x82\\x01B',
			'\\x01\\x828\\x82\\x01\\xc2\\x01\\x828\\x82\\x04\\x828\\x82\\x01\\xc1',
			'\\x02\\x827\\x82\\x06\\x825\\x83\\x03\\xc1\\x02\\x833\\x83\\x08\\x83',
			'1\\x83\\x06\\xc1\\x03\\x83/\\x83\\x0c\\x83-\\x83\\x07\\xc1\\x06\\x83',
			"+\\x83\\x10\\x83)\\x83\\x12\\x83\\'\\x83\\x0b\\xc1\\x08\\x83&\\x83",
			'\\x14\\x83%\\x83\\x16\\x83$\\x83\\x16\\x83$\\x82\\r\\xc1\\n\\x82',
			'$\\x82\\x0cC\\t\\x82$\\x82\\x0bE\\x08\\x82$\\x82\\tH',
			'\\x07\\x82$\\x82\\x06L\\x06\\x82$\\x83\\x01T\\x01\\x83%\\x83',
			"\\x01R\\x01\\x83\\'\\x83\\x01P\\x01\\x83(\\x84\\x10\\x84&\\x9c",
			'$\\x9c?\\xffT'
		);

		minutes = new Spinner(50, 50, 0, 99, 2);
		seconds = new Spinner(130, 50, 0, 59, 2);
		currentAlarm = null;
		minutes.value = 10;
		state = Stopped;
	}

	override public function foreground():Void {
		draw();
		Wash.system.requestEvent(EventMask.TOUCH);
		Wash.system.requestTick(1000);
	}

	override public function background():Void {
		if (state == Ringing) state = Stopped;
	}

	override public function tick(_):Void {
		if (state == Ringing) {
			Watch.vibrator.pulse(50, 500);
			Wash.system.keepAwake();
		}

		update();
	}

	override public function touch(event:TouchEvent):Void {
		switch (state) {
			case Ringing:
				Watch.display.mute(true);
				stop();
				Watch.display.mute(false);

			case Running:
				stop();

			case Stopped:
				if (!minutes.touch(event) && !seconds.touch(event)) {
					if (event.y >= BUTTON_Y) start();
				}
		}
	}

	function start():Void {
		state = Running;
		var now = Watch.rtc.time();
		currentAlarm = now + minutes.value * 60 + seconds.value;
		Wash.system.setAlarm(currentAlarm, alert);
		draw();
	}

	function stop():Void {
		state = Stopped;
		Wash.system.cancelAlarm(currentAlarm, alert);
		draw();
	}

	function alert():Void {
		state = Ringing;
		Wash.system.wake();
		if (Wash.system.isActive(this)) draw();
		else Wash.system.switchApp(this);
	}

	function update():Void {
		Wash.system.bar.update();

		if (state == Running) {
			var draw = Watch.drawable;
			var now = Watch.rtc.time();
			var s = currentAlarm - now;
			if (s < 0) s = 0;
			var m = opFloorDiv(s, 60);
			var s = Builtins.int(s) % 60;

			draw.set_font(Fonts.sans28);
			draw.set_color(Wash.system.theme.highlight);
			draw.string('{:02}'.format(m), 50, 120-24, 60);
			draw.string('{:02}'.format(s), 130, 120-24, 60);
		}
	}

	function draw():Void {
		var draw = Watch.drawable;
		draw.fill(0);

		Wash.system.bar.displayClock = true;
		Wash.system.bar.draw();
		draw.set_color(Wash.system.theme.highlight);

		switch (state) {
			case Ringing:
				draw.set_font(Fonts.sans24);
				draw.string(NAME, 0, 140, 240);
				draw.blit(ICON, 89, 54, Wash.system.theme.highlight, Wash.system.theme.secondary, Wash.system.theme.primary, true);

			case Running:
				drawStop(104, BUTTON_Y);
				draw.set_font(Fonts.sans28);
				draw.string(':', 110, 120-24, 20);
				update();

			case Stopped:
				draw.set_font(Fonts.sans28);
				draw.string(':', 110, 120-24, 20);
				minutes.draw();
				seconds.draw();
				drawPlay(114, BUTTON_Y);
		}
	}

	function drawPlay(x:Int, y:Int):Void {
		for (i in 0...20)
			Watch.drawable.fill(Wash.system.theme.highlight, x+i, y+i, 1, 40-2*i);
	}

	function drawStop(x:Int, y:Int):Void {
		Watch.drawable.fill(Wash.system.theme.highlight, x, y, 40, 40);
	}
}
