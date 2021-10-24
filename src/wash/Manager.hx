package wash;

// import python.Exceptions;
import python.Bytearray;
import python.Syntax.bytes;
import python.Syntax.construct;

import wasp.Builtins;
import wasp.Builtins.print;
import wasp.Gc;
import wasp.Machine;
import wasp.Micropython;
import wasp.Watch;

import wash.app.IApplication;
import wash.app.system.CrashApp;
import wash.app.system.Launcher;
import wash.app.system.NotificationApp;
import wash.app.system.PagerApp;
import wash.app.system.Settings;
import wash.app.system.Software;
import wash.app.user.AlarmApp;
import wash.app.user.Torch;
import wash.app.watchface.BatTri;
import wash.event.EventMask;
import wash.event.EventType;
import wash.event.TouchEvent;
import wash.util.Alarm;
import wash.widgets.PinHandler;
import wash.widgets.StatusBar;

using python.NativeArrayTools;

@:publicFields
@:native("Manager")
// TODO: determine public and private fields
class Manager {
	var app:Null<IApplication> = null;
	var quickRing:Array<IApplication> = [];
	var launcherRing:Array<IApplication> = [];
	var notifications:Array<Notification> = []; // TODO: real type?
	// var musicState:MusicState; // TODO
	// var weatherInfo:WeatherInfo; // TODO
	var theme:Theme = new Bytearray(cast bytes(
		'\\x7b\\xef', // ble
		'\\x7b\\xef', // scroll-indicator
		'\\x7b\\xef', // battery
		'\\xe7\\x3c', // status-clock
		'\\x7b\\xef', // notify-icon
		'\\xff\\xff', // bright
		'\\xfe\\x20', // mid - yellowish orange
		'\\xfb\\x80', // ui - orange
		'\\xff\\x00', // spot1
		'\\xdd\\xd0', // spot2
		'\\x00\\x0f' // contrast
	));

	var blankAfter:Int = 15;
	var alarms:Array<Alarm> = [];
	var brightness(default, set):Int = 2; // TODO: enum abstract
	var notifyLevel(default, set):Int = 2; // TODO: enum abstract
	var nfyLevels:Array<Int> = [0, 40, 80];
	var nfylev_ms:Int = 40;
	var charging:Bool = true;
	var scheduled:Bool = false;
	var scheduling:Bool = false;
	var tickPeriodMs:Int = 0;
	var tickExpiry:Int = 0;
	var sleepAt:Int = 0;
	var eventMask:Int = 0; // EventMask combination

	var bar:StatusBar;
	var launcher:Launcher;
	var button:PinHandler;
	var notifier:NotificationApp;

	function new() {
		nfylev_ms = nfyLevels[notifyLevel - 1];
	}

	function init():Void {
		if (bar == null) bar = new StatusBar();
		if (launcher == null) launcher = new Launcher();
		if (notifier == null) notifier = new NotificationApp();
		if (button == null) button = new PinHandler(Watch.button);
	}

	function secondaryInit():Void {
		// TODO: global free

		if (app == null) {
			if (quickRing.length == 0) registerDefaults();

			Watch.display.poweron();
			Watch.display.mute(true);
			Watch.backlight.set(brightness);
			sleepAt = Watch.rtc.uptime + 90;

			if (Watch.free > 0) {
				Gc.collect();
				// TODO
				var free = Gc.mem_free();
			}

			switchApp(quickRing[0]);
		}
	}

	function registerDefaults():Void {
		// Quick ring
		register(BatTri, true, true);
		register(AlarmApp, true);
		register(Torch, true);

		// Other apps
		register(Settings);
		register(Software);
	}

	function register(
		cls:Class<IApplication>,
		quickRing:Bool = false,
		watchFace:Bool = false,
		noExcept:Bool = true
	):Void {
		var app:IApplication = construct(cls);

		// TODO: special step counter handling

		if (watchFace) this.quickRing[0] = app;
		else if (quickRing) this.quickRing.push(app);
		else {
			launcherRing.push(app);
			launcherRing.nativeSort(appSort);
		}

		app.registered(watchFace || quickRing);
	}

	function unregister(cls:Class<IApplication>):Void {
		for (app in launcherRing) {
			if (Builtins.type(app) == cls) {
				launcherRing.remove(app);
				app.unregistered();
				break;
			}
		}
	}

	function hasApplication(cls:Class<IApplication>):Bool {
		for (app in launcherRing)
			if (Builtins.type(app) == cls) return true;

		return false;
	}

	function requestTick(periodMs:Int):Void {
		tickPeriodMs = periodMs;
		// Don't wait for first tick()
		tickExpiry = Watch.rtc.get_uptime_ms(); //  + periodMs;
	}

	// TODO:
	// - notify
	// - unnotify
	// - toggleMusic
	// - setMusicInfo
	// - setWeatherInfo

	function setAlarm(time:Float, cb:Void->Void):Void {
		alarms.push(Alarm.make(time, cb));
		alarms.nativeSort(alarmSort);
	}

	function cancelAlarm(time:Float, cb:Void->Void):Bool {
		try alarms.remove(Alarm.make(time, cb)) catch (_) return false;
		return true;
	}

	// TODO: EventMask combination
	function requestEvent(event:Int):Void {
		eventMask = eventMask | event;
	}

	function keepAwake():Void {
		sleepAt = Watch.rtc.uptime + blankAfter;
	}

	function sleep():Void {
		Watch.backlight.set(0);
		if (!app.sleep()) {
			switchApp(quickRing[0]);
			app.sleep();
		}

		Watch.display.poweroff();
		Watch.touch.sleep();
		charging = Watch.battery.charging();
		sleepAt = -1;
	}

	function wake():Void {
		if (sleepAt <= 0) {
			Watch.display.poweron();
			app.wake();
			Watch.backlight.set(brightness);
			Watch.touch.wake();
		}

		keepAwake();
	}

	@:keep
	function run(noExcept:Bool = true):Void {
		if (scheduling) {
			print('Watch already running in the background');
			return;
		}

		secondaryInit();

		print('Watch is running, use Ctrl-C to stop');

		if (!noExcept) {
			while (true) {
				tick();
				Machine.deepsleep();
			}
		}

		while (true) {
			// Damn.. can't do that native try/catch without adding lots of
			// crap.. Need to cheat to generate it x_x
			if (noExcept != noExcept) {
				python.Syntax.code('pass\n            try:');
				tick();

				python.Syntax.code('\n            except KeyboardInterrupt:');
				python.Syntax.code('raise');

				python.Syntax.code('\n            except MemoryError:');
				switchApp(new PagerApp('Your watch is low on memory.\n\nYou may want to reboot.'));
				python.Syntax.code('pass');

				python.Syntax.code('\n            except Exception as e:');
				#if simulator Watch.print_exception(untyped e); #end
				switchApp(new CrashApp(untyped e));
				python.Syntax.code('pass');
			}

			Machine.deepsleep();
		}
	}

	@:python("micropython.native")
	function tick():Void {
		var update = Watch.rtc.update();

		if (update && alarms.length > 0) {
			var now = Watch.rtc.time();
			var head = alarms[0];

			if (head.time <= now) {
				alarms.remove(head);
				head.cb();
			}
		}

		if (sleepAt > 0) {
			if (update && tickExpiry > 0) {
				var now = Watch.rtc.get_uptime_ms();

				if (tickExpiry <= now) {
					var ticks = opCeilDiv(now - tickExpiry, tickPeriodMs);
					tickExpiry = tickExpiry + ticks * tickPeriodMs;
					app.tick(ticks);
				}
			}

			var state = button.get_event();
			if (state != null) handleButton(state);

			var event = Watch.touch.get_event();
			if (event != null) handleTouch(event);

			if (sleepAt > 0 && Watch.rtc.uptime > sleepAt) sleep();

			Gc.collect();
		} else {
			if (button.get_event() || charging != Watch.battery.charging())
				wake();
		}
	}

	@:keep
	function work():Void {
		scheduled = false;

		// Damn.. can't do that native try/catch without adding lots of
		// crap.. Need to cheat to generate it x_x
		if (scheduled != scheduled) {
			python.Syntax.code('pass\n        try:');
			tick();

			python.Syntax.code('\n        except MemoryError:');
			switchApp(new PagerApp('Your watch is low on memory.\n\nYou may want to reboot.'));
			python.Syntax.code('pass');

			python.Syntax.code('\n        except Exception as e:');
			// TODO: print exception when watch is able to
			switchApp(new CrashApp(untyped e));
		}
	}

	@:keep
	function schedule(enable:Bool):Void {
		secondaryInit();

		if (enable) Watch.schedule = _schedule;
		else Watch.schedule = Watch.nop;

		scheduling = enable;
	}

	private function _schedule():Void {
		if (!scheduled) {
			scheduled = true;
			Micropython.schedule((untyped Manager).work, this);
		}
	}

	function handleButton(state:Bool):Void {
		keepAwake();

		if (eventMask & EventMask.BUTTON > 0) {
			if (!app.press(EventType.HOME, state)) return;
		}

		if (state) navigate(EventType.HOME);
	}

	function handleTouch(event:TouchEvent):Void {
		keepAwake();

		if (event.type == NEXT) {
			if (eventMask & EventMask.NEXT > 0 && !app.swipe(event)) {
				event.type = NONE;
			} else if (app == quickRing[0] && notifications.length > 0) {
				event.type = DOWN;
			} else if (app == notifier) {
				event.type = UP;
			} else {
				event.type = RIGHT;
			}
		}

		if ((event.type:Int) < 5) {
			var updown = event.type == DOWN || event.type == UP;

			if (
				(eventMask & EventMask.SWIPE_UPDOWN > 0 && updown)
				|| (eventMask & EventMask.SWIPE_LEFTRIGHT > 0 && !updown)
			) {
				if (app.swipe(event)) navigate(event.type);
			} else {
				navigate(event.type);
			}
		} else if (event.type == TOUCH && eventMask & EventMask.TOUCH > 0) {
			app.touch(event);
		}

		Watch.touch.reset_touch_data();
	}

	function isActive(app:IApplication):Bool return app == this.app;

	function switchApp(app:IApplication):Void {
		if (isActive(app)) return;

		if (this.app != null) {
			try {
				this.app.background();
			} catch (e) {
				// TODO (see comment in wasp.py)
			}
		}

		eventMask = 0;
		tickPeriodMs = 0;
		tickExpiry = 0; // null on wasp.py?

		this.app = app;
		Watch.display.mute(true);
		Watch.drawable.reset();
		app.foreground();
		Watch.display.mute(false);
	}

	function navigate(direction:EventType):Void {
		switch (direction) {
			case LEFT:
				var i = 0;
				if (quickRing.contains(app)) {
					i = quickRing.indexOf(app) + 1;
					if (i >= quickRing.length) i = 0;
				}

				switchApp(quickRing[i]);

			case RIGHT:
				var i = 0;
				if (quickRing.contains(app)) {
					i = quickRing.indexOf(app) - 1;
					if (i < 0) i = quickRing.length - 1;
				}

				switchApp(quickRing[i]);

			case UP:
				switchApp(launcher);

			case DOWN:
				if (app != quickRing[0]) switchApp(quickRing[0]);
				else {
					if (notifications.length > 0) {
						switchApp(notifier);
					} else {
						Watch.vibrator.pulse();
					}
				}

			case HOME | BACK:
				if (app != quickRing[0]) switchApp(quickRing[0]);
				else sleep();

			case _:
		}
	}

	function set_brightness(b:Int):Int {
		brightness = b;
		Watch.backlight.set(b);
		return b;
	}

	function set_notifyLevel(level:Int):Int {
		notifyLevel = level;
		nfylev_ms = nfyLevels[level - 1];
		return level;
	}

	function appSort(app:IApplication):String return app.NAME;
	function alarmSort(alarm:Alarm):Float return alarm.time;
}
