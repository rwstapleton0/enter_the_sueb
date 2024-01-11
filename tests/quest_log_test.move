#[test_only]
module enter_the_sueb::quest_log_test {

    use enter_the_sueb::enter_the_sueb::{Self, AdminCap, Relic};
    use enter_the_sueb::quest_log::{Self, QuestLog};
    
    use sui::test_scenario::{Self as ts, Scenario};

    const ADMIN: address = @0xAD;

    // ----------- Test Authorized to mint ----------- //

    #[test]
    public fun test_mint_authorized() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_modules(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            let key = enter_the_sueb::create_mint_key<Relic>();
            quest_log::authorize(&cap, &mut log, key);

            quest_log::mint(&mut log, ts::ctx(&mut ts));
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    #[test]
    #[expected_failure(abort_code = 1001)]
    public fun test_mint_not_authorized() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_modules(&mut ts);
        {
            ts::next_tx(&mut ts, ADMIN);
            quest_log::mint(&mut log, ts::ctx(&mut ts));
            // quest_log::authorize(&cap, &mut log);
        };
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    // ----------- Test Init ----------- //

    #[test]
    public fun test_helper_function() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_modules(&mut ts);
        clean_up(cap, log, &mut ts);
        ts::end(ts);
    }

    #[test]
    public fun test_module_init() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            let ctx = ts::ctx(&mut ts);
            enter_the_sueb::test_init(ctx);
            quest_log::test_init(ctx);
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            let cap:AdminCap = ts::take_from_sender(&mut ts);
            ts::return_to_sender(&mut ts, cap);
        };
        
        ts::end(ts);
    }

    // ----------- Helper functions ----------- //

    #[test_only]
    public fun clean_up(
        admin_cap: AdminCap,
        log: QuestLog,
        ts: &mut Scenario
    ) {
        ts::return_to_sender(ts, admin_cap);
        ts::return_shared(log);
    }

    #[test_only]
    public fun init_modules(ts: &mut Scenario): (AdminCap, QuestLog) {
        let (cap, log);
        {
            ts::next_tx(ts, ADMIN);
            let ctx = ts::ctx(ts);
            enter_the_sueb::test_init(ctx);
            quest_log::test_init(ctx);
        };
        {
            ts::next_tx(ts, ADMIN);
            cap = ts::take_from_sender<AdminCap>(ts);
            log = ts::take_shared<QuestLog>(ts);

        };
        (cap, log)
    }
}
