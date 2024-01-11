module enter_the_sueb::sueb_arena {
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, UID};
    use sui::transfer;

    struct SuebArena has key, store {
        id: UID
    }
    
}