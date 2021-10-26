package wash.app.system;

import python.Exceptions.BaseException;
import python.lib.Sys;
import python.lib.io.StringIO;

import wasp.Watch;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.icon.BombIcon;

@:native('CrashApp')
class CrashApp extends BaseApplication {
	var msg:String;

	public function new(e:BaseException) {
		super();
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
		Wash.system.requestEvent(EventMask.SWIPE_UPDOWN | EventMask.SWIPE_LEFTRIGHT);
	}

	override public function background():Void {
		Watch.display.mute(true);
		Watch.display.invert(true);
	}

	override public function swipe(event:TouchEvent):Bool {
		Wash.system.switchApp(new PagerApp(msg));
		return false;
	}
}
