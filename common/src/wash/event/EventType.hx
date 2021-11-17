package wash.event;

enum abstract EventType(Int) to Int {
    var NONE = 0;

    var DOWN = 1;
    var UP = 2;
    var LEFT = 3;
    var RIGHT = 4;
    var TOUCH = 5;

    var HOME = 255;
    var BACK = 254;
    var NEXT = 253;
}
