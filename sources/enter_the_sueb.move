module enter_the_sueb::enter_the_sueb {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    use std::string::String;

    const ENERGY: u8 = 0;
    const POWER: u8 = 1;
    const RUSH: u8 = 2;

    const EMintNotAuthorized: u64 = 1001;
    const EBurnNotAuthorized: u64 = 1002;
    const ELevelingNotAuthorized: u64 = 1003;

    // ----------- Caps ----------- //

    struct AdminCap has key, store { id: UID }

    struct AppCap has store, drop { app_name: String }

    // ----------- Types ----------- //

    struct Warrior has drop {}

    struct Relic has drop {}

    // ----------- Keys ----------- //

    struct MintKey<phantom T> has copy, store, drop {}

    struct BurnKey<phantom T> has copy, store, drop {}

    struct LevelingKey<phantom T> has copy, store, drop {}

    // ----------- Sueb Object ----------- //

    struct EnterTheSueb<phantom T> has key, store {
        id: UID,
        level: u64,
        max_duration: u64, // unsure of how i want to handle this.
    }
    // was unsure if i want to do this or just a u8 for the df:key, 
    // but this way i can also link the UID of the sueb for the game
    struct StatKey has copy, store, drop { key: u8 }

    struct SuebStat has store { 
        stat: u8, 
        value: u64,
    }

    // ----------- Mut Accessor Functions ----------- //
    
    fun increment_level<T>(self: &mut EnterTheSueb<T>) {
        self.level = self.level + 1;
    }
    
    // ----------- Accessor Functions ----------- //


    // ----------- Init Function ----------- //

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap { id: object::new(ctx) }, 
            tx_context::sender(ctx));
    }

    // ----------- Create Functions ----------- //

    public fun create_mint_key<T>(): MintKey<T> { MintKey<T> {} }

    public fun create_burn_key<T>(): BurnKey<T> { BurnKey<T> {} }

    public fun create_leveling_key<T>(): LevelingKey<T> { LevelingKey<T> {} }

    // ----------- Auth Functions ----------- //

    public fun is_authorized<K: store + copy + drop>(app: &UID, key: K): bool {
        dynamic_field::exists_(app, key)
    }

    public fun authorize_app<K: store + copy + drop>(
        _: &AdminCap,
        app: &mut UID,
        key: K,
        app_name: String
    ) {
        dynamic_field::add(app, key, AppCap { app_name })
    }

    // ----------- Mint Function ----------- //

    public fun mint<T: drop>(
        app: &mut UID,
        ctx: &mut TxContext,
    ) {
        assert!(is_authorized(app, create_mint_key<T>()), EMintNotAuthorized);

        let id = object::new(ctx);

        dynamic_field::add(&mut id, StatKey { key: ENERGY }, SuebStat{ stat: ENERGY, value: 5 });
        dynamic_field::add(&mut id, StatKey { key: POWER }, SuebStat{ stat: POWER, value: 5 });
        dynamic_field::add(&mut id, StatKey { key: RUSH }, SuebStat{ stat: RUSH, value: 5 });

        // for now just transfer to sender... something with kiosks.
        // linter: Returning an object from a function, allows a caller to use the object
        // and enables composability via programmable transactions.
        transfer::public_transfer(EnterTheSueb<T> {
            id,
            level: 0,
            max_duration: 5,
        }, tx_context::sender(ctx));
    }

    // ----------- Burn Function ----------- //

    public fun burn<T: drop> (app: &mut UID, obj: EnterTheSueb<T>) {
        assert!(is_authorized(app, create_burn_key<T>()), EBurnNotAuthorized);

        let EnterTheSueb<T> {id , level: _, max_duration: _} = obj;
        object::delete(id);
    }

    // ----------- Level Function ----------- //

    public fun leveling<T: drop>(
        app: &mut UID,
        sueb: &mut EnterTheSueb<T>
    ) {
        assert!(is_authorized(app, create_leveling_key<T>()), ELevelingNotAuthorized);

        increment_level<T>(sueb);
    }

    // ----------- Test Only Function ----------- //

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}