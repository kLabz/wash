package wasp;

#if simulator
class BLE {
	public static function address():String return "12:34:56:78:90:AB";
}
#else
@:pythonImport('ble')
extern class BLE {
	static function address():String;
}
#end
