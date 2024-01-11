module enter_the_sueb::enter_the_sueb {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    use std::string::String;

    const EMintNotAuthorized: u64 = 1001;
    const ELevelingNotAuthorized: u64 = 1002;

    // ----------- Caps ----------- //

    struct AdminCap has key, store { id: UID }

    struct AppCap has store, drop { app_name: String }

    // ----------- Types ----------- //

    struct Warrior has drop {}

    struct Relic has drop {}

    // ----------- Keys ----------- //

    struct MintKey<phantom T> has copy, store, drop {}

    struct LevelingKey<phantom T> has copy, store, drop {}

    // ----------- Sueb Object ----------- //

    struct EnterTheSueb<phantom T> has key, store {
        id: UID,
        level: u64,
        maxDuration: u64,
    }

    // ----------- Mut Accessor Functions ----------- //
    
    
    // ----------- Accessor Functions ----------- //


    // ----------- Init Functions ----------- //

    // does this expose the keys? no, fun with AdminCap is needed to do anything.
    public fun create_mint_key<T>(): MintKey<T> {
        MintKey<T> {}
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            AdminCap { id: object::new(ctx) }, 
            tx_context::sender(ctx));
    }

    // ----------- Auth Functions ----------- //

    public fun is_authorized<T: store + copy + drop>(app: &UID, key: T): bool {
        dynamic_field::exists_(app, key)
    }

    public fun authorize_app<T: store + copy + drop>(
        _: &AdminCap,
        app: &mut UID,
        key: T,
        app_name: String
    ) {
        dynamic_field::add(app, key, AppCap { app_name })
    }

    // ----------- Mint Function ----------- //

    public fun mint<T: drop>(
        app: &mut UID,
    ) {
        assert!(is_authorized(app, MintKey<T> {}), EMintNotAuthorized);
    }

    // ----------- Level Function ----------- //

    public fun gain_xp<T: drop>(
        app: &mut UID,
    ) {
        assert!(is_authorized(app, LevelingKey<T> {}), ELevelingNotAuthorized);
    }

    // ----------- Test Only Function ----------- //

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}