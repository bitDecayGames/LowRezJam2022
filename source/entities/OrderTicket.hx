package entities;

import states.ChangeSortState;
import states.SodaPourState;
import flixel.addons.display.FlxExtendedSprite;
import states.PopsiclePickerState;
import states.ScoopState;
import states.TruckState;
import flixel.FlxSubState;
import orders.OrderType;
import flixel.FlxSprite;

class OrderTicket extends FlxExtendedSprite {

	public static final assets = [
		OrderType.SCOOP => AssetPaths.scoops_ticket__png,
		OrderType.POPSICLE => AssetPaths.popsicle_ticket__png,
		OrderType.SODA => AssetPaths.soda_ticket__png,
		OrderType.MONEY => AssetPaths.change_ticket__png,
	];

	public var type:OrderType;
	public var orderingCustomer:Customer;

	public var settled = false;

	public function new(type:OrderType, c:Customer) {
		super(assets[type]);
		this.type = type;
		orderingCustomer = c;
	}

	public function getOrderState(truck:TruckState):FlxSubState {
		#if force_soda
		return new SodaPourState(truck);
		#end

		switch(type) {
			case SCOOP: return new ScoopState(truck);
			case POPSICLE: return new PopsiclePickerState(truck);
			case SODA: return new SodaPourState(truck);
			case MONEY: return new ChangeSortState(truck, truck.coinsSinceLastRegister);
		}
	}
}