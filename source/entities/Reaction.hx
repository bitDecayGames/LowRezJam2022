package entities;

import flixel.FlxG;
import flixel.FlxSprite;

class Reaction extends FlxSprite {

	var floatSpeed = 10;
	var fadeTime = 2.0;
	var fadeRemaining = 2.0;

	public function new(parent:FlxSprite, quality:Float) {
		super(parent.x + parent.width / 2 - 4, parent.y - 4);
		loadGraphic(AssetPaths.reactions__png, true, 8, 8);
		animation.add("face", [ for (i in 0...5) 4 - i ], 0, false);
		trace('reaction forming based on rating of ${quality}');
		animation.play("face", true, Std.int(quality * 5));
	}

	public function getRatingSFX():String {
		trace('anim frame is ${animation.frameIndex}');
		switch (animation.frameIndex) {
			case 0:
				return FmodSFX.delight;
			case 1:
				return FmodSFX.happy;
			case 2:
				return FmodSFX.mediocre;
			case 3:
				return FmodSFX.unhappy;
			default:
				return FmodSFX.disgust;
		}
	}

	override public function update(delta:Float) {
		super.update(delta);

		y -= floatSpeed * delta;
		fadeRemaining -= delta;

		if (fadeRemaining >= 0) {
			alpha = fadeRemaining/fadeTime;
		} else {
			kill();
		}
	}
}