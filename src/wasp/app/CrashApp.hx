package wasp.app;

import python.Exceptions.BaseException;
import python.lib.Sys;
import python.lib.io.StringIO;

import wasp.event.TouchEvent;
import wasp.icon.BombIcon;

@:native('CrashApp')
class CrashApp extends BaseApplication {
	var msg:String;

	public function new(e:BaseException) {
		NAME = "Crash";
		ICON = BombIcon;

		var msg = new StringIO();
		Sys.print_exception(e, msg);
		this.msg = msg.getvalue();
		msg.close();
	}

	override public function foreground():Void {
		Watch.display.invert(false);
		Watch.drawable.blit(BombIcon, 0, 104);
		Watch.drawable.blit(BombIcon, 32, 104);
		Wasp.system.requestEvent(EventMask.SWIPE_UPDOWN | EventMask.SWIPE_LEFTRIGHT);
	}

	override public function background():Void {
		Watch.display.mute(true);
		Watch.display.invert(true);
	}

	override public function swipe(event:TouchEvent):Bool {
		Wasp.system.switchApp(new PagerApp(msg));
		return false;
	}
}
