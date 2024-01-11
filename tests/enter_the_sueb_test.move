#[test_only]
module enter_the_sueb::enter_the_sueb_test {
    // use sui::tx_context::{Self, TxContext};
    // use sui::object::{Self, UID};
    // use sui::transfer;

    use enter_the_sueb::enter_the_sueb::{Self, AdminCap};
    
    use sui::test_scenario as ts;

    const ADMIN: address = @0xAD;

    #[test]
    public fun test_authorize_app() {}

    #[test]
    public fun test_module_init() {
        let ts = ts::begin(@0x0);
        {
            ts::next_tx(&mut ts, ADMIN);
            enter_the_sueb::test_init(ts::ctx(&mut ts));
        };
        ts::end(ts);
    }
}

#[test_only]
module enter_the_sueb::test_minting_app {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    struct SuebMinter has key, store {
        
    }
}


#[test_only]
module enter_the_sueb::test_leveling_app {

    // use sui::tx_context::{Self, TxContext};
    // use sui::object::{Self, UID};
    // use sui::transfer;
}