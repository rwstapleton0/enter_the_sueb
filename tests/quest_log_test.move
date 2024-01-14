module enter_the_sueb::quest_log_test {
    use std::string;
    use std::vector;
    use enter_the_sueb::enter_the_sueb::{Self, AdminCap};
    use enter_the_sueb::quest_log::{Self, QuestLog, Checkpoint};

    #[test_only] use sui::test_scenario::{Self as ts, Scenario};
    #[test_only] const ADMIN: address = @0xAD;

    // ----------- Test Checkpoint Quest ----------- //

    // public fun test_accept_quest() {}

    // ----------- Test Accept Quest ----------- //

    // public fun test_accept_quest() {}

    // public fun test_get_quest_card() {}

    // ----------- Test Init ----------- //

    #[test]
    public fun test_init_quest_log_and_list() {

        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log_and_list(&mut ts);

        let quest = quest_log::borrow_quest(&log, string::utf8(b"Cool Quest"));

        assert!(quest_log::get_quest_desc(quest) == 
            &string::utf8(b"do something really cool :)"), 0);

        clean_up(cap, log, &ts);
        ts::end(ts);
    }

    #[test]
    public fun test_list_quest() {
        let ts = ts::begin(@0x0);
        let (cap, log) = init_quest_log(&mut ts);

        let checkpoints = create_dummy_checkpoints(3);

        quest_log::list_quest(
            &cap, &mut log,
            string::utf8(b"Cool Quest"),
            string::utf8(b"do something really cool :)"),
            checkpoints,
            ts::ctx(&mut ts)
        );

        let quest = quest_log::borrow_quest(&log, string::utf8(b"Cool Quest"));

        assert!(quest_log::get_quest_desc(quest) == 
            &string::utf8(b"do something really cool :)"), 0);

        clean_up(cap, log, &ts);
        ts::end(ts);
    }

    // ----------- Helper functions ----------- //

    #[test_only]
    public fun create_dummy_checkpoints(amount: u64): vector<Checkpoint> {
        let out = vector::empty<Checkpoint>();
        let i = 0;
        while (i < amount) {
            let secret = string::utf8(b"This is some secret");
            let c = quest_log::create_checkpoint(secret);
            vector::push_back(&mut out, c);
            i = i + 1;
        };
        out
    }

    #[test_only]
    public fun init_quest_log_and_list(
        ts: &mut Scenario
    ): (AdminCap, QuestLog) {
        let (cap, log) = init_quest_log(ts);

        let checkpoints = create_dummy_checkpoints(3);

        quest_log::list_quest(
            &cap, &mut log,
            string::utf8(b"Cool Quest"),
            string::utf8(b"do something really cool :)"),
            checkpoints,
            ts::ctx(ts),
        );
            
        (cap, log)
    }

    #[test_only]
    public fun init_quest_log(
        ts: &mut Scenario
    ): (AdminCap, QuestLog) {
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

    #[test_only]
    public fun clean_up(
        admin_cap: AdminCap,
        log: QuestLog,
        ts: &Scenario
    ) {
        ts::return_to_sender(ts, admin_cap);
        ts::return_shared(log);
    }
}