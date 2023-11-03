# Ball Bearing Logic iteration 2

First iteration works as far as a full adder, but...

## What worked well

# The final gate design was sound, even if ensuring reliability was still a bit of work

# The speed bump was a great solution for the speed regulation

# The switch fabric worked great

## Problems with the first iteration

### The connections

The final connection design with strong connections in the base and the signal paths
and weaker ones in the support pillars is not a bad design as such but it turned
out that trying to connect everything smoothly and keep everything connected while
adjusting something was already pretty hard for the full adder because of various
printing inaccuracies. Some parts really didn't like to be aligned just right and
some were a bit more loose, and the former tended to pop the latter out of alignment.

### The size of the layout

Trying to make anything more complicated would fill a room pretty quick.

### Feedback

There are some elements which would need to send a signal or at least a trigger
back, but this is problematic in a flat layout.

## The way forward and solutions to the issues

### The connections

We really need a frame to hold the whole contraption together and the path connections
need to be a bit more tolerant.

### The size

The obvious answer is to make the design more vertical. The basic idea would be to 
stack the switch fabrics and for the basic design have the gates loop back into the 
same tower. One gate out and second back would probably be a good starting point.

The stacked switch fabrics would also allow dropping signals more than one level.
This would help a lot in cases where we would need to route a signal long way along
the layout from where it's generated to where it is actually used.

### Feedback

In a vertical design we can easily send a signal up with vertical bars or such.

## Basic design

* Obviously will keep the grid design.
* Instead of locating grid blocks to each other we'll locate each connected block
  separately to the frame.

## Frame design

Let's build the frame from simple square grids. The blocks will get sandwiched
between upper and lower blocks, will probably need bevelling or something to
actually locate them. And this assembly can be locked together with snap-in
vertical bars. What's more, the gates attached to the outer edge can have a double
duty as the snap-in bars.

The snap-in bar mechanism will be important. Because the gates will overhang quite
a bit, the upper part will need some kind of hook and rotate into place action.

### Frame design idea 1

Horizontal bars should be triangular and the module bottom edges bevelled.
Vertical bars can be round and they need to slot into each other, either with cones
or cylinders fitting inside each other.

The module corners will have cuts corresponding to the frame vertical bars. If these
are tall enough, they will prevent the module from tilting in any direction. 

The remaining problem is that the insertion direction is still left unsecured. How
do we sandwich the modules between the frame layers? We don't want to extend every
module upwards, that would be a lot of (fragile) extra stuff to print for things like
basic track pieces.

Maybe spacer pipe sections. Drop in a module, insert spacers to the opposite frame
bars and once the next frame layer is in place, the spacers will lock the module in
place.

