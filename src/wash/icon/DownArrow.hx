package wash.icon;

@:native('DownArrow')
class DownArrow {
	public static function getIcon() return bytes(
		'\\x02',
		'\\x10\\t',
		'\\xe0\\x01\\xce\\x03\\xcc\\x05\\xca\\x07\\xc8\\t\\xc6\\x0b\\xc4\\r\\xc2\\x07'
	);
}
