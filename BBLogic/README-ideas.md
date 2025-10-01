### Ideas

## Elevators

The design really needs elevators to make it any kind of a
continuous-running apparatus. Two of the more promising and most often
seen are the screw lift and the chain conveyor.

The screw can lift multiple channels depending on the size, but seems
like a bit inconvenient and space-consuming. The signal channels would
need to diverge into individual lift channels and converge on the top,
also they exit on the same side as they enter, so keeping the motion
in the forward direction would be annoying.

The chain conveyor on the other hand seems more promising. The
conveyor itself doesn't need to have whole buckets to hold the balls,
it can have vertical channels quite similar to the horizontal signal
paths and just minimal claws to push the balls along. The chain and
sprockets can be modeled after a bicycle chain.

If the chain elevator can reliably pick up one ball at a time from a
tightly packed signal track, it will also solve the problem of feeding
the input signal to the circuit. We can have a mini elevator
(basically just a sprocket with integrated claws) to pick the balls
from a queue one at a time.

## Powering the elevators

The circuits will eventually need multiple elevators and signal
feeding elements, it would be inconvenient to power them with
individual motors. It would be equally inconvenient to try to
distribute the power along the circuit from the single source.

One elegant idea would be to drive the elevators from the clock
signal. We can assume that we want a clock signal distributed across
the layout at some point. This would of course need two clock pulses
on the descending side to raise the signal ball.

## Clock signal

We could have a dedicated frame tower type just for collecting clock
signals into a pool and then have a powered elevator (screw probably)
lifting them back to the start. The other option would be to have an
input and output pools and fill the input pool manually from the
output pool.

If powered, the clock frequency would depend on the lift speed. If
not, there would need to be some kind of a frequency regulator.
