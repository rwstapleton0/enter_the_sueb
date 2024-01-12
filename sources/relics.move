module enter_the_sueb::relics {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    use std::string::String;

    use enter_the_sueb::enter_the_sueb::{AdminCap};

    struct RelicStash has key { id: UID }

    struct RelicType has store {
        name: String,
        type: String,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(RelicStash {id: object::new(ctx)});
    }

    fun new_relic(
        _: &AdminCap,
        self: &mut RelicStash,
        name: String,
        type: String
    ) {
        dynamic_field::add(&mut self.id, name, RelicType { name, type });
    }

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}