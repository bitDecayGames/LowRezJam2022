package entities;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

// Follows the mouse position. Better than a custom cursor as this follows the proper pixel-perfect position
// and asset scale
class ScoopCursor extends FlxSprite {
	private var mouseOffset = FlxPoint.get(-4, -13);

	private var tmp = FlxPoint.get();

	public function new() {
		super(AssetPaths.scoop_icon__png);
	}

	override public function update(delta:Float) {
		super.update(delta);

		FlxG.mouse.getPosition(tmp);

		tmp.addPoint(mouseOffset);
		x = tmp.x;
		y = tmp.y;
	}
}