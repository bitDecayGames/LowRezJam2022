package states;

import flixel.FlxSubState;
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

	var activeCustomer:Customer = null;

	// TODO: probably makes sense to have a min/max spawn window and to pick something
	// randomly in between. As difficulty increases, the min/max decrease
	var customerTimer:FlxTimer;

	// The valid spots customers may go to start an order
	var counterSpace = FlxRect.get(6, 39, 50-13, 7);

	// TODO: Might need to tweak these a tiny bit
	var lineCoords = [
		0 => 5,
		1 => 15,
		2 => 25,
		3 => 35,
		4 => 45,
	];

	var lineBaseY = 42;
	var customerSpacing = 3;
	var lineCustomers:Map<Int, Array<Customer>> = [
		0 => [],
		1 => [],
		2 => [],
		3 => [],
		4 => [],
	];
	var lineDepths:Map<Int, Int> = [
		0 => 0,
		1 => 0,
		2 => 0,
		3 => 0,
		4 => 0,
	];

	public function new() {
		super();

		// We will be opening other microgame states on top of this. Don't want to draw
		// or update while those are being played
		// .... or do we? probably do, actually
		// persistentUpdate = false;

		#if isolate_games
		persistentDraw = false;
		#end
	}

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		add(customers);

		truck = new FlxSprite(AssetPaths.truck_layout_bg__png);
		add(truck);

		customerTimer = new FlxTimer();
		customerTimer.start(5, spawnCustomer, 0);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		for (c in customers) {
			if (c.linePosition > 0) {
					if (c.settled && lineCustomers[c.lineNum][c.linePosition - 1] == null) {
					lineCustomers[c.lineNum][c.linePosition] = null;
					c.linePosition--;
					lineCustomers[c.lineNum][c.linePosition] = c;
					moveCustomerToPosition(c);
				}
			}
		}

		customers.sort(FlxSort.byY);
	}

	function spawnCustomer(timer:FlxTimer) {
		var custLine = FlxG.random.int(0, 4);
		var cust = new Customer();
		cust.lineNum = custLine;
		cust.linePosition = lineDepths[custLine];
		cust.spacingVariance = FlxG.random.int(0, 2) - 1;

		cust.enableMouseClicks(true, true);
		cust.mousePressedCallback = function(spr:FlxExtendedSprite, x:Int, y:Int) {
			if (!cust.settled) {
				// only handle clicks if they are settled
				return;
			}

			activeCustomer = cust;

			// TODO: Need a transition here of some sort (swipe out?)
			var scoopState:FlxSubState = new ScoopState(this);
			scoopState = new PopsiclePickerState(this);
			openSubState(scoopState);

			// TODO: This has a bug where the indices get jacked and customers will move UP before getting into the proper position
			// in line. This has to be because of how we are managing our arrays
			lineCustomers[cust.lineNum][cust.linePosition] = null;
			lineDepths[custLine]--;
		}

		moveCustomerToPosition(cust);

		if (lineDepths[custLine] < cust.linePosition) {
			lineCustomers[custLine].push(cust);
		} else {
			lineCustomers[custLine].insert(cust.linePosition, cust);
		}
		lineDepths[custLine]++;

		customers.add(cust);
	}

	function moveCustomerToPosition(cust:Customer) {
		cust.settled = false;
		var variance = FlxG.random.int(0, 4) - 2;
		var target = FlxPoint.get(lineCoords[cust.lineNum] + variance, lineBaseY - cust.linePosition * customerSpacing + cust.spacingVariance);

		FlxTween.linearPath(cust, [FlxPoint.get(cust.x, cust.y), FlxPoint.get(target.x, cust.y), FlxPoint.get(target.x, target.y)], 40, false, {
			onComplete: function (t) {
				cust.settled = true;
			}
		});
	}

	public function dismissCustomer() {
		if (activeCustomer == null) {
			return;
		}

		// TODO: Real customer exit
		var cust = activeCustomer;
		activeCustomer = null;
		var exitXCoord = cust.lineNum <= 2 ? -20 : FlxG.width;
		if (cust.lineNum == 2 && FlxG.random.bool()) {
			exitXCoord = FlxG.width;
		}
		FlxTween.linearPath(cust, [FlxPoint.get(cust.x, cust.y), FlxPoint.get(exitXCoord, cust.y)], 40, false, {
			onComplete: function (t) {
				cust.kill();
			}
		});
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
