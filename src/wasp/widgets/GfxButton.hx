package wasp.widgets;

import python.Bytes;

import wasp.event.TouchEvent;
import wasp.util.PointTuple;

class GfxButton implements IWidget {
	var pos:PointTuple;
	var gfx:Bytes;

	public function new(x:Int, y:Int, gfx:Bytes) {
		pos = PointTuple.make(x, y);
		this.gfx = gfx;
	}

	public function draw():Void {
		Watch.drawable.blit(gfx, pos.x, pos.y);
	}

	public function touch(event:TouchEvent):Bool {
		var x1 = pos.x - 10;
		var x2 = x1 + gfx[1] + 20;
		var y1 = pos.y - 10;
		var y2 = y1 + gfx[2] + 20;

		return event.x >= x1 && event.x < x2 && event.y >= y1 && event.y < y2;
	}
}
