package wasp.app;

import wasp.event.TouchEvent;
import wasp.widgets.ConfirmationView;

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
		var notes = Wasp.system.notifications;
		var note = notes.last();
		var title = note.title == null ? "Untitled" : note.title;
		var body = note.body == null ? "" : note.body;
		msg = '{}\n\n{}'.format(title, body);

		Wasp.system.requestEvent(EventMask.TOUCH);
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
				Wasp.system.notifications = [];
				Wasp.system.navigate(BACK);
			} else {
				draw();
			}
		}
	}
}
