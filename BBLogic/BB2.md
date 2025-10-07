# Ball Bearing Logic iteration 2
01234567890123456789012345678901234567890123456789012345678901234567890123456789
First iteration works as far as a full adder, but...

## What worked well

# The final gate design was sound, even if ensuring reliability was
  still a bit of work

# The speed bump was a great solution for the speed regulation

# The switch fabric worked great

## Problems with the first iteration

### The connections

The final connection design with strong connections in the base and
the signal paths and weaker ones in the support pillars is not a bad
design as such but it turned out that trying to connect everything
smoothly and keep everything connected while adjusting something was
already pretty hard for the full adder because of various printing
inaccuracies. Some parts really didn't like to be aligned just right
and some were a bit more loose, and the former tended to pop the
latter out of alignment.

### The size of the layout

Trying to make anything more complicated would fill a room pretty
quick.

### Feedback

There are some elements which would need to send a signal or at least
a trigger back, but this is problematic in a flat layout.

## The way forward and solutions to the issues

### The connections

We really need a frame to hold the whole contraption together and the
path connections need to be a bit more tolerant.

### The size

The obvious answer is to make the design more vertical. The basic idea
would be to stack the switch fabrics and for the basic design have the
gates loop back into the same tower. One gate out and second back
would probably be a good starting point.

The stacked switch fabrics would also allow dropping signals more than
one level.  This would help a lot in cases where we would need to
route a signal long way along the layout from where it's generated to
where it is actually used.

### Feedback

In a vertical design we can easily send a signal up with vertical bars
or such.

## Basic design

* Obviously will keep the grid design.  Instead of locating grid
* blocks to each other we'll locate each connected block separately to
* the frame.

## Frame design

The frame will be essentially a box shape with square grid walls. This
is so that the signals can enter and exit at any location. The gates
will attach outside the frame with the internal volume being the
switch fabric (and possibly other elements later).

### Frame design idea 1 (full 3d grid)

The frame could be a full 3d grid. The parts would need to be inserted
from the side as we want the signals to be continuous blocks to keep
the signal speed up. The part would be then locked in place at the
frame wall. We would need signals of various lengths ending in either
a drop down or a receiver from up (the previous fabric block split in
two essentially).

Pros: The frame itself would locate everything precisely. Easy to
modify something inside the frame by pulling out a block and inserting
another.

Cons: Lots of stuff to print, most of which might not even be needed.

### Frame design idea 2 (hollow inside)

