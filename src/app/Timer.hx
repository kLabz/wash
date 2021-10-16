package app;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.opFloorDiv;

import wasp.EventMask;
import wasp.Fonts;
import wasp.Wasp;
import wasp.Watch;
import wasp.app.BaseApplication;
import wasp.event.TouchEvent;
import wasp.widgets.Spinner;

using python.NativeStringTools;

private enum abstract State(Int) to Int {
	var Stopped = 0;
	var Running = 1;
	var Ringing = 2;
}

@:native('Timer')
class Timer extends BaseApplication {
	static inline var BUTTON_Y:Int = 200;

	static var icon:Bytes = bytes(
		'\\x02',
		'@@',
		'?\\xff\\xff\\x15\\x9c%\\x9a\\\'\\x82\\x14\\x82(\\x81\\x16\\x81\\\'',
		'\\x81\\x18\\x81&\\x81\\x18\\x81%\\x81\\x1a\\x81$\\x81\\x1a\\x81$',
		'\\x81\\x1a\\x81$\\x81\\x1a\\x81$\\x81\\x1a\\x81$\\x81\\x1a\\x81$',
		'\\x81\\x02@\\xacV\\x02\\x81%\\x81\\x01V\\x01\\x81&\\x81\\x02',
		'T\\x02\\x81\\\'\\x81\\x02R\\x02\\x81)\\x81\\x03N\\x03\\x81+',
		'\\x82\\x03J\\x03\\x82.\\x82\\x02H\\x02\\x822\\x81\\x02F\\x02',
		'\\x815\\x81\\x02D\\x02\\x817\\x81\\x02B\\x02\\x819\\x81\\x01',
		'B\\x01\\x81:\\x81\\x04\\x81;\\x81\\x02\\x81;\\x81\\x04\\x81:',
		'\\x81\\x04\\x819\\x81\\x02\\xc1\\x03\\x817\\x81\\x08\\x815\\x81\\x05',
		'\\xc1\\x04\\x812\\x82\\x0c\\x82.\\x82\\x07\\xc1\\x08\\x82+\\x81\\x14',
		'\\x81)\\x81\\x16\\x81\\\'\\x81\\x0c\\xc1\\x0b\\x81&\\x81\\x18\\x81%',
		'\\x81\\x1a\\x81$\\x81\\x1a\\x81$\\x81\\rA\\x0c\\x81$\\x81\\x0c',
		'C\\x0b\\x81$\\x81\\x0bE\\n\\x81$\\x81\\tH\\t\\x81$',
		'\\x81\\x06L\\x08\\x81%\\x81\\x02T\\x02\\x81&\\x81\\x02T\\x02',
		'\\x81\\\'\\x81\\x02R\\x02\\x81(\\x82\\x14\\x82\\\'\\x9a%\\x9c?',
		'\\xffT'
	);

	var minutes:Spinner;
	var seconds:Spinner;
	var currentAlarm:Null<Int>;
	var state:State;

	public function new() {
		NAME = "Timer";
		ICON = icon;

		minutes = new Spinner(50, 60, 0, 99, 2);
		seconds = new Spinner(130, 60, 0, 59, 2);
		currentAlarm = null;
		minutes.value = 10;
		state = Stopped;
	}

	override public function foreground():Void {
		draw();
		Wasp.system.requestEvent(EventMask.TOUCH);
		Wasp.system.requestTick(1000);
	}

	override public function background():Void {
		if (state == Ringing) state = Stopped;
	}

	override public function tick(_):Void {
		if (state == Ringing) {
			Watch.vibrator.pulse(50, 500);
			Wasp.system.keepAwake();
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
		Wasp.system.setAlarm(currentAlarm, alert);
		draw();
	}

	function stop():Void {
		state = Stopped;
		Wasp.system.cancelAlarm(currentAlarm, alert);
		draw();
	}

	function alert():Void {
		state = Ringing;
		Wasp.system.wake();
		if (Wasp.system.isActive(this)) draw();
		else Wasp.system.switchApp(this);
	}

	function update():Void {
		Wasp.system.bar.update();

		if (state == Running) {
			var draw = Watch.drawable;
			var now = Watch.rtc.time();
			var s = currentAlarm - now;
			if (s < 0) s = 0;
			var m = opFloorDiv(s, 60);
			var s = Math.floor(s) % 60;
			draw.set_font(Fonts.sans28);
			draw.string('{:02}'.format(m), 50, 120-14, 60);
			draw.string('{:02}'.format(s), 130, 120-14, 60);
		}
	}

	function draw():Void {
		var draw = Watch.drawable;
		draw.fill();

		Wasp.system.bar.displayClock = true;
		Wasp.system.bar.draw();

		switch (state) {
			case Ringing:
				draw.set_font(Fonts.sans24);
				draw.string(NAME, 0, 150, 240);
				draw.blit(icon, 89, 54, Wasp.system.theme.bright, Wasp.system.theme.mid, Wasp.system.theme.ui, true);

			case Running:
				drawStop(104, BUTTON_Y);
				draw.string(':', 110, 120-14, 20);
				update();

			case Stopped:
				draw.set_font(Fonts.sans28);
				draw.string(':', 110, 120-14, 20);
				minutes.draw();
				seconds.draw();
				drawPlay(114, BUTTON_Y);
		}
	}

	function drawPlay(x:Int, y:Int):Void {
		for (i in 0...20)
			Watch.drawable.fill(0xffff, x+i, y+i, 1, 40-2*i);
	}

	function drawStop(x:Int, y:Int):Void {
		Watch.drawable.fill(0xffff, x, y, 40, 40);
	}
}
