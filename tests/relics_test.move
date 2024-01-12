#[test_only]
module enter_the_sueb::relics_test {
    use enter_the_sueb::relics::{Self, RelicStash};

    use sui::test_scenario::{Self as ts, Scenario};

    const ADMIN: address = @0xAD;
    
    #[test]
    public fun test_module_init() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            let ctx = ts::ctx(&mut ts);
            relics::test_init(ctx);
        };
        {
            ts::next_tx(&mut ts, ADMIN);
            let stash: RelicStash = ts::take_shared(&mut ts);
            ts::return_shared(stash);
        };
        ts::end(ts);
    }
}