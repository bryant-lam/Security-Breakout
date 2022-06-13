:- dynamic i_am_at/1, at/2, holding/1, locked_container/1, container_content/2, locked_obj/1, stationary/1, time/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

/* Starting Point */
i_am_at(cell).

/* Hallway is north of cell, cafeteria is north of hallway */
path(cell, n, hallway).
path(hallway, s, cell).

path(hallway, n, cafeteria).
path(cafeteria, s, hallway).

/* Declare objects at room (Cell) */
at(bed, cell).
at(toilet, cell).
at(sink, cell).
at(drawer, cell).
at(metal_bars, cell).

/* Set containers and its content(s) */
locked_container(bed).
container_content(full_can_of_gas, bed).

locked_container(drawer).
container_content(burner_tube, drawer).

/* Set locked door*/
locked_obj(metal_bars).

/* Make objects unobtainable*/
stationary(bed).
stationary(toilet).
stationary(sink).
stationary(drawer).
stationary(metal_bars).

/* Start time */
time(1).

/* Increment time */
increment_time :- 
    retract(time(X)),
    (X < 15 -> true; 
        X = 15 -> 
            (write('You lightly hear footsteps from a team of guards marching.'), nl);
        (X > 15, X < 18) -> 
            true;
        X = 18 -> 
            (write('Time is up! Security guards have cleared the area and have taken you to prison for life.'), die)),
    succ(X, NewX),
    assertz(time(NewX)),
    !, nl.

/* These rules describe how to pick up an object. */

take(X) :-
    stationary(X),
    write('You can''t carry '), 
    write(X),
    write('.'),
    !, nl,
    increment_time.

take(X) :-
    holding(X),
    write('You''re already holding it!'),
    !, nl.

take(X, Object) :-
    (locked_obj(Object); locked_container(Object)),
    write(Object),
    write(' is closed/locked.'),
    !, nl,
    increment_time.

take(X, Object) :-
    \+locked_container(Object),
    retract(container_content(X, Object)),
    assert(holding(X)),
    write('You took the '),
    write(X), !, nl,
    increment_time.

take(X) :-
    i_am_at(Place),
    at(X, Place),
    retract(at(X, Place)),
    assert(holding(X)),
    write('OK.'),
    !, nl.

take(_) :-
    write('I don''t see it here.'),
    nl.


/* These rules describe how to put down an object. */

drop(X) :-
    holding(X),
    i_am_at(Place),
    retract(holding(X)),
    assert(at(X, Place)),
    write('OK.'),
    !, nl.

drop(_) :-
    write('You aren''t holding it!'),
    nl.

/* Rules that describe how to open an object/container */

open(Object) :-
    locked_container(Object),
    write('You have opened the '), write(Object), write('.'), nl,
    write('You see: '),
    display_container_contents(Object), !,
    nl, !,
    retract(locked_container(Object)),
    increment_time.

open(Object) :- 
    !, nl.

open(_) :-
    write('You can''t open this'), !, nl,
    increment_time.

/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).


/* This rule tells how to move in a given direction. */

go(Direction) :-
    i_am_at(Here),
    path(Here, Direction, There),
    at(metal_bars, Here),
    write('It seems to be locked.'), 
    nl, !,
    increment_time.

go(Direction) :-
    i_am_at(Here),
    path(Here, Direction, There),
    retract(i_am_at(Here)),
    assert(i_am_at(There)),
    !, look,
    increment_time.

go(_) :-
    write('You can''t go that way.'), nl,
    increment_time.


/* This rule tells how to look about you. */

look :-
    i_am_at(Place),
    describe(Place),
    nl,
    notice_objects_at(Place),
    nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
    at(X, Place),
    write('There is a '), write(X), write(' here.'), nl,
    fail.

notice_objects_at(_).


/* Display container contents */
display_container_contents(Object) :-
    container_content(X, Object),
    write(X), nl, fail.

display_container_contents(Object) :-
    nl, !.


/* Lists inventory */
i :-
    inventory.

inventory :-
    holding(X), 
    write('You have: '), nl,
    inventory_list.
  
inventory :-
    nl, write('You aren''t carrying anything.'),nl.
  
inventory_list :-
    holding(X),
    tab(2), write(X), nl,
    fail.
    inventory_list.


/* These rules describe how to combine two components*/
combine(Component1, Component2) :-
    holding(Component1),
    holding(Component2),
    ( ((Component1 = full_can_of_gas, Component2 = burner_tube); 
    (Component1 = burner_tube, Component2 = full_can_of_gas)) -> assert(holding(blowtorch)) ),
    write('You have created a blowtorch'),
    retract(holding(Component1)),
    retract(holding(Component2)), !, nl.

combine(_, _) :-
    write(''), !, nl.


/* Rules describe how to burn objects*/
burn(Object) :-
    holding(blowtorch),
    burn(Object, blowtorch), !, nl,
    increment_time.

burn(_) :-
    write('You have nothing to burn with.'), !, nl,
    increment_time.

burn(Object, _) :-
    \+ locked_obj(Object),
    write('This dangerous act would achieve little.'), !, nl.

burn(Object, blowtorch) :-
    i_am_at(cell),
    holding(blowtorch),
    locked_obj(Object),
    retract(locked_obj(Object)),
    retract(at(metal_bars, cell)),
    write('The lock is melted into liquid metal and the bars sway freely.'), !, nl.


/* This rule tells how to die. */

die :-
    finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
    nl,
    write('The game is over. Please enter the "halt." command.'),
    nl.


/* This rule just writes out game instructions. */

instructions :-
    nl,
    write('Enter commands using standard Prolog syntax.'), nl,
    write('Available commands are:'), nl,
    write('start.                           -- to start the game.'), nl,
    write('n.  s.  e.  w.                   -- to go in that direction.'), nl,
    write('combine(Component1, Component2). -- to combine two components.'), nl,
    write('open(Object).                    -- to open containers.'), nl,
    write('take(Object).                    -- to pick up an object.'), nl,
    write('take(Object, Container).         -- to pick up an object inside a container.'), nl,
    write('drop(Object).                    -- to put down an object.'), nl,
    write('look.                            -- to look around you again.'), nl,
    write('burn(Object).                    -- to burn an object assuming you have to tool.'), nl,
    write('burn(Object, With).              -- to burn an object specifying the tool.'), nl,
    write('describe(Location/Object).       -- to describe a location/object.'), nl,
    write('i/inventory.                     -- to display inventory.'), nl,
    write('instructions.                    -- to see this message again.'), nl,
    write('halt.                            -- to end the game and quit.'), nl,
    nl.


/* This rule prints out instructions and tells where you are. */

start :-
    instructions,
    look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(cell) :- 
    write('Cell'), nl, nl,
    write('A plain room with white brick walls and metal bars that are preventing'), nl,
    write('you from getting out are on the north. There is a metal toilet and sink for'), nl,
    write('hygiene and a closed drawer with unknown contents. A proper bed is tucked in the corner.'), nl,
    write('The alarm pops and the security guard run in panic to see the commotion.'), nl,
    write('You take this opportunity and try to escape while the guards are busy.'), !, nl.

describe(hallway) :-
    write('Hallway'), nl, nl,
    write('The left and right of the hallway are filled with empty cells belonging to the escaped'), nl,
    write('prisoners. Up ahead is an open door blinded by light.'), !, nl.

/* Ends the game once arriving at the cafeteria */
describe(cafeteria) :-
    write('Cafeteria'), nl, nl,
    write('You are in the cafeteria only to see bodies of unconscious security guards everywhere. '), nl,
    write('You walk to the past the next door and feel the warm sun and its brightness. You taste freedom'), nl,
    write('and are on your way to start a new life.'), nl, 
    die, !, nl.

describe(bed) :-
    i_am_at(cell),
    write('Somewhat comfortable bed with bed-frame and a storage compartment.'), !, nl,
    increment_time.

describe(toilet) :-
    i_am_at(cell),
    write('The toilet is clean'), !, nl,
    increment_time.

describe(sink) :-
    i_am_at(cell),
    write('The sink handles are a bit moldy but the sink bowl is clean.'), !, nl,
    increment_time.

describe(drawer) :-
    i_am_at(cell),
    write('A rusty metal drawer that can be opened.'), !, nl,
    increment_time.

describe(metal_bars) :-
    i_am_at(cell),
    write('A wall of metal bars being held together by a metal chain and lock.'), !, nl,
    increment_time.

describe(full_can_of_gas) :-
    write('Should probably combine this with something'), !, nl.

describe(burner_tube) :-
    write('Should probably combine this with some gas.'), !, nl.