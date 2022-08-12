package states;

import entities.OrderTicket;
import orders.OrderType;
import flixel.addons.effects.FlxClothSprite;
import flixel.math.FlxMath;
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
import entities.ArrowCursor;

import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class TruckState extends FlxTransitionableState {

	var bg:FlxSprite;
	var customers:FlxTypedGroup<Customer> = new FlxTypedGroup<Customer>();

	// for render order
	var tickets:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	// for position managment
	var ticketQueue:Array<OrderTicket> = [];

	var truck:FlxSprite;
	var heatOverlay:FlxSprite;
	var thermometer:FlxSprite;
	var redMercuryLevel:FlxSprite;

	var activeCustomer:Customer = null;
	var activeTicket:OrderTicket = null;

	// TODO: probably makes sense to have a min/max spawn window and to pick something
	// randomly in between. As difficulty increases, the min/max decrease
	var customerTimer:FlxTimer;

	// The valid spots customers may go to start an order
	var counterSpace = FlxRect.get(6, 39, 50-13, 7);

	// TODO: Might need to tweak these a tiny bit
	var lineCoords = [
		0 => 2,
		1 => 15,
		2 => 28,
		3 => 41,
	];

	var lineBaseY = 42;
	var customerSpacing = 6;
	var lineCount = 4;
	var lineCustomers:Map<Int, Array<Customer>> = [
		0 => [],
		1 => [],
		2 => [],
		3 => [],
	];
	var lineDepths:Map<Int, Int> = [
		0 => 0,
		1 => 0,
		2 => 0,
		3 => 0,
	];

	// 0 = perfect, 1 = game over
	var temperature = 0.30;

	var ticketTest:FlxSprite;

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

		bg = new FlxSprite(AssetPaths.background__png);
		add(bg);

		add(customers);

		heatOverlay = new FlxSprite();
		heatOverlay.makeGraphic(64, 64, FlxColor.fromRGB(243, 242, 140));
		heatOverlay.alpha = 0;
		add(heatOverlay);

		truck = new FlxSprite(AssetPaths.truck_layout_bg__png);
		add(truck);

		redMercuryLevel = new FlxSprite(56 + 3, 13 + 21);
		redMercuryLevel.makeGraphic(3, 1, FlxColor.RED);
		add(redMercuryLevel);

		thermometer = new FlxSprite(56, 13, AssetPaths.thermometer__png);
		add(thermometer);

		customerTimer = new FlxTimer();
		customerTimer.start(5, spawnCustomer, 0);

		add(tickets);

		// Add cursor last so it is on top
		add(new ArrowCursor());
	}

	#if temp_test
	var increasing = true;
	#end

	override public function update(elapsed:Float) {
		super.update(elapsed);

		#if temp_test
		if (increasing) {
			temperature += .002;
			if (temperature >= 1.0) {
				increasing = false;
			}
		} else {
			temperature -= .002;
			if (temperature <= 0) {
				increasing = true;
			}
		}
		#end


		// this is some math because of how scale works
		redMercuryLevel.y = FlxMath.lerp(thermometer.y+1, thermometer.y + 21, 1 - temperature);
		// Adding +1 here to keep gaps from forming between the thermometer ball and the main shaft
		redMercuryLevel.scale.y = thermometer.y + 21 - redMercuryLevel.y + 1;
		redMercuryLevel.height = redMercuryLevel.scale.y;
		redMercuryLevel.offset.y = -redMercuryLevel.height/2;
		heatOverlay.alpha = FlxMath.lerp(0, .85, temperature);

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
		var custLine = FlxG.random.int(0, lineCount-1);
		var cust = new Customer();
		cust.lineNum = custLine;
		cust.linePosition = lineDepths[custLine];
		cust.spacingVariance = FlxG.random.int(0, 2) - 1;

		var orderType = FlxG.random.bool() ? OrderType.SCOOP : OrderType.POPSICLE;
		var ticket = new OrderTicket(orderType, cust);
		ticket.x = FlxG.width;
		ticket.y = 1;

		cust.ticket = ticket;

		ticket.enableMouseClicks(true, true);
		ticket.mousePressedCallback = function(spr:FlxExtendedSprite, x:Int, y:Int) {
			if (!cust.settled) {
				// only handle clicks if they are settled
				return;
			}

			activeTicket = ticket;

			// TODO: Need a transition here of some sort (swipe out?)
			openSubState(ticket.getOrderState(this));
		}

		cust.enableMouseClicks(true, true);
		// cust.mousePressedCallback = function(spr:FlxExtendedSprite, x:Int, y:Int) {
		// 	if (!cust.settled) {
		// 		// only handle clicks if they are settled
		// 		return;
		// 	}

		// 	activeCustomer = cust;

		// 	// TODO: Need a transition here of some sort (swipe out?)
		// 	openSubState(ticket.getOrderState(this));

		// 	// TODO: This has a bug where the indices get jacked and customers will move UP before getting into the proper position
		// 	// in line. This has to be because of how we are managing our arrays
		// 	lineCustomers[cust.lineNum][cust.linePosition] = null;
		// 	lineDepths[custLine]--;
		// }

		moveCustomerToPosition(cust);

		if (lineDepths[custLine] < cust.linePosition) {
			lineCustomers[custLine].push(cust);
		} else {
			lineCustomers[custLine].insert(cust.linePosition, cust);
		}
		lineDepths[custLine]++;

		customers.add(cust);

		ticketTest = new FlxSprite(FlxG.width, 1, AssetPaths.scoops_ticket__png);
		// ticketTest.meshVelocity.set(0, 100);
		tickets.add(ticketTest);
	}

	function moveTicketToPosition(ticket:OrderTicket) {
		ticket.settled = false;
		var position = ticketQueue.indexOf(ticket);
		var variance = FlxG.random.int(0, 2) - 2;

		var target = FlxPoint.get(position * 13 + variance, 1);

		FlxTween.linearPath(ticket, [FlxPoint.get(ticket.x, ticket.y), FlxPoint.get(target.x, ticket.y), FlxPoint.get(target.x, target.y)], 100, false, {
			onComplete: function (t) {
				ticket.settled = true;
			}
		});
	}

	function moveCustomerToPosition(cust:Customer, onMoveComplete:()->Void=null) {
		cust.settled = false;
		var variance = FlxG.random.int(0, 4) - 2;
		var target = FlxPoint.get(lineCoords[cust.lineNum] + variance, lineBaseY - cust.linePosition * customerSpacing + cust.spacingVariance);

		FlxTween.linearPath(cust, [FlxPoint.get(cust.x, cust.y), FlxPoint.get(target.x, cust.y), FlxPoint.get(target.x, target.y)], 40, false, {
			onComplete: function (t) {
				cust.settled = true;
				if (cust.linePosition == 0) {
					// TODO: Ring bell SFX
					tickets.add(cust.ticket);
					ticketQueue.push(cust.ticket);

					moveTicketToPosition(cust.ticket);
				}
			}
		});
	}

	public function dismissCustomer() {
		if (activeTicket == null) {
			return;
		}

		var ticketPosition = ticketQueue.indexOf(activeTicket);
		ticketQueue.remove(activeTicket);

		// keep a temp reference and clear out our active ticket
		var ticket = activeTicket;
		activeTicket = null;

		var cust = ticket.orderingCustomer;

		var exitXCoord = cust.lineNum <= 2 ? -20 : FlxG.width;
		if (cust.lineNum == 2 && FlxG.random.bool()) {
			exitXCoord = FlxG.width;
		}
		FlxTween.linearPath(cust, [FlxPoint.get(cust.x, cust.y), FlxPoint.get(exitXCoord, cust.y)], 40, false, {
			onComplete: function (t) {
				cust.kill();
			}
		});

		// move all of our tickets behind this one up
		for (t in ticketPosition...ticketQueue.length) {
			moveTicketToPosition(ticketQueue[t]);
		}

		FlxTween.linearPath(ticket, [FlxPoint.get(ticket.x, ticket.y), FlxPoint.get(-ticket.width, ticket.y)], 100, false, {
			onComplete: function (t) {
				ticket.kill();
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
