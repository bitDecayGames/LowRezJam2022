package states;

import flixel.math.FlxMath;
import flixel.FlxSubState;
import flixel.util.FlxColor;

import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class SodaPourState extends FlxSubState {
	var returnState:TruckState;

	var gusher:FlxSprite;
	var fillLever:FlxSprite;
	var sodaCup:FlxSprite;

	var intendingToPour = false;
	var pourSoda = false;

	// 1/(seconds to fill). Ex: .33 = 3 seconds to fill cup
	var fillRate = 0.33;
	var fillPercent = 0.0;

	var fillingFrameCount = 0;
	var spillingFrameCount = 0;

	var frameCupOffsets = [7, 4, 2, 1];

	var waitingForFinish = false;
	var finishTimer = 0.0;
	var finishThreshold = 1.0;

	public function new(returnState:TruckState) {
		super();

		this.returnState = returnState;
		bgColor = FlxColor.fromRGB(30, 30, 30, 128);

		fillLever = new FlxSprite();
		fillLever.loadGraphic(AssetPaths.activatorArm__png, true, 64, 64);
		fillLever.animation.add("press", [0, 1, 2, 3], 15, false);
		fillLever.animation.add("release", [3, 2, 1, 0], 15, false);
		fillLever.animation.play("release", true, 3);
		fillLever.animation.finishCallback = function(name:String) {
			if (name == "press") {
				// press finished, start filling
				pourSoda = true;
			}
		};
		add(fillLever);

		gusher = new FlxSprite(18, 21);
		gusher.loadGraphic(AssetPaths.gusher__png, true, 7, 36);
		gusher.animation.add("gush", [0, 1, 2], 25);
		gusher.animation.play("gush");
		gusher.alpha = 0;
		add(gusher);

		sodaCup = new FlxSprite();
		sodaCup.x = 6;
		sodaCup.loadGraphic(AssetPaths.fillingSpilling__png, true, 64, 64);
		sodaCup.animation.add("filling", [ for (i in 0...33) i ], 0, false);
		sodaCup.animation.add("spilling_start", [33], 15, false);
		sodaCup.animation.add("spilling", [ for (i in 34...38) i ], 15, true);
		sodaCup.animation.add("spilling_end", [38], 15, false);
		sodaCup.animation.play("filling", true);
		sodaCup.animation.finishCallback = function(name:String) {
			if (name == "spilling_start") {
				sodaCup.animation.play("spilling");
			}

			if (name == "spilling_end") {
				sodaCup.animation.play("filling", true, 32);
			}
		};
		add(sodaCup);

		fillingFrameCount = sodaCup.animation.getByName("filling").numFrames;
	}

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		var bgImage = new FlxSprite(AssetPaths.fountain_bg__png);
		add(bgImage);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.pressed || FlxG.mouse.justPressed) {
			intendingToPour = true;
			if (FlxG.mouse.justPressed) {
				trace('just pressed and current anim is ${fillLever.animation.name}/${fillLever.animation.curAnim.curFrame}');
				trace('setting press anim to play starting on frame ${3 - fillLever.animation.frameIndex}');
				fillLever.animation.play("press", true, false, 3 - fillLever.animation.curAnim.curFrame);
			}
			sodaCup.x = frameCupOffsets[fillLever.animation.frameIndex];
		} else {
			intendingToPour = false;
			pourSoda = false;
			if (FlxG.mouse.justReleased) {
				trace('just released and current anim is ${fillLever.animation.name}/${fillLever.animation.curAnim.curFrame}');
				trace('setting release anim to play starting on frame ${3 - fillLever.animation.frameIndex}');
				// TODO: Do we have to care if we are in the press animation, or can that be assumed?
				fillLever.animation.play("release", true, false, 3 - fillLever.animation.curAnim.curFrame);
			}
			sodaCup.x = frameCupOffsets[3 - fillLever.animation.curAnim.curFrame];
		}

		if (intendingToPour) {
			waitingForFinish = true;
			finishTimer = 0;
		}

		if (pourSoda) {
			gusher.alpha = 1;
			fillPercent += fillRate * elapsed;
			if (fillPercent > 1.0) {
				if (!StringTools.startsWith(sodaCup.animation.name, "spilling")) {
					sodaCup.animation.play("spilling_start");
				}
			}
		} else {
			if (gusher.alpha != 0 && StringTools.startsWith(sodaCup.animation.name, "spilling")) {
				sodaCup.animation.play("spilling_end");
			}
			gusher.alpha = 0;
			if (waitingForFinish) {
				finishTimer += elapsed;
				if (finishTimer >= finishThreshold) {
					// TODO: rate the soda level and next game
					close();
					returnState.dismissCustomer(1);
					// returnState.openSubState(new ChangeSortState(returnState, 1));
				}
			}
		}

		if (fillPercent <= 1.0) {
			sodaCup.animation.frameIndex = Std.int(FlxMath.bound(fillingFrameCount * fillPercent, 0, fillingFrameCount));
		}

	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
