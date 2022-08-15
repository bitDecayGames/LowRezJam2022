package entities;

import flixel.FlxG;
import states.ChangeSortState;
import states.SodaPourState;
import flixel.addons.display.FlxExtendedSprite;
import states.PopsiclePickerState;
import states.ScoopState;
import states.TruckState;
import flixel.FlxSubState;
import orders.OrderType;

class OrderTicket extends FlxExtendedSprite {

	private static final scoopAssets = [
		AssetPaths.scoops_chocolate__png,
		AssetPaths.scoops_strawberry__png,
		AssetPaths.scoops_vanilla__png,
	];

	public static final assets = [
		OrderType.SCOOP => function() { return FlxG.random.getObject(scoopAssets); },
		OrderType.POPSICLE => function() { return AssetPaths.popsicle_ticket__png; } ,
		OrderType.SODA => function() { return AssetPaths.soda_ticket__png; },
		OrderType.MONEY => function() { return AssetPaths.change_ticket__png; },
	];

	public var type:OrderType;
	public var orderingCustomer:Customer;

	public var settled = false;

	var ticketAsset:String;

	public function new(type:OrderType, c:Customer) {
		ticketAsset = assets[type]();
		trace('making ticket for: ${ticketAsset}');
		super(ticketAsset);
		this.type = type;
		orderingCustomer = c;
	}

	public function getOrderState(truck:TruckState):FlxSubState {
		#if force_soda
		return new SodaPourState(truck);
		#end

		switch(type) {
			case SCOOP:
				return new ScoopState(truck, switch(ticketAsset) {
					case AssetPaths.scoops_vanilla__png:
						IceCreamFlavor.Vanilla;
					case AssetPaths.scoops_chocolate__png:
						IceCreamFlavor.Chocolate;
					default:
						IceCreamFlavor.Strawberry;
				});
			case POPSICLE: return new PopsiclePickerState(truck);
			case SODA: return new SodaPourState(truck);
			case MONEY: return new ChangeSortState(truck, truck.coinsSinceLastRegister);
		}
	}
}