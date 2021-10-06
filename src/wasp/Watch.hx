/*
	Using real wasp-os for now. Needed (extern) fields:

	os.uname()
	button
	display.poweron()
	display.poweroff()
	display.mute()
	display.touch.sleep()
	display.touch.wake()
	display.touch.get_event()
	display.touch.reset_touch_data()
	backlight.set()
	battery.charging()
	rtc.update
	rtc.uptime
	rtc.time
	rtc.get_uptime_ms
	free
	drawable.reset()
	vibrator.pulse()
	print_exception
	schedule
	nop
*/
package wasp;

extern class Watch {
	var drawable:Draw565;
}
