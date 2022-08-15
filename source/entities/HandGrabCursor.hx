package entities;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;

// Follows the mouse position. Better than a custom cursor as this follows the proper pixel-perfect position
// and asset scale
class HandGrabCursor extends FlxSprite {
	private static inline var openAnim = "open";
	private static inline var closedAnim = "closed";

	private var mouseOffset = FlxPoint.get(-6, -18);

	private var tmp = FlxPoint.get();

	public function new() {
		super();
		loadGraphic(AssetPaths.pinch__png, true, 20, 20);
		animation.add(openAnim, [0]);
		animation.add(closedAnim, [1]);
	}

	override public function update(delta:Float) {
		super.update(delta);

		FlxG.mouse.getPosition(tmp);

		tmp.addPoint(mouseOffset);
		x = tmp.x;
		y = tmp.y;

		if (FlxG.mouse.pressed) {
			animation.play(closedAnim);
		} else {
			animation.play(openAnim);
		}
	}
}