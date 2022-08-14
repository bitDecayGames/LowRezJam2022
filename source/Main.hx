package;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import flixel.addons.plugin.FlxMouseControl;
import achievements.Achievements;
import helpers.Storage;
import states.SplashScreenState;
import misc.Macros;
import states.MainMenuState;
import flixel.FlxState;
import config.Configure;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.util.FlxColor;
import misc.FlxTextFactory;
import openfl.display.Sprite;
#if play
import states.ChangeSortState;
import states.ScoopState;
import states.ConeStackState;
import states.TruckState;
#end

class Main extends Sprite {
	public function new() {
		super();
		Configure.initAnalytics(false);

		Storage.load();
		Achievements.initAchievements();

		var startingState:Class<FlxState> = SplashScreenState;
		#if play
		startingState = TruckState;
		#else
		if (Macros.isDefined("SKIP_SPLASH")) {
			startingState = MainMenuState;
		}
		#end

		addChild(new FlxGame(64, 64, startingState, 1, 60, 60, true, false));

		FlxG.game.setFilters([new ShaderFilter(new FlxShader())]);
		FlxG.game.stage.quality = StageQuality.LOW;

		FlxG.fixedTimestep = false;
		FlxG.plugins.add(new FlxMouseControl());

		// Disable flixel volume controls as we don't use them because of FMOD
		FlxG.sound.muteKeys = null;
		FlxG.sound.volumeUpKeys = null;
		FlxG.sound.volumeDownKeys = null;

		#if debug
		FlxG.autoPause = false;
		#if hide_debugger
		FlxG.debugger.visible = false;
		#end
		#end

		FlxG.mouse.useSystemCursor = Configure.config.mouse.useSystemCursor;
		FlxG.mouse.visible = Configure.config.mouse.cursorVisible;

		// Set up basic transitions. To override these see `transOut` and `transIn` on any FlxTransitionable states
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1);
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 1);

		FlxTextFactory.defaultFont = AssetPaths.Brain_Slab_8__ttf;
	}
}
