package wasp;

import python.Exceptions;
import python.Lib.print;
import python.Syntax.bytes;
import python.Syntax.construct;
import python.Syntax.opFloorDiv;

// Default apps
import app.Torch;

import wasp.app.IApplication;
import wasp.app.Launcher;
import wasp.event.TouchEvent;
import wasp.util.Gc;
import wasp.util.Machine;
import wasp.util.Micropython;
import wasp.widgets.PinHandler;
import wasp.widgets.StatusBar;

using python.NativeArrayTools;

@:publicFields
// TODO: determine public and private fields
class Manager {
	var app:Null<IApplication> = null;
	var quickRing:Array<IApplication> = [];
	var launcherRing:Array<IApplication> = [];
	var notifications:Array<Notification> = []; // TODO: real type?
	// var musicState:MusicState; // TODO
	// var weatherInfo:WeatherInfo; // TODO
	var units:String = 'Metric'; // TODO: enum abstract
	var theme:Theme = bytes(
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
	);

	var blankAfter:Int = 15;
	// var alarms:Array<Alarm>; // TODO
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
	// var notifier:NotificationApp; // TODO

	function new() {
		nfylev_ms = nfyLevels[notifyLevel - 1];
	}

	function init():Void {
		if (bar == null) bar = new StatusBar();
		if (launcher == null) launcher = new Launcher();
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
		// TODO: replace with WatchFace, Alaarm, Torch
		register(Torch, true, true, true);

		// TODO: other apps
	}

	function register(cls:Class<IApplication>, quickRing:Bool, watchFace:Bool, noExcept:Bool):Void {
		var app:IApplication = construct(cls);

		// TODO: special step counter handling

		if (watchFace) this.quickRing[0] = app;
		else if (quickRing) this.quickRing.push(app);
		else {
			launcherRing.push(app);
			launcherRing.nativeSort(appSort);
		}
	}

	function unregister(cls:Class<IApplication>):Void {
		var inst:IApplication = construct(cls);

		for (app in launcherRing) {
			if (app.NAME == inst.NAME) {
				launcherRing.remove(app);
				break;
			}
		}
	}

	function requestTick(ticks:Int, ?periodMs:Int = 0):Void {
		tickPeriodMs = periodMs;
		tickExpiry = Watch.rtc.get_uptime_ms() + periodMs;
	}

	// TODO:
	// - notify
	// - unnotify
	// - toggleMusic
	// - setMusicInfo
	// - setWeatherInfo
	// - setAlarm
	// - cancelAlarm

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
		sleepAt = null;
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

	inline function print(s:String):Void python.Syntax.code('print({0})', s);

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
				// TODO: PagerApp
				// switchApp(new PagerApp('Your watch is low on memory.\n\nYou may want to reboot.'));
				// python.Syntax.code('pass');
				python.Syntax.code('raise');

				python.Syntax.code('\n            except Exception as e:');
				// TODO: CrashApp
				// TODO: print exception when watch is able to
				// switchApp(new CrashApp(e));
				// python.Syntax.code('pass');
				python.Syntax.code('raise');
			}

			Machine.deepsleep();
		}
	}

	// TODO: @micropython.native
	// Not needed in simulator, but might be needed on real watch
	function tick():Void {
		var update = Watch.rtc.update();

		// TODO: alarms

		if (sleepAt > 0) {
			if (update && tickExpiry > 0) {
				var now = Watch.rtc.get_uptime_ms();

				if (tickExpiry <= now) {
					// var ticks = 0;
					// TODO: double check formula
					var ticks = tickPeriodMs == 0 ? 0 : -opFloorDiv(-(now - tickExpiry), tickPeriodMs);

					// while (tickExpiry <= now) {
					// 	tickExpiry = tickExpiry + tickPeriodMs;
					// 	ticks++;
					// }

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

	function work():Void {
		scheduled = false;

		// Damn.. can't do that native try/catch without adding lots of
		// crap.. Need to cheat to generate it x_x
		if (scheduled != scheduled) {
			python.Syntax.code('pass\n        try:');
			tick();

			python.Syntax.code('\n        except MemoryError:');
			// TODO: PagerApp
			// switchApp(new PagerApp('Your watch is low on memory.\n\nYou may want to reboot.'));
			python.Syntax.code('raise');
			// python.Syntax.code('pass');

			python.Syntax.code('\n        except Exception as e:');
			// TODO: print exception when watch is able to
			// TODO: CrashApp
			python.Syntax.code('raise');
			// python.Syntax.code('pass');
			// switchApp(new CrashApp(e));
		}
	}

	function schedule(enable:Bool = true):Void {
		secondaryInit();

		if (enable) Watch.schedule = _schedule;
		else Watch.schedule = Watch.nop;

		scheduling = enable;
	}

	private function _schedule():Void {
		if (!scheduled) {
			scheduled = true;
			Micropython.schedule(work, this);
		}
	}

	function handleButton(state:Bool):Void {
		// python.Syntax.code('print("handle button")');
		keepAwake();

		if (eventMask & EventMask.BUTTON > 0) {
			if (!app.press(EventType.HOME, state)) return;
		}

		if (state) navigate(EventType.HOME);
	}

	function handleTouch(event:TouchEvent):Void {
		// python.Syntax.code('print("handle touch")');
		keepAwake();

		if (event.type == NEXT) {
			if (eventMask & EventMask.NEXT > 0 && !app.swipe(event)) {
				event.type = NONE;
			// TODO: notifications
			// } else if (app == quickRing[0] && notifications.length > 0) {
			// 	event.type = DOWN;
			// TODO: notifier
			// } else if (app == notifier) {
			// 	event.type = UP;
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

	function switchApp(app:IApplication):Void {
		if (this.app != null) {
			try {
				app.background();
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
					// TODO: notifications
					// if (notifications.length > 0) {
					// 	switchApp(notifier);
					// } else {
						Watch.vibrator.pulse();
					// }
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
}
