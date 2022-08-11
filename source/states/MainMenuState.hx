package states;

import flixel.tweens.FlxTween;
import flixel.addons.effects.chainable.FlxRainbowEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.FlxSprite;
import states.transitions.Trans;
import states.transitions.SwirlTransition;
import states.AchievementsState;
import com.bitdecay.analytics.Bitlytics;
import config.Configure;
import flixel.FlxG;
import flixel.addons.ui.FlxUICursor;
import flixel.addons.ui.FlxUIState;
import flixel.addons.ui.FlxUITypedButton;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;

using extensions.FlxStateExt;

#if windows
import lime.system.System;
#end

class MainMenuState extends FlxUIState {
	var _btnPlay:FlxButton;
	var _btnCredits:FlxButton;
	var _btnExit:FlxButton;

	var _imgTitle:FlxSprite;
	var _imgStartPrompt:FlxSprite;

	var transitioning = false;

	override public function create():Void {
		super.create();

		FmodManager.PlaySong(FmodSongs.LetsGo);
		bgColor = FlxColor.TRANSPARENT;
		FlxG.camera.pixelPerfectRender = true;

		_imgTitle = new FlxSprite(AssetPaths.title_image__png);
		add(_imgTitle);

		_imgStartPrompt = new FlxSprite(AssetPaths.startText__png);

		var rainbow = new FlxEffectSprite(_imgStartPrompt);
		var effect = new FlxRainbowEffect(1, 1, 1);
		rainbow.effects = [effect];
		add(rainbow);

		// Trigger our focus logic as we are just creating the scene
		this.handleFocus();

		// we will handle transitions manually
		// transOut = null;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		if (FlxG.keys.pressed.D && FlxG.keys.justPressed.M) {
			// Keys D.M. for Disable Metrics
			Bitlytics.Instance().EndSession(false);
			FmodManager.PlaySoundOneShot(FmodSFX.MenuSelect);
			trace("---------- Bitlytics Stopped ----------");
		}

		if (!transitioning && FlxG.mouse.justReleased) {
			clickPlay();
		}
	}

	function clickPlay():Void {
		// FmodManager.StopSong();
		// var swirlOut = new SwirlTransition(Trans.OUT, () -> {
		// 	// make sure our music is stopped;
		// 	FmodManager.StopSongImmediately();
		// 	FlxG.switchState(new PlayState());
		// }, FlxColor.GRAY);
		// openSubState(swirlOut);
		FmodFlxUtilities.TransitionToStateAndStopMusic(new TruckState());
	}

	function clickCredits():Void {
		FmodFlxUtilities.TransitionToState(new CreditsState());
	}

	function clickAchievements():Void {
		FmodFlxUtilities.TransitionToState(new AchievementsState());
	}

	#if windows
	function clickExit():Void {
		System.exit(0);
	}
	#end

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
