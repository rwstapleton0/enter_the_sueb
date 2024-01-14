#[test_only]
/// Testing the app authorizer, this give the ability to create different keys with different
/// types. Then we can authorize an app with specific functionality and this can be specified
/// by type. 
/// 
/// code style does alot of the heavy lifting and throws a type error in most cases, otherwise
/// a not authorize error (1001, 1002, 1003) will be thrown either in the app or enter the sueb.
/// 
/// Currently only written tests for quest_log, mint and burn for type relic but they all follow
/// the same dry flow. maybe write the rest at a later date.
module enter_the_sueb::app_authorizer {
    use enter_the_sueb::enter_the_sueb::
        {Self as ets, EnterTheSueb, AdminCap, MintKey, BurnKey, Relic, Warrior};
    use enter_the_sueb::quest_log::{Self as quest_log, QuestLog};
    
    use sui::test_scenario::{Self as ts, Scenario};

    const ADMIN: address = @0xAD;

    // == QuestLog == //

    // ----------- Test Authorized to Burn ----------- //

    // Authorize the app with a 'BurnKey' with the 'Relic' type. uses key to mint.
    #[test]
    public fun test_burn_authorized() {
        let ts = ts::begin(@0x0);
        let (cap, log, relic) = init_quest_log_authorize_and_mint<Relic>(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);

            let key = ets::create_burn_key<Relic>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::burn<BurnKey<Relic>, Relic>(&mut log, relic, key);
        };
        clean_up(cap, log, &mut ts); // normal clean up as we burnt relic.
        ts::end(ts);
    }

    // Fails, trys to Burn without authorizing.
    #[test]
    #[expected_failure(abort_code = quest_log::EMintNotAuthorized)]
    public fun test_burn_not_authorized() {
        let ts = ts::begin(@0x0);
        let (cap, log, relic) = init_quest_log_authorize_and_mint<Relic>(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_burn_key<Relic>();

            quest_log::burn<BurnKey<Relic>, Relic>(&mut log, relic, key);
            // quest_log::authorize(&cap, &mut log);
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // Fails, mints warrior, creates key:'BurnKey<Relic>' passes key and key-type as K to 
    // mint<K, T>, fails when we specify the T type as Warrior, all other combinations will
    // throw a type error.
    #[test]
    #[expected_failure(abort_code = ets::EBurnNotAuthorized)]
    public fun test_burn_with_wrong_type() {

        let ts = ts::begin(@0x0);
        let (cap, log, relic) = init_quest_log_authorize_and_mint<Warrior>(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_burn_key<Relic>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::burn<BurnKey<Relic>, Warrior>(&mut log, relic, key);
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // Trys to run burn function with a mint key.
    #[test]
    #[expected_failure(abort_code = ets::EBurnNotAuthorized)]
    public fun test_burn_with_wrong_key() {

        let ts = ts::begin(@0x0);
        let (cap, log, relic) = init_quest_log_authorize_and_mint<Relic>(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_mint_key<Relic>();
            // mint key is already authorized
            // quest_log::authorize(&cap, &mut log, key);

            quest_log::burn<MintKey<Relic>, Relic>(&mut log, relic, key);
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // ----------- Test Authorized to mint ----------- //

    // Authorizers the app with a 'MintKey' with the 'Relic' type. uses key to mint.
    #[test]
    public fun test_mint_authorized() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_mint_key<Relic>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::mint<MintKey<Relic>, Relic>(&mut log, key, ts::ctx(&mut ts));
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // Trys to mint without authorizing.
    #[test]
    #[expected_failure(abort_code = quest_log::EMintNotAuthorized)]
    public fun test_mint_not_authorized() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_mint_key<Relic>();

            quest_log::mint<MintKey<Relic>, Relic>(&mut log, key, ts::ctx(&mut ts));
            // quest_log::authorize(&cap, &mut log);
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // Fails, creates key:'MintKey<Relic>' passes key and key-type as K to mint<K, T>, fails
    // when we specify the T type as Warrior, all other combinations will throw a type error.
    #[test]
    #[expected_failure(abort_code = ets::EMintNotAuthorized)]
    public fun test_mint_with_wrong_type() {

        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_mint_key<Relic>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::mint<MintKey<Relic>, Warrior>(&mut log, key, ts::ctx(&mut ts));
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // Trys to run mint function with a burn key.
    #[test]
    #[expected_failure(abort_code = ets::EMintNotAuthorized)]
    public fun test_mint_with_wrong_key() {

        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = ets::create_burn_key<Relic>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::mint<BurnKey<Relic>, Relic>(&mut log, key, ts::ctx(&mut ts));
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // ----------- Test Init ----------- //

    #[test]
    public fun test_init_quest_log_authorize_and_mint_helper_function() {
        let ts = ts::begin(@0x0);
        let (cap, log, obj) = init_quest_log_authorize_and_mint<Relic>(&mut ts);
        clean_up_minted(cap, log, obj, &mut ts);
        ts::end(ts);
    }

    #[test]
    public fun test_init_quest_log_helper_function() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log(&mut ts);
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    #[test]
    public fun test_module_init() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            let ctx = ts::ctx(&mut ts);
            ets::test_init(ctx);
            quest_log::test_init(ctx);
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            let cap:AdminCap = ts::take_from_sender(&ts);
            let log: QuestLog = ts::take_shared(&ts);
            ts::return_to_sender(&ts, cap);
            ts::return_shared(log);
        };
        
        ts::end(ts);
    }

    // ----------- Helper functions ----------- //

    #[test_only]
    public fun init_quest_log_authorize_and_mint<T: drop>(
        ts: &mut Scenario
    ): (AdminCap, QuestLog, EnterTheSueb<T>) {
        let (cap, log) = init_quest_log(ts);
        let ets: EnterTheSueb<T>;
        {
            ts::next_tx(ts, ADMIN);
            let key = ets::create_mint_key<T>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::mint<MintKey<T>, T>(&mut log, key, ts::ctx(ts));
        };
        {
            ts::next_tx(ts, ADMIN);
            ets = ts::take_from_sender(ts);
        };
        (cap, log, ets)
    }


    // Initiates enter the sueb and quest log. returns 'AdminCap' and 'QuestLog'
    #[test_only]
    public fun init_quest_log(
        ts: &mut Scenario
    ): (AdminCap, QuestLog) {
        let (cap, log);
        {
            ts::next_tx(ts, ADMIN);
            let ctx = ts::ctx(ts);
            ets::test_init(ctx);
            quest_log::test_init(ctx);
        };
        {
            ts::next_tx(ts, ADMIN);
            cap = ts::take_from_sender<AdminCap>(ts);
            log = ts::take_shared<QuestLog>(ts);
        };
        (cap, log)
    }

    public fun clean_up_minted<T>(
        admin_cap: AdminCap,
        log: QuestLog,
        obj: EnterTheSueb<T>,
        ts: &mut Scenario
    ) {
        ts::return_to_sender(ts, obj);
        clean_up(admin_cap, log, ts);
    }

    // Handles cleaning up test 'QuestLog' and 'AdminCap'
    #[test_only]
    public fun clean_up(
        admin_cap: AdminCap,
        log: QuestLog,
        ts: &mut Scenario
    ) {
        ts::return_to_sender(ts, admin_cap);
        ts::return_shared(log);
    }
}