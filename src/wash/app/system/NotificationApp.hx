package wash.app.system;

import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.ConfirmationView;
import wasp.Builtins.next;

using python.NativeArrayTools;
using python.NativeStringTools;

@:native('NotificationApp')
class NotificationApp extends PagerApp {
	var confirmationView:ConfirmationView;

	public function new() {
		super("");
		NAME = "NotificationApp";
		confirmationView = new ConfirmationView();
	}

	override public function foreground():Void {
		var notes = Wash.system.notifications;
		var note = notes.pop(next(notes.iter()));
		var title = note.title == null ? "Untitled" : note.title;
		var body = note.body == null ? "" : note.body;
		msg = '{}\n\n{}'.format(title, body);

		Wash.system.requestEvent(EventMask.TOUCH);
		super.foreground();
	}

	override public function background():Void {
		confirmationView.active = false;
		super.background();
	}

	override public function swipe(event:TouchEvent):Bool {
		if (confirmationView.active) {
			if (event.type == UP) {
				confirmationView.active = false;
				draw();
				return false;
			}
		} else {
			if (event.type == DOWN && page == 0) {
				confirmationView.draw('Clear notifications?');
				return false;
			}
		}

		return super.swipe(event);
	}

	override public function touch(event:TouchEvent):Void {
		if (confirmationView.touch(event)) {
			if (confirmationView.value) {
				Wash.system.notifications.clear();
				Wash.system.navigate(BACK);
			} else {
				draw();
			}
		}
	}
}
