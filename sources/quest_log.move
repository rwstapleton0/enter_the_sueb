
/// could handle this one of 2 ways.
/// - accepting a quest mints and new quest.
/// - get a quest card, we then get quests(pointer to?) are held against that.
/// 
/// quick side though can we enforce a non 0 paymnet transfer policy even when sending
/// to stop people for farm items?

module enter_the_sueb::quest_log {
    use sui::tx_context::{TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::dynamic_field;

    use std::vector;
    use std::string::{utf8, String};

    use enter_the_sueb::enter_the_sueb::
        {Self as ets, EnterTheSueb, MintKey, Relic, AdminCap};

    const EMintNotAuthorized: u64 = 1001;
    
    // ----------- Quest Objects ----------- //

    struct QuestLog has key, store { id: UID }

    struct Quest has store {
        id: UID,
        name: String,
        desc: String,
        checkpoint_len: u64,
        // checkpoints: vector<Checkpoints> // use df here w/ key incrementing nums + is_fin bool
    }

    struct CheckpointKey has store, copy, drop {
        index: u64,
        complete: bool
    }
    // how to handle this? 
    struct Checkpoint has store, copy, drop {
        secret: String,
    }

    // ----------- Accessor Functions ----------- //

    public fun borrow_quest(self: &QuestLog, name: String): &Quest {
        dynamic_field::borrow<String, Quest>(&self.id, name)
    }

    public fun get_quest_desc(self: &Quest): &String {
        &self.desc
    }

    public fun get_quest_name(self: &Quest): &String {
        &self.name
    }

    // ----------- Create Functions ----------- //

    public fun create_checkpoint(secret: String): Checkpoint { Checkpoint { secret } }

    // ----------- Init Function ----------- //

    fun init(ctx: &mut TxContext) {
        transfer::share_object( QuestLog { id: object::new(ctx) })
    }

    // ----------- List New Quest Functions ----------- //

    public fun list_quest(
        _: &AdminCap,
        self: &mut QuestLog,
        name: String,
        desc: String,
        checkpoints: vector<Checkpoint>,
        ctx: &mut TxContext,
    ) {
        // 
        let checkpoint_len = vector::length(&checkpoints);

        let quest = Quest { id: object::new(ctx), name, desc, checkpoint_len };

        // Add quest checkpoints
        let i = 0;
        while( i < checkpoint_len) {
            let key = CheckpointKey { index: i, complete: false };
            
            let template = vector::borrow(&checkpoints, i); //
            let checkpoint = Checkpoint {
                secret: template.secret
            };

            dynamic_field::add(&mut quest.id, key, checkpoint);
            i = i + 1;
        };

        // List quest
        dynamic_field::add(&mut self.id, name, quest)
    }

    // ----------- Accept Quest Function ----------- //
   
    public fun accept_quest() {
        // some thing here.
    }

    // ----------- Checkpoint Function ----------- //

    public fun checkpoint_quest() {
        // some thing here.
    }

    // ----------- Complete Quest Function ----------- //

    public fun complete_quest(self: &mut QuestLog, ctx: &mut TxContext) {
        // some more stuff related to that other stuff.

        // Then call mint with its type
        
        // needs to pass a type creates a key base on quest type...
        let key = ets::create_mint_key<Relic>();

        mint<MintKey<Relic>, Relic>(self, key, ctx)
    }

    // ----------- Mint Function ----------- //

    public fun mint<K: store + copy + drop, T: drop>(
        self: &mut QuestLog,
        key: K,
        ctx: &mut TxContext,
    ) {
        assert!(ets::is_authorized<K>(&self.id, key), EMintNotAuthorized);

        ets::mint<T>(&mut self.id, ctx);
    }

    // ----------- Burn Function ----------- //

    public fun burn<K: store + copy + drop, T: drop>(
        self: &mut QuestLog,
        obj: EnterTheSueb<T>,
        key: K,
    ) {
        assert!(ets::is_authorized<K>(&self.id, key), EMintNotAuthorized);

        ets::burn<T>(&mut self.id, obj);
    }

    // ----------- Auth Functions ----------- //

    public fun authorize<K: store + copy + drop>(
        admin_cap: &AdminCap,
        self: &mut QuestLog,
        key: K
    ) {
        ets::authorize_app(
            admin_cap, &mut self.id, key, utf8(b"quest_log"));
    }

    // ----------- Test Only Function ----------- //

    #[test_only]
    public fun test_init(ctx: &mut TxContext) {
        init(ctx);
    }
}