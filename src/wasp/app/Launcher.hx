package wasp.app;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.opFloorDiv;

import wasp.event.TouchEvent;
import wasp.icon.AppIcon;
import wasp.widgets.ScrollIndicator;

@:native('LauncherApp')
class Launcher extends BaseApplication {
	static var icon:Bytes = bytes(
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
	function get_numPages():Int return opFloorDiv(Wasp.system.launcherRing.length + 8, 9);

	public function new() {
		NAME = "Launcher";
		ICON = icon;
		scroll = new ScrollIndicator(null, 6);
		page = 0;
	}

	override public function foreground():Void {
		page = 0;
		draw();
		Wasp.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN);
	}

	override public function background():Void {}

	override public function swipe(event:TouchEvent):Bool {
		var i = page;
		var n = numPages;

		if (event.type == UP) {
			i++;
			if (i >= n) {
				Watch.vibrator.pulse();
				return false;
			}
		} else {
			i--;
			if (i < 0) {
				Wasp.system.switchApp(Wasp.system.quickRing[0]);
				return false;
			}
		}

		page = i;
		// Watch.display.mute(true);
		draw();
		// Watch.display.mute(false);

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		var page = getPage(page);
		var app = page[3 * opFloorDiv(event.y, 74) + opFloorDiv(event.x, 74)];
		if (app != null) Wasp.system.switchApp(app);
		else Watch.vibrator.pulse();
	}

	function getPage(i:Int):Array<IApplication> {
		var ret = Wasp.system.launcherRing.slice(9*i, 9*(i+1));
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

		Watch.drawable.blit(
			app.ICON == null ? AppIcon : app.ICON,
			x+14,
			y+14,
			// Force recoloring of icons with theme colors
			Wasp.system.theme.bright,
			Wasp.system.theme.mid,
			Wasp.system.theme.ui,
			true
		);
	}
}
