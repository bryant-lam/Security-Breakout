Security Breakout by Bryant Lam

The goal of this game is to escape your cell and the prison while the guards are busy.

Run file with:
consult(adventure).

Start game with:
start.

Enter commands using standard Prolog syntax.
Available commands are:
start.                           -- to start the game.
n.  s.  e.  w.                   -- to go in that direction.
combine(Component1, Component2). -- to combine two components.
open(Object).                    -- to open containers.
take(Object).                    -- to pick up an object.
take(Object, Container).         -- to pick up an object inside a container.    
drop(Object).                    -- to put down an object.
look.                            -- to look around you again.
burn(Object).                    -- to burn an object assuming you have to tool.
burn(Object, With).              -- to burn an object specifying the tool.      
describe(Location/Object).       -- to describe a location/object.
i/inventory.                     -- to display inventory.
instructions.                    -- to see this message again.
halt.                            -- to end the game and quit.

My locked door is the metal bars within the cell/prison.
Can be "unlocked" by burning with blowtorch.

Hidden objects are the burner_tube(inside drawer) and full_can_of_gas(inside bed).

The incomplete object is the blowtorch.
Combining both hidden objects.

Limited resource is time. Estimated 12 turns to complete the game, lose by 18.