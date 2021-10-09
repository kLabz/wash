package wasp.app;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.opFloorDiv;

import wasp.app.IApplication;
import wasp.icon.AppIcon;
import wasp.widgets.ScrollIndicator;

@:native('LauncherApp')
class Launcher implements IApplication {
	public var NAME(default, null):String = "Launcher";
	public var ICON(default, null):Bytes = bytes(
		'\\x02',
		'@@',
		'?\\xff\\x88@\\xc1t\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0cA2A\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0cA2A\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0cA2A\\x0cA2A\\x0cA\\x03\\x80\\xc6\\xac',
		'\\x03A\\x0cA2A\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0cA\\x04\\xc9\\x03\\xc5\\x04\\xc6\\x07\\xc5\\x07A\\x0cA',
		'\\x04\\xc9\\x02\\xc7\\x03\\xc8\\x04\\xc7\\x06A\\x0cA\\x07\\xc3\\x05\\xc3',
		'\\x01\\xc3\\x03\\xc3\\x02\\xc3\\x04\\xc3\\x01\\xc3\\x06A\\x0cA\\x07\\xc3',
		'\\x04\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x05A\\x0cA',
		'\\x07\\xc3\\x04\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x05A',
		'\\x0cA\\x07\\xc3\\x04\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3',
		'\\x05A\\x0cA\\x07\\xc3\\x04\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x02\\xc3',
		'\\x03\\xc3\\x05A\\x0cA\\x07\\xc3\\x04\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3',
		'\\x02\\xc3\\x03\\xc3\\x05A\\x0cA\\x07\\xc3\\x04\\xc3\\x03\\xc3\\x02\\xc3',
		'\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x05A\\x0cA\\x07\\xc3\\x04\\xc3\\x03\\xc3',
		'\\x02\\xc3\\x03\\xc3\\x02\\xc3\\x03\\xc3\\x05A\\x0cA\\x07\\xc3\\x05\\xc3',
		'\\x01\\xc3\\x03\\xc3\\x02\\xc3\\x04\\xc3\\x01\\xc3\\x06A\\x0cA\\x07\\xc3',
		'\\x05\\xc7\\x03\\xc8\\x04\\xc7\\x06A\\x0cA\\x07\\xc3\\x06\\xc5\\x04\\xc6',
		'\\x07\\xc5\\x07A\\x0cA2A\\x0cA2A\\x0cA2A',
		'\\x0cA2A\\x0cA\\x03\\xac\\x03A\\x0cA2A\\x0cA',
		'2A\\x0cA2A\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0cA2A\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0cA2A\\x0cA2A\\x0cA2A\\x0cA',
		'2A\\x0ct?\\xff\\x08'
	);

	var page:Int;
	var numPages(get, null):Int;
	var scroll:ScrollIndicator;
	function get_numPages():Int return opFloorDiv(Manager.launcher_ring.length + 8, 9);

	public function new() {
		scroll = new ScrollIndicator(null, 6);
		page = 0;
	}

	public function foreground():Void {
		page = 0;
		draw();
		Manager.request_event(EventMask.TOUCH | EventMask.SWIPE_UPDOWN);
	}

	public function background():Void {}

	public function swipe(event:Array<Int>):Void {
		var i = page;
		var n = numPages;

		if (event[0] == EventType.UP) {
			i++;
			if (i >= n) return Watch.vibrator.pulse();
		} else {
			i--;
			if (i < 0) return Manager.switchApp(Manager.quick_ring[0]);
		}

		page = i;
		// Watch.display.mute(true);
		draw();
		// Watch.display.mute(false);
	}

	public function touch(event:Array<Int>):Void {
		var page = getPage(page);
		var x = event[1];
		var y = event[2];
		var app = page[3 * opFloorDiv(y, 74) + opFloorDiv(x, 74)];
		if (app != null) Manager.switchApp(app);
		else Watch.vibrator.pulse();
	}

	function getPage(i:Int):Array<IApplication> {
		var ret = Manager.launcher_ring.slice(9*i, 9*(i+1));
		while (ret.length < 9) ret.push(null);
		return ret;
	}

	function draw():Void {
		var pageNum = page;
		var page = getPage(pageNum);

		Watch.drawable.fill();
		for (i in 0...3)
			for (j in 0...3)
				drawApp(page[i*3 + j], j*74, i*74);

		scroll.up = pageNum > 0;
		scroll.down = pageNum < (numPages - 1);
		scroll.draw();
	}

	function drawApp(app:IApplication, x:Int, y:Int):Void {
		if (app == null) return;

		Watch.drawable.blit(app.ICON == null ? AppIcon : app.ICON, x+14, y+14);
	}
}
