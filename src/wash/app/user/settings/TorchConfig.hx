package wash.app.user.settings;

import python.Bytearray;
import python.lib.io.BufferedReader;

import wash.app.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wasp.Fonts;
import wasp.Watch;

@:access(wash.app.user.Torch)
class TorchConfig extends BaseApplication implements ISettingsApplication {
	var initialState:Checkbox;
	var redLight:Checkbox;

	public function new(_) {
		super();
		NAME = "Torch App";

		initialState = new Checkbox(6, 90, "Initial state ON");
		redLight = new Checkbox(6, 140, "Use red light");
	}

	override public function touch(event:TouchEvent):Void {
		if (initialState.touch(event)) Torch.initialState = initialState.state;
		if (redLight.touch(event)) Torch.redLight = redLight.state;
	}

	public function draw():Void {
		var draw = Watch.drawable;
		draw.set_color(Wash.system.theme.highlight);
		draw.set_font(Fonts.sans24);
		draw.string(NAME, 0, 6, 240);

		initialState.state = Torch.initialState;
		redLight.state = Torch.redLight;

		initialState.draw();
		redLight.draw();
	}

	public function update():Void {}

	public static function serialize(bytes:Bytearray):Void {
		bytes.append(F_InitState);
		bytes.append(Torch.initialState ? 0x01 : 0x00);

		bytes.append(F_RedLight);
		bytes.append(Torch.redLight ? 0x01 : 0x00);
	}

	public static function deserialize(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case F_InitState:
					Torch.initialState = f.read(1).get(0) == 0x01;

				case F_RedLight:
					Torch.redLight = f.read(1).get(0) == 0x01;

				case 0x00:
					break;
			}
		}
	}
}

private enum abstract Field(Int) to Int {
	var F_InitState = 0x01;
	var F_RedLight = 0x02;
}
