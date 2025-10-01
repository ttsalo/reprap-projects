# Ball Bearing Logic NF (New Frame)

The idea of making the signal paths rigidly connected with jigsaw
connections while the frame is loosely connected turns out to be a bad
idea. At the scale of the full adder keeping everything connected
starts to be very hard, pushing in one connection can make something
else pop loose, fixing that makes something else loose and so on.

So, let's change the design into a rigid frame and (some) loosely
connected signal path parts.

## Design principles

- The frame is composed of several tower structures made from smaller
  blocks.
- We'll keep the base board with jigsaw connections to tie the towers
  together at the bottom.
- The grid system can stay as it is.
- The switching fabric can stay as it is. It will be housed inside the
  frame towers on stacked floors. The frame towers will have internal
  volume matching the grid scheme.
- 
