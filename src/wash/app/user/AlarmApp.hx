// package wash.app.user;

// import python.Bytearray;
// import python.Syntax.bytes;
// import python.Syntax.delete;
// import python.Tuple;

// import wash.Wash;
// import wash.app.system.DataVault;
// import wash.app.user.alarm.DayButtons;
// import wash.event.EventMask;
// import wash.event.TouchEvent;
// import wash.util.DateTimeTuple;
// import wash.widgets.Button;
// import wash.widgets.Checkbox;
// import wash.widgets.Spinner;
// import wasp.Fonts;
// import wasp.Watch;
// import wasp.Builtins;
// import wasp.Time;

// using python.NativeStringTools;

// enum abstract RepetitionFlag(Int) from Int to Int {
// 	var MONDAY = 0x01;
// 	var TUESDAY = 0x02;
// 	var WEDNESDAY = 0x04;
// 	var THURSDAY = 0x08;
// 	var FRIDAY = 0x10;
// 	var SATURDAY = 0x20;
// 	var SUNDAY = 0x40;
// 	var WEEKDAYS = 0x1F;
// 	var WEEKENDS = 0x20;
// 	var EVERYDAY = 0x7F;
// 	var IS_ACTIVE = 0x80;
// }

// enum abstract Page(Int) from Int to Int {
// 	var HOME_PAGE = -1;
// 	var RINGING_PAGE = -2;

// 	@:op(A > B) function gt(B:Int):Bool;
// }

// @:native('AlarmApp')
// @:pythonImport('app.alarm', 'AlarmApp')
// extern class AlarmApp extends BaseApplication {
// 	static var instance:AlarmApp;
// 	static var alarms:Array<AlarmDef>;
// 	static var pendingAlarms:Array<Float>;
// 	static var numAlarms:Int;

// 	var page:Page;
// 	var delAlarmButton:Button;
// 	var hoursSpinner:Spinner;
// 	var minutesSpinner:Spinner;
// 	var dayButtons:DayButtons;
// 	var alarmChecks:Tuple4<Checkbox, Checkbox, Checkbox, Checkbox>;

// 	public static function init(?alarms:Array<AlarmDef>):Void;
// 	public function new();

// 	public static function getInstance():AlarmApp;
// 	public static function nextAlarm():Null<Float>;
// }

// extern class AlarmDef extends Bytearray {
// 	static inline function make(HH:Int, MM:Int, mask:RepetitionFlag):AlarmDef
// 		return cast new Bytearray([HH, MM, mask]);

// 	var HH(get, set):Int;
// 	inline function get_HH():Int return this[0];
// 	inline function set_HH(v:Int):Int return this[0] = v;

// 	var MM(get, set):Int;
// 	inline function get_MM():Int return this[1];
// 	inline function set_MM(v:Int):Int return this[1] = v;

// 	var mask(get, set):RepetitionFlag;
// 	inline function get_mask():RepetitionFlag return this[2];
// 	inline function set_mask(v:RepetitionFlag):RepetitionFlag return this[2] = v;

// 	inline function formatHour():String return '{:02d}:{:02d}'.format(this.HH, this.MM);
// }
