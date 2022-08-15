package entities.games.conestack;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;

class IceCreamBall extends FlxSprite {

	var flavor:IceCreamFlavor;

	public var plopped = false;

	public function new(flavor:IceCreamFlavor) {
		super();

		loadGraphic(switch (flavor) {
			case Chocolate:
				AssetPaths.chocolate_ball__png;
			case Vanilla:
				AssetPaths.vanilla_ball__png;
			case Strawberry:
				AssetPaths.strawberry_ball__png;
		}, true, 22, 21);
		animation.add("resting", [0]);
		animation.add("falling", [1]);
		animation.play("resting");

		this.flavor = flavor;

		setSize(14, 14);
		offset.set(4, 4);
	}

	public function fall() {
		animation.play("falling");
	}

	public function plop(against:FlxSprite):Float {
		plopped = true;
		// This is to align the plop with the initial ball of ice cream
		// y += 3;

		// starts off as half-accuracy (up to 0.5 in either direction)
		var accuracy = (this.getMidpoint().x - against.getMidpoint().x) / width;
		trace('raw accuracy: ${accuracy}');
		// accuracy /= .5; // normalize to [-1,1]
		// trace('percentage normalized: ${accuracy}');

		// Multiply by 2 to get into 0 - 1 range
		accuracy = accuracy * 2;
		trace('frame adj accuracy: ${accuracy}');

		var frameMathAccuracy = accuracy + 2;
		trace('frame: ${frameMathAccuracy}');


		var plopFrame = Math.round(frameMathAccuracy);
		trace('plopFrame: ${plopFrame}');

		var plopGfx = switch (flavor) {
			case Chocolate:
				AssetPaths.chocolate_plop__png;
			case Vanilla:
				AssetPaths.vanilla_plop__png;
			case Strawberry:
				AssetPaths.strawberry_plop__png;
		}
		loadGraphic(plopGfx, true, 22, 29);
		setSize(14, 14);
		offset.set(4, 4);

		animation.add('plop', [for (i in 0...5) i], 0);
		animation.play('plop', plopFrame);

		var helperMod = 0.2;
		return FlxMath.bound(1 - Math.abs(accuracy) + helperMod, 0, 1);
	}
}