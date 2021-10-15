package app;

import python.Bytes;
import python.Syntax.bytes;

import wasp.EventMask;
import wasp.Wasp;
import wasp.Watch;
import wasp.app.BaseApplication;

@:native('TorchApp')
class Torch extends BaseApplication {
	static var icon:Bytes = bytes(
		'\\x02',
		'`@',
		'?\\xff\\xff\\xff\\xff\\xff\\xff\\xff&\\xc6\\x0c@\\xd4B?\\n',
		'\\xca\\tD?\\x08\\xc4\\x06\\xc2\\x07F?\\x07\\xc3\\x07\\xc2\\x06',
		'H?\\x06\\xc2\\n\\xc1\\x04G\\xc2A8\\xc5\\x08\\xc2\\t\\xc2',
		'\\x02F\\xc3C7\\xc7\\x06\\xc2\\x0b\\xc1F\\xc2F\\x1e\\xe8\\n',
		'\\xc2C\\xc3H\\x1d\\xe8\\x0c\\xc1N\\x1d\\xc2%\\xc1\\x0b\\xc2N',
		'\\x1d\\xc2%\\xc1\\x0c\\xc1N\\x1d\\xc2\\x04\\x9d\\x04\\xc1\\x0b\\xc2N',
		'\\x1d\\xc2\\x06\\x81\\x03\\x81\\x03\\x81\\x03\\x81\\x03\\x81\\x03\\x81\\x03\\x81',
		'\\x06\\xc1\\x0c\\xc1N\\x1d\\xc2\\x04\\x9d\\x04\\xc1\\x0b\\xc2C\\xcaA',
		'\\x1d\\xc2\\x06\\x81\\x03\\x81\\x03\\x81\\x03\\x81\\x03\\x81\\x03\\x81\\x03\\x81',
		'\\x06\\xc1\\x0c\\xc1N\\x1d\\xc2\\x04\\x9d\\x04\\xc1\\x0b\\xc2N\\x1d\\xc2',
		'%\\xc1\\x0c\\xc1N\\x1d\\xc2%\\xc1\\x0b\\xc2N\\x1d\\xe8\\x0c\\xc1',
		'N\\x1e\\xe8\\n\\xc2C\\xc3H?\\x05\\xc2\\x0b\\xc1F\\xc2F',
		'?\\x06\\xc2\\t\\xc2\\x02F\\xc3C?\\x06\\xc2\\n\\xc1\\x04G',
		'\\xc2A?\\x07\\xc3\\x07\\xc2\\x06H?\\x08\\xc4\\x06\\xc2\\x07F',
		'?\\n\\xca\\tD?\\r\\xc6\\x0cB?\\xff\\xff\\xff\\xff\\xff',
		'\\xff\\x95'
	);

	private var activated:Bool;
	private var brightness:Int;

	public function new() {
		NAME = "Torch";
		ICON = icon;
		activated = false;
		brightness = Wasp.system.brightness;
	}

	override public function foreground():Void {
		brightness = Wasp.system.brightness;
		draw();
		Wasp.system.requestTick(1000);
		Wasp.system.requestEvent(EventMask.TOUCH | EventMask.BUTTON);
	}

	override public function background():Void {
		activated = false;
		Wasp.system.brightness = brightness;
	}

	override public function tick(ticks:Int):Void {
		Wasp.system.keepAwake();
	}

	override public function touch(_):Void {
		activated = !activated;
		draw();
	}

	override public function press(_, state:Bool):Bool {
		if (!state) return true;
		activated = !activated;
		draw();
		return false;
	}

	function draw():Void {
		if (activated) {
			Watch.drawable.fill(0xffff);
			drawTorch(0, 0);
			Wasp.system.brightness = 3;
		} else {
			Watch.drawable.fill();
			drawTorch(Wasp.system.theme.mid, 0xffff);
			Wasp.system.brightness = brightness;
		}
	}

	function drawTorch(torch:Int, light:Int):Void {
		var draw = Watch.drawable;
		var x = 108;

		draw.fill(torch, x, 107, 24, 9);
		for (i in 1...8)
			draw.line(x+i, 115+i, x+23-i, 115+i, 1, torch);
		draw.fill(torch, x+8, 123, 8, 15);

		draw.line(x-3, 94, x+5, 102, 2, light);
		draw.line(x+17, 102, x+25, 94, 2, light);
		draw.line(x+11, 89, x+11, 100, 2, light);
	}
}
