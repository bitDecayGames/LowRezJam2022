package states;

import flixel.util.FlxSort;
import entities.Customer;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import entities.IceCreamFlavor;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.addons.plugin.FlxMouseControl;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxColor;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;

import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class TruckState extends FlxTransitionableState {

	var customers:FlxTypedGroup<Customer> = new FlxTypedGroup<Customer>();
	var truck:FlxSprite;

	// TODO: probably makes sense to have a min/max spawn window and to pick something
	// randomly in between. As difficulty increases, the min/max decrease
	var customerTimer:FlxTimer;

	// The valid spots customers may go to start an order
	var counterSpace = FlxRect.get(6, 39, 50-13, 7);

	public function new() {
		super();

		// We will be opening other microgame states on top of this. Don't want to draw
		// or update while those are being played
		// .... or do we? probably do, actually
		// persistentUpdate = false;
		persistentDraw = false;
	}

	override public function create() {
		super.create();

		if (FlxG.plugins.get(FlxMouseControl) == null) {
			FlxG.plugins.add(new FlxMouseControl());
		}

		FlxG.camera.pixelPerfectRender = true;

		add(customers);

		truck = new FlxSprite(AssetPaths.mockTruckLayout__png);
		add(truck);

		customerTimer = new FlxTimer();
		customerTimer.start(5, spawnCustomer, 0);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		customers.sort(FlxSort.byY);
	}

	function spawnCustomer(timer:FlxTimer) {
		var cust = new Customer();
		cust.enableMouseClicks(true, true);
		cust.mousePressedCallback = function(spr:FlxExtendedSprite, x:Int, y:Int) {
			// TODO: Need a transition here of some sort (swipe out?)
			var scoopState = new ScoopState(this);
			openSubState(scoopState);
		}

		// TODO: Have a pseudo line for customers to get into. Customers should scoot up once people in front leave
		var target = FlxPoint.get(FlxG.random.float(counterSpace.left, counterSpace.right), FlxG.random.float(counterSpace.top, counterSpace.bottom));

		FlxTween.linearPath(cust, [FlxPoint.get(cust.x, cust.y), FlxPoint.get(target.x, cust.y), FlxPoint.get(target.x, target.y)]);

		customers.add(cust);
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
