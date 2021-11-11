package wash.icon;

@:native('BleStatusIcon')
class BleStatusIcon {
	public static function getIcon() return bytes(
		'\\x02',
		'\\t\\x11',
		'@\\x81D\\xc1H\\xc2G\\xc3F\\xc4A\\xc2B\\xc2A\\xc2',
		'A\\xc2A\\xc2A\\xc2B\\xc6D\\xc4F\\xc2F\\xc4D\\xc6',
		'B\\xc2A\\xc2A\\xc4B\\xc2A\\xc2D\\xc4E\\xc3F\\xc2',
		'G\\xc1D'
	);
}
