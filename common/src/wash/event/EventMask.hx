package wash.event;

enum abstract EventMask(Int) to Int {
	var TOUCH = 0x0001;
	var SWIPE_LEFTRIGHT = 0x0002;
	var SWIPE_UPDOWN = 0x0004;
	var BUTTON = 0x0008;
	var NEXT = 0x0010;
}
