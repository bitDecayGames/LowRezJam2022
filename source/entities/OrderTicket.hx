package entities;

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
		OrderType.POPSICLE => AssetPaths.popsicle_ticket__png
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
		switch(type) {
			case SCOOP: return new ScoopState(truck);
			case POPSICLE: return new PopsiclePickerState(truck);
		}
	}
}