package states;

import flixel.system.FlxAssets.FlxGraphicAsset;
import config.Configure;
import haxefmod.flixel.FmodFlxUtilities;
import flixel.tweens.misc.VarTween;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxG;

class SplashScreenState extends FlxState {
	public static inline var PLAY_ANIMATION = "play";

	var index = 0;
	var splashImages:Array<FlxSprite> = [];

	var timer = 0.0;
	var splashDuration = 3.0;

	override public function create():Void {
		super.create();
		// FmodManager.PlaySong(FmodSongs.LetsGetWiggly);

		// To use the system cursor:
		FlxG.mouse.useSystemCursor = true;

		// List splash screen image paths here
		loadSplashImages([
			new SplashImage(AssetPaths.splash_bitSplash__png, 64, 64, 0, 10),
			new SplashImage(AssetPaths.splash_jamSplash__png, 64, 64, 11, 1)
		]);

		timer = splashDuration;
		fadeIn(index);

		Configure.initAnalytics();
	}

	private function loadSplashImages(splashes:Array<SplashImage>) {
		for (s in splashes) {
			add(s.sprite);
			s.sprite.alpha = 0;
			splashImages.push(s.sprite);
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		timer -= elapsed;
		if (timer < 0)
			nextSplash();
	}

	private function fadeIn(index:Int):VarTween {
		var splash = splashImages[index];
		var fadeInTween = FlxTween.tween(splash, { alpha: 1 }, 1);
		if (splash.animation.getByName(PLAY_ANIMATION) != null) {
			fadeInTween.onComplete = (t) -> splash.animation.play(PLAY_ANIMATION);
			splash.animation.callback = (name, frameNumber, frameIndex) -> {
				if (frameNumber == 1 || frameNumber == 3) {
					// FmodManager.PlaySoundOneShot(FmodSFX.SplashBite);
				}
			}
		}
		return fadeInTween;
	}

	public function nextSplash() {
		var tween:VarTween = FlxTween.tween(splashImages[index], { alpha: 0 }, 0.5);

		index += 1;
		timer = splashDuration;

		if (index < splashImages.length) {
			tween.then(fadeIn(index));
		} else {
			tween.onComplete = (t) -> {
				FmodFlxUtilities.TransitionToState(new MainMenuState());
			};
		}
	}
}

class SplashImage {
	public var sprite:FlxSprite;

	public function new(gfx:FlxGraphicAsset, width:Int = 0, height:Int = 0, startFrame:Int = 0, endFrame:Int = -1, rate:Int = 10) {
		sprite = new FlxSprite();
		sprite.loadGraphic(gfx, true, width, height);
		sprite.animation.add(SplashScreenState.PLAY_ANIMATION, [for (i in startFrame...endFrame) i], rate, false);
		sprite.scale.x = FlxG.width / sprite.frameWidth;
		sprite.scale.y = FlxG.height / sprite.frameHeight;

		sprite.updateHitbox();
	}
}