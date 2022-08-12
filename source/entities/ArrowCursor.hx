package entities;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

// Follows the mouse position. Better than a custom cursor as this follows the proper pixel-perfect position
// and asset scale
class ArrowCursor extends FlxSprite {
	private var mouseOffset = FlxPoint.get();

	private var tmp = FlxPoint.get();

	public function new() {
		super(AssetPaths.arrow_icon__png);
	}

	override public function update(delta:Float) {
		super.update(delta);

		FlxG.mouse.getPosition(tmp);

		tmp.addPoint(mouseOffset);
		x = tmp.x;
		y = tmp.y;
	}
}