package wash.app.system;

import python.Syntax;

import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.ConfirmationView;
import wash.widgets.ScrollIndicator;
import wasp.Fonts;
import wasp.Watch;

using python.NativeStringTools;

@:native('NotificationApp')
class NotificationApp extends BaseApplication {
	var confirmationView:ConfirmationView;
	var scroll:ScrollIndicator;
	var i(default, set):Int;
	var current:Notification;
	var nbNotifications:Int;

	function set_i(v:Int):Int {
		i = v;
		scroll.value = i;
		current = Wash.system.notifications[i];
		return i;
	}

	public function new() {
		super();
		NAME = "NotificationApp";

		confirmationView = new ConfirmationView();
		scroll = new ScrollIndicator(26);
	}

	override public function foreground():Void {
		redraw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN | EventMask.BUTTON);
	}

	override public function background():Void {
		confirmationView.active = false;
		current = null;
	}

	override public function swipe(event:TouchEvent):Bool {
		switch (event.type) {
			case DOWN if (i == 0 && confirmationView.active):
				Watch.vibrator.pulse();

			case DOWN if (i == 0):
				confirmationView.draw('Clear notifications?');

			case DOWN:
				i--;
				draw();

			case UP if (i == 0 && confirmationView.active):
				confirmationView.active = false;
				draw();

			case UP if (i < nbNotifications - 1):
				i++;
				draw();

			case UP:
				Wash.system.navigate(BACK);

			case _:
		}

		return false;
	}

	override public function touch(event:TouchEvent):Void {
		if (confirmationView.touch(event)) {
			if (confirmationView.value) {
				Wash.system.notifications = [];
				Wash.system.navigate(BACK);
			} else {
				draw();
			}
		}
	}

	override public function press(_, state:Bool):Bool {
		if (!state) return true;
		if (confirmationView.active) return true;

		Wash.system.unnotify(current.id);
		redraw(false);
		return false;
	}

	function redraw(?warnIfEmpty:Bool = true):Void {
		nbNotifications = Wash.system.notifications.length;
		if (nbNotifications == 0) {
			if (warnIfEmpty) Watch.vibrator.pulse();
			Wash.system.navigate(BACK);
			return;
		}

		i = nbNotifications - 1;
		scroll.min = 0;
		scroll.max = i;

		draw();
	}

	function draw():Void {
		Watch.display.mute(true);
		Watch.drawable.set_font(Fonts.sans24);
		Watch.drawable.fill(Wash.system.theme.secondary, 0, 0, 240, 26);
		Watch.drawable.fill(0, 0, 26, 240, 214);
		scroll.draw();

		// TODO: TextScroller widget (width = 200)
		Watch.drawable.set_color(0, Wash.system.theme.secondary);
		var title = current.content.title;
		if (title != null && title.length > 0)
			Watch.drawable.string(current.content.title, 2, 2);
		Watch.drawable.string('{}/{}'.format(i + 1, nbNotifications), 202, 2, 36, true);

		// TODO: handle multi-screens notification body (truncated for now)
		Watch.drawable.set_color(Wash.system.theme.highlight);
		var body = current.content.body;
		if (body != null && body.length > 0) {
			var chunks = Watch.drawable.wrap(body, 232);
			var nbLines = chunks.length - 1;
			if (nbLines > 8) nbLines = 8;
			for (i in 0...nbLines) {
				var sub = Syntax.substr(body, chunks[i], chunks[i+1]).rstrip();
				Watch.drawable.string(sub, 2, 29 + 26*i);
			}
		}
		Watch.display.mute(false);
	}
}
