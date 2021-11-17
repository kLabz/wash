package wasp;

// TODO: enable ble mac address again when a workaround is found
// See https://github.com/daniel-thompson/wasp-os/issues/271#issuecomment-962613262
// #if simulator
class BLE {
	public static function address():String return "12:34:56:78:90:AB";
}
// #else
// @:native('BLE_address')
// @:pythonImport('ble', 'address')
// extern class BLE {
// 	@:selfCall static function address():String;
// }
// #end
