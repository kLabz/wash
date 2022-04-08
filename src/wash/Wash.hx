package wash;

import wash.Notification;

@:python('noImportFrom')
@:python('dotpath(wasp.Wasp)')
@:native('wasp.Wasp')
class Wash {
	@:keep
	public static var system(default, null):Manager;

	@:keep
	public static function init():Void {
		if (system == null) {
			MacroUtils.localImport(Manager);
			system = new Manager();
			system.init();
		}
	}
}

@:native('system')
private class System {
	@:keep
	public static function schedule():Void {
		Wash.init();
		Wash.system.schedule(true);
	}

	@:keep
	public static function notify(id:Int, notif:NotificationContent):Void {
		Wash.system.notify(id, notif);
	}

	@:keep
	public static function unnotify(id:Int):Void {
		Wash.system.unnotify(id);
	}
}
