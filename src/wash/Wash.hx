package wash;

@:native('Wasp')
class Wash {
	@:keep
	public static var system(default, null):Manager;

	@:keep
	public static function init():Void {
		if (system == null) {
			system = new Manager();
			system.init();
		}
	}
}

@:native('system')
class System {
	@:keep
	public static function schedule():Void {
		Wash.init();
		Wash.system.schedule(true);
	}
}
