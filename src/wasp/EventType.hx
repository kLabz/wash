package wasp;

/**
	Enumerated interface actions.

	MicroPython does not implement the enum module so EventType
	is simply a regular object which acts as a namespace.
*/
enum abstract EventType(Int) to Int {
    var DOWN = 1;
    var UP = 2;
    var LEFT = 3;
    var RIGHT = 4;
    var TOUCH = 5;

    var HOME = 255;
    var BACK = 254;
    var NEXT = 253;
}
