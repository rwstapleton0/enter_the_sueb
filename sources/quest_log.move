module enter_the_sueb::quest_log {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    use std::vector;
    use std::string::{utf8, String};

    use enter_the_sueb::enter_the_sueb::
        {Self, EnterTheSueb, MintKey, Relic, AdminCap};

    const EMintNotAuthorized: u64 = 1001;
    
    // ----------- Quest Objects ----------- //

    struct QuestLog has key, store {
        id: UID,
        quests: vector<Quest> // probably change to dynamic fields?
    }

    struct Quest has store {
        quest_name: String
    }

    // ----------- Init Functions ----------- //

    fun init(ctx: &mut TxContext) {
        transfer::share_object( QuestLog {
            id: object::new(ctx),
            quests: vector::empty(),
        })
    }

    // ----------- Accept/Complete Quest Function ----------- //

    public fun accept_quest() {
        // some thing here.
    }

    public fun complete_quest(self: &mut QuestLog, ctx: &mut TxContext) {
        // some more stuff related to that other stuff.

        // Then call mint with its type
        
        // needs to pass a type creates a key base on quest type...
        let key = enter_the_sueb::create_mint_key<Relic>();

        mint<MintKey<Relic>, Relic>(self, key, ctx)
    }

    // ----------- Mint Function ----------- //

    public fun mint<K: store + copy + drop, T: drop>(
        self: &mut QuestLog,
        key: K,
        ctx: &mut TxContext,
    ) {
        assert!(enter_the_sueb::is_authorized<K>(&self.id, key), EMintNotAuthorized);

        enter_the_sueb::mint<T>(&mut self.id, ctx);
    }

    // ----------- Burn Function ----------- //

    public fun burn<K: store + copy + drop, T: drop>(
        self: &mut QuestLog,
        obj: EnterTheSueb<T>,
        key: K,
    ) {
        assert!(enter_the_sueb::is_authorized<K>(&self.id, key), EMintNotAuthorized);

        enter_the_sueb::burn<T>(&mut self.id, obj);
    }

    // ----------- Auth Functions ----------- //

    // this is pointless not like im getting users to mint
    // public fun authorize_mint_relic

    public fun authorize<K: store + copy + drop>(
        admin_cap: &AdminCap,
        self: &mut QuestLog,
        key: K
    ) {
        enter_the_sueb::authorize_app(
            admin_cap, &mut self.id, key, utf8(b"quest_log"));
    }

    // ----------- Test Only Function ----------- //

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}