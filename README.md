# Enter the sueb.

'Enter the sueb' full sueb system, this will include various features based around 'sueb warriors' and the 'Sueb Arena.' 

## Aspects of Sueb.

My ramblings:

Types: 

SuebWarriors - are the objects required to particate in the Arena.
relics - equipable objects to inhance SuebWarriors.

Main aspects:

SuebArena - game where 2 suebs compete and gain xp.

Other features:

item mixing - mix 2 or more items to make more powerful items.

## Link aspects of Sueb together.

It will feature an extendable system. (based on the suifrens example <- debateable)

This part is a big question mark for me right now.. how do I join aspect together. 
why do i want to link them together? because they share a lot of functionality.. leveling, stats.. 

limit some apps to only some functions? ie some games can only use xp and health functions, some apps can mint and some can do all??

suifren example:

// This kinda acts as an empty repeatable value... BUT we could change this to 
// give app different keys have a mint key, lvl key
// struct AppKey<phantom T> has copy, store, drop {}
the alternative was check types this is much a cleaner solution.
you can give multiple keys to object and then retrieve them by the differenet key objects.
    

This code is an example of letting various app use the same protected mint function 

PROS:
- the 2 types both share the same functionality, mint, gain xp, lose health/duration just where they can be used is different, but this is fine, as they are type?
- new games can be easily implemented, and use all the shared functionality.
- apps can do run there own functionality prior to use.

CONS:


alternatives?
- I think any alternatives would end up looking fairly simular to this as the xp, leveling and health lose would be good for new games too?

cant think of any rn... ok experimental sake, try the most left field from the suifrens example... thats not everything split up...

HOT POTATO!! we finish a game, which opens a hot potato that would fill either gain xp or lose health... doesnt really work -_- will have a think later
