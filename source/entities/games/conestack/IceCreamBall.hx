package entities.games.conestack;

import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;

class IceCreamBall extends FlxSprite {

	var flavor:IceCreamFlavor;

	public var plopped = false;

	public function new(flavor:IceCreamFlavor) {
		super(switch (flavor) {
			case Chocolate:
				AssetPaths.chocolate_ball__png;
			case Vanilla:
				AssetPaths.vanilla_ball__png;
			case Strawberry:
				AssetPaths.strawberry_ball__png;
		});

		this.flavor = flavor;

		setSize(14, 14);
		offset.set(4, 4);
	}

	public function plop(against:FlxSprite) {
		plopped = true;
		// This is to align the plop with the initial ball of ice cream
		// y += 3;

		var accuracy = (this.getMidpoint().x - against.getMidpoint().x) / width;
		trace('raw accuracy: ${accuracy}');
		// accuracy /= .5; // normalize to [-1,1]
		// trace('percentage normalized: ${accuracy}');
		accuracy *= 2;
		trace('frame adj accuracy: ${accuracy}');

		accuracy += 2;
		trace('frame: ${accuracy}');


		var plopFrame = Math.round(accuracy);
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
	}
}