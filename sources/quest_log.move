module enter_the_sueb::quest_log {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    use std::vector;
    use std::string::{utf8, String};

    use enter_the_sueb::enter_the_sueb::{Self, MintKey, Relic, AdminCap};
    
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

    // ----------- Auth Functions ----------- //

    public fun authorize(
        admin_cap: &AdminCap,
        self: &mut QuestLog
    ) {
        enter_the_sueb::authorize_app(
            admin_cap, 
            &mut self.id,
            enter_the_sueb::create_mint_key<Relic>(),
            utf8(b"quest_log"),
        );
    }


}