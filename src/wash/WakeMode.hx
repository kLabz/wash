package wash;

// TODO: bit flag manipulation helpers
enum abstract WakeMode(Int) to Int {
	var Button = 0x1;
	var Tap = 0x2;
	var DoubleTap = 0x4;
}
