package states;

import spacial.Cardinal;
import spacial.Queue;
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
	var tickQueue:Queue;

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

	var customerSpacing = 6;
	var lineCount = 4;
	var lineCustomers:Map<Int, Queue> = [
		0 => new Queue(FlxPoint.get(2, 42), Cardinal.N, 6, 2, 1),
		1 => new Queue(FlxPoint.get(15, 42), Cardinal.N, 6, 2, 1),
		2 => new Queue(FlxPoint.get(28, 42), Cardinal.N, 6, 2, 1),
		3 => new Queue(FlxPoint.get(41, 42), Cardinal.N, 6, 2, 1),
	];
	var lineDepths:Map<Int, Int> = [
		0 => 0,
		1 => 0,
		2 => 0,
		3 => 0,
	];

	// 0 = perfect, 1 = game over
	var temperature = 0.30;

	public var coinsSinceLastRegister = 0;
	var moneyTicket:OrderTicket = null;

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
		tickQueue = new Queue(FlxPoint.get(0, 1), Cardinal.E, 13);
		tickQueue.verticalVariance = 0;
		tickQueue.horizontalVariace = 1;

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

		customers.sort(FlxSort.byY);
	}

	function spawnCustomer(timer:FlxTimer) {
		var custLine = FlxG.random.int(0, lineCount-1);
		var cust = new Customer();
		cust.lineNum = custLine;

		var orderType = getRandomOrderType();
		var ticket = makeTicket(orderType, cust);
		cust.ticket = ticket;

		cust.enableMouseClicks(true, true);

		lineCustomers[custLine].push(cust, function (position:Int) {
			cust.settled = true;
			cust.linePosition = position;
			if (position == 0) {
				// TODO: Ring bell SFX
				tickets.add(cust.ticket);
				tickQueue.push(cust.ticket);
			}
		});

		customers.add(cust);
	}

	function makeTicket(orderType:OrderType, cust:Customer):OrderTicket {
		var ticket = new OrderTicket(orderType, cust);
		ticket.x = FlxG.width;
		ticket.y = 1;

		ticket.enableMouseClicks(true, true);
		ticket.mousePressedCallback = function(spr:FlxExtendedSprite, x:Int, y:Int) {
			if (cust != null && !cust.settled) {
				// only handle clicks if they are settled
				return;
			}

			activeTicket = ticket;

			// TODO: Need a transition here of some sort (swipe out?)
			openSubState(ticket.getOrderState(this));
		}

		tickets.add(ticket);

		return ticket;
	}

	public function dismissCustomer(coinCount:Int) {
		coinsSinceLastRegister += coinCount;
		if (coinsSinceLastRegister > 0 && moneyTicket == null) {
			var moneyJob = makeTicket(OrderType.MONEY, null);
			moneyTicket = moneyJob;
			tickQueue.push(moneyTicket);
		}

		if (activeTicket == null) {
			return;
		}

		// keep a temp reference and clear out our active ticket
		var ticket = activeTicket;

		dismissTicket();

		var cust = ticket.orderingCustomer;
		lineCustomers[cust.lineNum].remove(cust);

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

	public function dismissTicket() {
		if (activeTicket == null) {
			trace("attempted to dismiss null activeTicket");
			return;
		}

		var ticket = activeTicket;
		tickQueue.remove(ticket);

		if (ticket.type == OrderType.MONEY) {
			moneyTicket = null;
			coinsSinceLastRegister = 0;
		}

		FlxTween.linearPath(ticket, [FlxPoint.get(ticket.x, ticket.y), FlxPoint.get(-ticket.width, ticket.y)], 100, false, {
			onComplete: function (t) {
				ticket.kill();
				tickets.remove(ticket);
			}
		});

		activeTicket = null;

	}

	function getRandomOrderType():OrderType {
		var orders = [ OrderType.SCOOP, OrderType.POPSICLE, OrderType.SODA ];
		return orders[FlxG.random.int(0, orders.length-1)];
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
