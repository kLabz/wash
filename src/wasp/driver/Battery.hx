package wasp.driver;

extern class Battery {
	function charging():Bool;
	function power():Bool;
	function voltage_mv():Int;
	function level():Int;
}
