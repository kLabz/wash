package wash.app;

class BaseWatchFace extends BaseApplication implements IWatchFace {
	// Configuration
	public static var hours12:Bool;
	public static var displayWeekNb:Bool;
	public static var displayBatteryPct:Bool;
	public static var dblTapToSleep:Bool;

	public function preview():Void {}
}
