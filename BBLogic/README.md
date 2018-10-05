/* Ball Bearing Logic by Tomi T. Salo <ttsalo@iki.fi> */

// Main parameters

// Main module dimensions (l=x, w=y, h=z)
l = 100; // Not really used
gate_l = 130; // Full gate length
w = 54; // Nominal width
h = 30; // Nominal height

ss_offset = 8; // How far the source/sink channel is offset from the main module (to negative y)

tol = 0.2;     // Fit tolerance

slope = 7; 

angle = -atan((h+tol)/(l+tol));
l_pitch = sqrt(pow((l+tol), 2)+pow((h+tol), 2));
h_pitch = h*cos(-angle);

r = 12.7/2;    // Ball radius
r2r = 10;       // Ball separation in a double track
R2R = 26;      // Track separation
r_tol = 1;   // Ball track tolerance
r_t = 1.8;       // Ball track wall thickness
mid_h = r+r_tol+r_t; // Pipe vertical midpoint - as low as possible to make room on top

switch_ramp_l = r + 0.5; // Length of the ramp in the switch section
roof_cut = r*2; // Width of the cut in open-roof pipe sections

pin_r = 3;
pin_h = 3;

frame_t = 3;
corner_t = 12;

/* Logic ideas:
  
    - Another idea: represent also the zero signals with a ball, using a double track
      for the signal. With this approach inverting simply switches the ball between the
      tracks and there is never a need for a separate source. This also eliminates the
      need for a clock signal for gate operation, although this when raises the problem
      of needing the synchronize signals arriving at different times.
     - Fanning out the signal will naturally still need a source, but this can be a simple
       repeater instead of having to build it into many gate types.

    - Gate types. AND, OR, NAND and NOR can all be changed into each other by adding
      inverters into the inputs and outputs. So these can be implemented by a single
      mechanism by varying the inversions.

    - The logic itself. What could the mechanical logic be like?
     - AND gate gets input signals A and B. The signal B goes to the output. The B's route
       shunts both levels of B to 0 unless there is an 1 signal in A, in which case the
       shunt doesn't operate.
     - Similarly for OR, the B goes to output, and a positive A shunts B from zero to one.
     - In both cases the A signal gets routed to the drain. Each drain can also operate
       one repeater down the line, which can then operate at the same frequency as the
       gate.
     - A cool trick would be to have the other ball to physically knock the other one
       from one value to another by curving partly into the other track and back again.
     - Synchronization: We want to stop both balls and then release them at the same time,
       so that the next elements can rely on the balls arriving at the same time.
      - A raised portion of the signal pipe and a spring-loaded ramp. The arriving single
        ball rides on the ramp and gets stopped by the end of the raised section. When
        the second ball arrives, their combined weight is enough to push the ramp down
        and release them together.

    - Module system:
     - The synchronization requires at least that part to slope downward. The cleanest
       approach would be to make a flat structure which then needs to be tilted a bit to
       work.
      - Actually let's make a "sawtooth" base which gives the modules the correct slope.
        This allows expanding the structure in all directions by stacking and tiling 
        the modules, and building it on a horizontal surface.
     - Module dimensions:
       - As small as possible, to save material and printing time.
       - Height is constrained by needing the ability for two balls pass each other
         vertically at the same time, without exceeding the boundaries of the module.
       - Width is constrained by having to fit two double tracks side by side, plus some
         extra space for fitting the various mechanisms.
       - Length is constrained by needing to fit inverter, synchronizer, logic decider and
         inverter back to back.
     - Module types:
       - Logic gate
        - Two inputs, implements one of the basic gates.
       - Repeater
        - Takes one input, gives two outputs, which are copies of the input.
       - Remote repeater
        - Takes an input as a signal from further down the mechanism, and outputs a
          copy of the signal.
       - Remote trigger
        - Counterpart of the remote repeater. Takes an input and outputs a copy of it
          farther up the machine.
       - Memory cell
        - Like repeater, but does not release the input, only the copy of it. Write-many
          cells would need to be able to release the previous input when receiving the 
          next input.
       - Remote memory cell
        - Analogous to remote repeater, except 
       - Router
        - Connects outputs to inputs. Must be able to move signals sideways. Has a
          standardized set of possible side connections.
         - Would be great if it could be itself composed of smaller building blocks so
           that we wouldn't need a large variety of modules for different input-output
           connection permutations.
        - Standardize the sideways movement to happen on the lower level and up-down
          on the upper level. This allows building the sideways movement separately from
          the up-down by usign independent half-height blocks, with .
     - Other features:
      - Things like ripple-carry adders have a lot of backtracking, and trying to arrange
        an adder flowing purely downhill would make the mechanism unreasonably long.
        Thus there is a need to move signals back uphill. This is obviously not feasible
        for the real ball signals without some sort of a powered return path.
      - Rotating shaft will probably be less problematic than a reciprocating one.
      - Should we have dedicated blocks for this? We could have two variants of router
        blocks, one that allows up-down signal tracks and one that allows two shafts to
        pass. Both would still allow sideways movement in the lower level.

    - First tests 10.6.2015:
     - The kick (logic gate core) works fine! With kick_dpipe(60, 10), it's very gently
       curving, can be probably made shorter without problems.
     - However the inverter doesn't. The helix formed by a circle doesn't pass a ball
       through, more twist it has, the flatter it becomes in z-direction.
      - Doesn't seem to have any easy ways to make the rotated helix out of a sphere,
        not a flat disk.
      - Other ideas?
       - Make the same thing somehow from curved sections?
       - Use the switch section and put ramps in the sides to kick each side into the
         other track. Test piece with 20 and 30 mm long invert sections calculated.
     - If the new inverter works, the basic logic gate is only missing the synchronizer.
      - Both inverters worked pretty much perfectly at any speed!
     - This only leaves the synchronizer. This really needs an elegant, compact solution.
      - Let's forget the spring-loaded ramp.
      - Rather, use a seesaw-type tilting mechanism, where two balls are needed to
        tilt the mechanism to the release position. The tube has a raised section and
        the seesaw in the floor.
      - Looking at other mechanism ideas, the seesaw which triggers only when all the
        balls are in position is an often used one.
      - Another is where one ball opens a gate that stopped the other. This is the same
        principle that the repeater/trigger mechanism needs, except for the synchronizer
        we don't know the order of the balls, so it would need two pairs of triggered
        gates, and the one that gets stopped by the gate before the trigger must have
        enough energy to trigger the other one's gate. Seems overly complicated.
      - Let's go with the tilting ramp idea. Putting a cutout in the floor and printing
        a separately attached ramp-counterweight piece will probably be the simplest idea.
    - Sync unit tests 16.6.2015:
     - Geometry itself looks good apart from 3 mm bar and particularly bearing thicknesses
       being kind of marginal.
     - However the pendulum mechanism has no chance of working without some fairly
       significant non-plastic counterweight.
      - Which makes the spring-loaded mechanism look attractive again.
      - Also the main tube does not have a raised ceiling yet, so the arriving ball
        loses it's speed pushing the pendulum down, and will push through against either
        a counterweight or a spring pretty easily. This may need modification.
     - Next steps:
      - Try to integrate all the bits into the full gate, with gate length less than
        10 cm (to allow printing vertically), and also create the slanting stand suitable
        for stacking, to allow calibrating the action with known slope.
     - Full gate designed. Includes input and output inverters, sync section and the
       kick section, but fitting everything into 100 mm is tough. The combination of
       the kick and output inverter in particular looks a bit dodgy, since there is no
       dual section between them to constrain the ball.
      - The sync section currently uses a symmetric seesaw. This is not necessary,
        the leading edge is not needed. 
    - Full gate test 17.6.2015:
     - Print had a discontinuity but it seems that the 15mm long inverter sections work
       fine at least.
    - Sync section testing 18.6.2015:
     - Slanted spring didn't work at all.
     - The seesaw void should have more tolerance.
     - The seesaw bearings should be larger.
     - Testing with horizontal spring designs.
      - Last iteration worked correctly with somewhat increased slope, but does not
        release using the design slope. Also there seemed to be some problems with left
        track pushing axle on that side down as well as tilting the ramp, so the right
        side did not release the ball since the ramp didn't tilt enough.
     - Action items:
      - Make the axis beefier. Maybe conical bearings?
      - Increase the cutout tolerance
      - Somehow make the ramp release easier. Maybe make it longer? The spring is
        already pretty flimsy.
    
    - New design idea 15.9.2015:
     - Trigger/latch assembly. Swinging axle at the top of the track, with trailing part,
       which can either be a trigger or a latch. A ball passing a trigger rotates the axle,
       a latch on the other hand stops the ball until the trigger rotates the axle and raises
       the latch.
     - This assembly can be used by many modules in suitable variants.
     - For the full gate, two series T-L assemblies in left-right and right-left will
       synchronize two input signals, as long as the track with trigger first and latch
       second does not release the trigger before stopping at the latch. Meaning that the
       T-Ls must be able to overlap.
     - Overlap is needed for compactness anyway. For a repeater we need two separate 
       T-Ls (one for each signal value) and they can mostly share the same area.
     - Additional requirement: Latch should only let one ball pass for one triggering.
       This is required for any module which has a storage of balls, such as the repeater.

    - Sync problem solution idea 3.1.2017:
     - Looking at existing mechanisms, not much else except gates where one ball gets
       stopped at a gate which is then released by another ball.
     - Double sync can be achieved by having two gates in sequence. The positioning
       must be so the the track where the trigger is first must get blocked by the gate
       after opening the other track's gate but before releasing it. That way the other
       track can pass the gate and reach the trigger, or if the arrival order is different,
       it will block at the gate, be released, reach it's own trigger and release the other
       track which was blocked after triggering the first.
     - This should also allow building the buffer element where one track holds a queue
       of balls and each ball on the other track releases one.
     - Geometry: How about having a hinge near the edge. Two flaps attached to the hinged
       bar extend down to the tracks. Larger flap farther from the hinge extends to the
       midpoint of the track, which means that the ball cannot push it up. Smaller flap
       extends less, which means that the ball's edge can push it up and in turn release
       the other track.
     - Tested one gate and it seems to work! Only problem was that the track closest to the
       hinge wasn't completely reliable in triggering the gate. Making the trigger block
       slanted might help with this.

    - Other ideas:   
     - The frame has printing problems and it's not actually needed for the gate, since the
       tracks themselves serve as structural.
      - Let's eliminate the long frame bars and simplify the ends with braces to the tracks.
     - Would it actually be better to divide the gate into smaller individual modules?
      - This way it would be possible to assemble gates from standard building blocks.
      - Module size could be 20mm. Inverters and sync gates would fit into this, and
        kick section would be two modules long.
      - Related to this, the frame-and-pin structure sucks.
       - Need a proper interlocking structure, something that allows the grid to
         stay together on any surface.
       - Also need a way to pull modules up to replace them.
       - Also it would be great to have rotational (180) symmetry to avoid having
         to print separate left- and right-handed versions of various parts. Inverters can
         probably be made symmetric. Kick sections are naturally symmetric. 
       - Can't figure out symmetric interlocking which wouldn't interfere with the
         printing or require extra loose bits. Let's forget the symmetry idea initially.
       - Or actually, let's use basic rectangular frames and attach them with clips.
         Easier to print
         
    - SYNC alternative:
     - denha's AND gate acts as a SYNC element. (Signal concept is different so
       it won't work as an AND gate here.)
     - It includes a double seesaw element where the individual seesaws block the
       outer, larger seesaw from tilting until all of them have been tipped.
     - Advantages: looks like it's more resistant to differences in ball arrival speeds
       and syncs them better, as all of the balls are stopped before the outer seesaw
       tilts and releases them. Also releasing balls from a reservoir is a problem for the
       gate. A raised gate will pass balls freely if they are waiting in line.
     - Disadvantages: many moving parts, may be hard to assemble, may be hard to
       fit into as little space as the raised gate SYNC.
      
    - XOR gate:
     - XOR gate requires at least three basic gates to implement. Not very efficient. 
       Can the basic gate be used as a XOR gate?
     - B input to kick A from 0 to 1 implements the three first rows of the truth table.
     - The last line can be implemented by inverting A, doing another kick section and
       inverting it again.
     - Can this be made to fit in the basic frame?
      - With more modular frame, with 20mm as the basic unit, XOR gate would need
        1 (sync) + 2 (kick) + 1 (invert) + 2 (kick) + 1 (invert) units, 7 in total (plus
        possible input inverters, if needed)
     - Implementing with mixed gates requires two repeaters and three gates
     - Perhaps a special double length gate would be best here. XOR stage 1 + stage 2.
     - This doesn't require making the basic gate format longer and saves a lot of space
       compared to mixed gate implementation.
     - Another alternative would be to go to a fully modular approach and construct
       every gate unit from individual modules. That would save for example the space
       used by the inverters when not needed in the design.
    
    - Testing 10.1.2017:
     - Gate works at least as a proof of concept, including the sync stage.
     - However, some bugs...
      - Inverters (at least some) don't seem to be completely reliable. Enlarge the
        inverting kickers?
      - The track nearest the hinge, where there is a trigger-gate sequence, can get
        stuck at the gate. Possibly just some wonkiness in the geometry of the gate bar.
      - If the slope angle is too steep, the ball which triggers the last gate gets ahead
        of the one that is released (as the triggering ball doesn't stop while the waiting
        ball needs to accelerate from standstill) and they don't meet in the kick section.

    - Testing 17.1.2017:
     - Several changes:
      - Open tops for the inverter and sync parts to observe the action.
      - Larger kicker parts in the inverter to improve the reliability.
      - Split the whole gate into smaller modules, connected together using separate clips.
        Probably a superior solution compared to built-in interlocking mechanisms. The clips are
        a bit fragile though.
     - The gate axle holders suck. Need to be redesigned.
      - Ideas?
       - Make the lower holder open from the side, make the upper holder deep enough to hold
         the bar properly. DONE. AND FAIL.
        - The side-opening holder doesn't hold the bar properly. The other side has bad fit
          (mostly because of inconvenient printing).
        - Redesigned again, now a slot along the whole length, on the outside. Looks
          like it might have some printing issues.
         - Yeah the shaft holders are a mess, mainly on the upper side.
        - Redesigned again:
         - Slot only on the downstream side to help upper side printability. The shaft
           can be inserted to that side first and then through the slot all the way.
         - Looser tolerance to allow shaft to move freely.
         - Extra cutout near the hinge to allow bar to fall to horizontal-
         
     - Clips are too fragile. Need to be redesigned.
    
    - SYNC issues for repeaters:
     - Repeaters will probably need a wholly different mechanism.
     - Amending the gate bar idea with a ratcheting system might work.
      - Just have the gate bar release a rotating wheel instead of the ball itself.
        Once one ball is released, the bar falls into the next slot before the next
        one is released.
       - Actually, don't use a slot, but a real ratcheting teeth. This should avoid the
         problem of how to ensure that the bar falls into the slot in limited time.
       - This should also work for the plain gate SYNC module, if the bar-gate
         mechanism is not reliable enough.
         
    - Testing 19.1.2017:
     - It's starting to look like the gate bar idea is a dead end. Just too unreliable.
       Using large enough tolerances to ensure that the bars move freely makes them
       move laterally, tilt, collide with the cutout edges and more.
     - Let's start again, with the ratcheting wheel idea. It will take more space for
       the double sync component, but it's useful for much more. Having a design
       for this component of high reliability will be crucial. It can be used for 
       one-to-many sync, for releasing balls from reservoirs one by one, detecting and
       routing a signal through non-ball mechanisms and more.
     
    - SYNC ideas again:
     - There has to be a way to sync the balls by using just two side-by-side wheels.
     - Let's consider the situation where the wheel lobes are vertical as 0. This should
       be the rest position.
      - A ball comes in. The wheel should be allowed to rotate to 45 degrees and
        stop the ball in position. This should also release the other wheel to rotate
        from 0 to 90 degrees. The other wheel should, at 45 degrees, release the
        first wheel.
      - This should be doable with two ratchet wheels and two double ratchets.
        Each ratchet has a hook for one wheel and a non-catching arm for the other.
        The non-catching arm raises the hook for the other wheel and another
        arm set stops the moving wheel as the first one has moved to released position.
        
    - Testing 24.1.2017:
     - First test print of the dual wheel sync (or rather, repeater) module.
      - Ratchet teeth on the wheel are more or less nonexistent. Will need to be
        enlarged quite a lot. DONE enlarged a bit, but see below.
      - 1 mm shaft tolerances are more than enough, but the shaft holder material
        thickness is too little. Also the undersides will need some printing support.
       - DONE, enhanced both.
      - The whole ratchet mechanism is too small. Enlarge the scale and worry about
        miniaturization once it actually works.
       - DONE, enlarged ratchet wheels and the arm. Frame size grew by 10 mm.
         Wheels stayed the same.
      - Also made the wheel assemblies two-piece to avoid annoying support issues.
    
    - Testing 26.1.2017:
     - Wheel assembly tolerances tested, 0.4 was loose on the 0.4 nozzle MendelMax.
       0.25 or 0.3 should be about right. With 0.5 nozzle 0.4 would not work.
     - Got the mechanism working a couple of times with some fiddling, however there are
       some issues:
      - Shafts and their holders are too rough: 
       - The stopped ball can jam the shaft so badly that the wheel will hold it 
         alone even when the pipes are vertical.
       - The ratchet arm will stay in the air and not fall under it's own weight.
     - Improvement ideas:
      - Make the ratchet arm spring-loaded. Separately printed with a snap-on
        connection.
      - Make the shaft holders undersized and drill them out.
       - To help this, drop the pipes to the bottom of the frame to make room
         for the mechanism. This affects all modules, but it seems that there is
         no benefit in having the pipes be in the midpoint vertically.
        - Drop DONE. Also allows the wheels to almost fit into the frame. Shaving just
          1-2 mm from the diameter or vertical positioning might fit them completely,
          but no need to worry about that right now.
          
    - SYNC ideas revisited...
     - Working AND mechanism demonstrated by denha has a ramp mechanism where
       outer ramp blocks or releases all balls at once and individual ramps inside the outer
       one each block the outer ramp separately.
     - In denha's mechanism, the outer ramp is hinged pretty far from the inner ramp hinge
       so that blocking action is pretty clear. 
     - Problem is that denha's mechanism requires a lot of vertical space because the outer ramp
       hinge is so far down.
     - New idea based on this:
      - Let's have the previous wheel mechanism, but with wheels rotating in lockstep.
      - Per-channel locking "triggers" will individually release the wheel just as the wheel
        is arriving at the wheel.
      - Once both balls have arrived, the wheels can rotate together.
        As the wheel rotation constrains the ball motion, the synchronisation should be
        very good and balls leave at virtually the same time and at same speed.
      - On the negative side, requires several moving parts. But hopefully these are not too
        challenging. The wheels are proven to work well.
     - Applicability for other modules:
      - Repeater: should work well, with the kick unit to copy the value to the second output.
     - Possible problems:
      - The wheel diameter has been minimized to save space and it sits quite high from the
        bottom of the track. It may be inconvenient to make the trigger reach that high.
       - Any alternatives?
        - Simply put the trigger on the roof instead of the floor and have it lock the top of
          the wheel. 
         - Advantage: all moving hardware is conveniently on the top. The tracks can remain
           right at the bottom.
         - Problem: making a trigger which keeps the wheel released even when
           ball has gone as far as it can while the wheel is still locked on the other side.
        - Have the trigger ride in a groove in the wheel? Allows the trigger profile to reach close
          to the shaft and lock on something with a smaller radius than the whole wheel.
    
    - Thoughts about the MODULE ARRANGEMENT.
     - Very large sloping plane is not a good idea, especially for signal backtracking.
     - Let's make helix type arrangement instead.
     - Two sloping planes side to side.
     - From the low end of one plane we have an U-shaped signal routing area which can
       connect the outputs to the inputs freely.
     - This arrangement makes it possible to route the sinks to sources much easier than in
       one big plane.
     - Remote repeaters can be implemented using vertical connections of some kind.
     - With remote repeaters and a ball reservoir at the top (why not even a powered lifter?)
       it's possible to make the mechanism iterate a built-in procedure.
       - For example, if we can transmit the carry back up and feed a sequential signal as
         input, we can perform arbitrarily long addition with just one full adder.
       - In fact with a ripple carry adders, there is no gain in building parallel adders since
         the carry signal will force them to be used sequentially anyways.
     - The iterating adder would be an awesome proof of concept and not even that big.
     - Practical signal routing:
      - For example in the full adder, we receive two input signals and need to duplicate
        them immediately. Then the total of four signals need to be distributed to the next
        two gates.
      - We can either try to route the signals in the middle of the plane, or dedicate all the
        routing to the connections between the planes.
      - Routing in the plane might work for two tracks, but if there are three parallel gate
        tracks, it likely becomes unworkable.
       - Might save hardware in some cases (with two tracks).
     - The helix might be the most compact way to arrange a lot of gates, especially a lot of
       them in parallel, but for the full adder a single stack of alternating planes might be
       simpler. 
      - Perhaps make bayonet mounts for the gate modules.
       - A length of the input and output tubes has larger diameter and grooves for bayonet
         lugs.
       - Between gate modules simple tubes can be inserted to ensure smooth operation.
       - At the ends, flexible conduits can be locked in with the bayonet connections. This
         avoids having to print complex rigid shapes for the plane interconnections. The conduits
         can be any old hoses or something printed.
     
    - Thoughts about SOURCES AND SINKS.
     - Perhaps best to go with a more generic source/sink mechanism from the beginning.
       Even the full adder feeds the input values to two gates at the beginning, which not
       be possible to feed from the discarded balls from the gates, even though the amount
       of final output signals equals the amount of input signals.
     - We basically only need a single source/sink signal through the system, but this
       needs:
      - Way for the repeaters to receive a ball if they lack one and let it pass if they don't.
        This allows for the global source to feed all repeaters as needed (eventually, but
        earlier repeaters would have priority here)
      - Either a lift or a clock signal to feed the sink.
       - Lift will allow indefinitely long operation, it will always be able to feed the repeaters
         eventually, as long as the repeaters have bidirectional sync.
       - Clock signal feeds from a reservoir at the top and allows operation only as long as
         there are balls in the reservoir.
      - Signal routing:
       - Without going to more interesting 3D arrangements, it might be easier to route the
         source/sink signal between two parallel gate module tracks. This allows either side to
         feed from and sink to the common signal, but requires different left and right side
         gates.
       - The other option would be for each gate "track" to have their own source/sink signal.
         This would allow more flexible gate arrangements, as the number of parallel gates
         would not be limited and they would not need to be differentiated.
       - However in this case the global source needs to be able to distribute the balls to
         different tracks fairly.
    
    - Thoughts about the MAIN MEMORY.
     - Memory cells can be based on the gate idea, but by having the sync wheel stop the
       memorized ball at the kick (1) position.
      - This way the incoming signal at position 0 will pass as 0 if the memorized bit is 0,
        and get kicked to 1 if the memorized bit is 1, allowing for a very simple read operation.
      - If a bit arriving at the memorized position can release the previous value and be
        stopped itself, the write operation will be very simple as well, simply feed the new
        value in and route the old one to a sink.
     - Memory bus (addressable memory cells)
      - Requires a demultiplexer to route the signal to the correct memory cell.
      - Multiplexer to select the correct output is trivial in this case, as we can simply route
        the outputs into a single stream.
        
    - Thoughts about the WORD LENGTH
     - In the case of the binary adder, we should be able to operate on arbitrarily long (within
       limits) words in a single channel.
     - Transmitting these words as sequential signals should be a great simplification, especially
       whenever they can be processed as sequentially as well.
     - The synced gate design should work on sequential signals out of the box.
     - Can we handle storing a word per memory cell?
      - Probably, but reading it non-destructively requires copying the output back to the input.
     - Making one of the adder inputs a memory cell and feeding the output of the adder back
       to the other input (via a remote repeater) would allow creating a counter.
  
    - Thoughts about REMOTE REPEATERS.
     - These should be able to use the same sync design as local gates and repeaters, if the
       wheels are simply linked together in some other manner than direct shaft between them.
       Triggers only need to act locally.
      - Simple interlinked cranks might work? At least if the ball travel takes the cranks past
        the dead points.
      - Problem here is that we can't use the kicker module to copy the value.
       - Possible solution: Input value arrives at one of two independent wheels with independent
         triggers and releases one of them. The source value is waiting on a similar gate, but
         one which allows it to select whichever side is released. For bidirectional sync, it can
         have one trigger which releases both wheels at once, or the trigger can be omitted
         if we can guarantee that it always has a value to source when the repeater is triggered
         (this is probable when a value is copied upwards and the sources are fed beginning from
         top).
       - 
       
     - Testing 23.2.2018:
      - The new sync frame idea looks workable. But:
       - Tolerances are way too loose
       - As expected, the trigger releases again before the ball is at the point of rotating the wheel
       
     - Testing 26.2.2018:
      - Finally very promising results with a couple of glitches!
      - The triggers work nicely. Whenever the wheel rotates well, the mechanism works as intended.
      - The rough 1mm tolerances are ok for the shaft holders.
      - The wheel void needs even more tolerance since the play in the shaft holders eats it. DONE
      - The inner shaft holders for the wheel are not even needed. DONE
     - Testing again:
      - Works, but some improvement ideas:
       - Shaft holders are too beefy (esp. wheel), shafts are hard to insert. Make thinner. DONE
       - The extra protrusion in the ratchet arm end is not necessary, eliminate. DONE
       - The ratchet arm groove in the wheel is maybe a little bit too tight. MONITOR
       - Might be possible to make the dimensions overall smaller? Drop the wheel down, lose
         some diameter, make the ratchet arm shorter. MONITOR
       - Add the extension to the ratchet arm, which blocks a possible second arriving ball if
         there is already a ball actuating the arm. LATER
     - TODO:
      - Integrate the new sync frame to the full gate. DONE
      - Add the source/sink channel. DONE
      - Route the discarded ball to the source/sink channel. DONE
      - Module connectors. DONE
      - Legs for module connectors. DONE
      - Module connector with input. DONE
       - Add labels to the channels (0/1) DONE
      - Module connector with output. Preferably with some nice indicators to show the values
        at the output. DONE
     
     - Some development ideas:
      - First prototype module: full gate, with feeding the second signal to the source/sink channel.
       - Fixing hopefully last glitches.
      - Second prototype module: repeater. Mechanism close to the full gate, but receives the second
        signal from the source/sink channel.
       - This needs:
       - Blocking action for the sync section. It must be able to send the second ball back to the
         sink if one ball is already waiting in the sync.
        - It might be possible for the wheel sync to handle a queue of multiple balls and only
          release one for each arriving ball in the other channel, in which case a new special
          blocking mechanism is not needed.
       - Kick section in the other direction to copy the input to the sourced value.
       - No need for the output inverter so the sync section can be moved farther up to make room for
         the source value routing (which is probably necessary)
     
     - STACKING/CONNECTIONS:
      - Tube connectors between the modules with friction fit. Forget the frame/corner scheme.
      - Have the connectors mount on friction fit stands (poles).
      - Pole mounts on top allows stacking.
      - H-shaped pole mounts can tie together parallel modules.
      
     - Testing 28.2.2018:
      - Promising with some glitches.
       - The kick path to sink route had some drooping filament, requiring making an
         "inspection hatch" to clean the route up.
       - The thinner shaft holders are ok and the parts move nicely, except...
       - The ratchet without the claw now allows the wheel to rotate too far and the
         ratchet arm gets blocked from getting raised once there is pressure on the other wheel.
       - The inverters don't work right anymore. The balls get stuck between the diverter part
         and the channel divider on the floor.
       - The output end connector is way too loose. (Input is ok.)  
       - Couldn't check the actual kicker action because of the ratchet release glitch.
       - The slope looks about right.
      - TODO from testing:
       - Fix the voids for the inverter section so that the ball movement is ok (or do some
         other kind of redesign) DONE, changed the kick ramps into X-shaped displacer setup.
       - Add the notch back to the ratchet arm or change the dimensions otherwise. DONE 1mm
       - Export output connector with smaller tolerance. DONE
       - Add an "inspection hatch" to the sink routes and the kick section. DONE
       
     - Testing 28.2.2018 II:
      - Even the 20 mm new style inverters have some glitches. However there seems to be space
        to make them still a bit longer. Let's monitor the situation.
      - Even with the notch the ratchet arms allow the wheel to rotate too far and that both
        takes the ball too far and the arm can fall again or jams the end of the arm under the
        backward sloping wheel fin.
       - Tested with longer arms and almost works. Only remaining problem is that the ball still
         allows the arm fall back too far when stopped by the wheel.
        - So: remove the notch again, extend the wedge by 1 mm. If there are still problems,
          wedge angle can still be increased.
          
     - Testing 1.3.2018:
      - Testing with 26mm arm, no notch. Almost there but not quite. Still has the problem that
        there is too much space between the position where the wheel stops the ball and the trigger
        wedge, so the trigger falls back into position for the ball that arrives first.
      - Options for changing the geometry:
       - Increase the wedge angle (easiest)
       - Increase the wedge width (not easy)
       - Decrease the space between the wedge and the stopped position (not easy)
      - Let's go with increasing the wedge angle now.
       - No dice. The arm gets now raised way high with 55 degree angle, but there is still space
         between the wedge and the wheel for the ball to get deadlocked.
       - Could decrease the width of the groove between the wheels to avoid the wedge getting
         tilted sideways.
       - Also there is a possibility of the ball getting wedged against the flat part of the wheel now.
         Perhaps from lengthening the arm (once the wheel is no longer loaded by the ball, it moves
         into a position where the flats are more diagonal.
       - And the increased wedge angle seems to interfere with arm resetting and stopping the wheel
         reliably at the next position.
     
     - SYNC fix:
      - Let's make a groove in the middle of the blocking fins of the wheel and have the wedge ride
        in the groove.
      - Busted again. The tolerences allow the fin to tilt so much that there is again a deadlock
        position for the ball.
        
     - SYNC fix again:
      - Let's put one wedge close to the middle of each track, about where the wheels are now,
        and move the wheels wider.
      - Tested: looks promising, the trigger action is now much more definitive.
        Still some minor issues though:
       - The blocking teeth are too small, resulting in printing problems.
       - The arm wedge and main arm are a bit too long. Seems that the wheel axis can jam
         against the wedge when the wheel is rotating. Also the main arm touches the blocking
         tooth while it's a bit too slanted. Let's take 1mm out of the wedge and 0.5 mm out of
         the arm length.
      - Tested improvements on 6.3.2018:
       - Finally nailed it, maybe! Saw only one single channel pass, reason unclear, otherwise
         looks to work very nicely.
      - Tested full gate on 6.3.2018:
       - Some occasional sync glitches, maybe needs some tuning or just better part cleanup.
       - However there is a new issue, now the A channel ball wants to change sides in the
         kick switch section even without input from the B channel. Probably the exit from the
         sync wheel gives it sideways momentum which causes it to cross the channel.
       - Fix idea: Let's make the switch section more constrained. It should be just a double
         pipe and the kick section should include the void which creates a specific path for
         the signaled ball to travel.
     
     - Repeater designed!
      - No blocking of more than one ball arriving in the sync section. Intention is that the sync
        section fills with balls and then starts diverting arriving balls to the source/sink channel.
        Dunno whether this will work.
     
     - Testing 7.3.2018:
      - Tested the new track idea for the kick-switch section and by itself, it works fine and
        solves the inadvertent switch issue. However the kick section is too timing-sensitive and
        with the current sync design, there is going to be a timing difference between the channels.
        The ball arriving last will pass through at speed whereas the one arrived first will
        accelerate toward the terminal velocity. Also the curve in the kick section slows the ball down.
        Since the timing has to match very closely for the balls to actually intersect, this is
        probably not going to be reliable.
      - Other alternatives with less critical timing?
       - Let's make part of the wall between signals movable. In default position it allows the
         A signal ball to travel straight. When B signal 1 is active, it pushes the wall slightly
         which then diverts the A signal from 0 to 1.
        - The moving wall can use a living hinge, maybe? Print orientation may be a problem though.
       - Could there be a solution integrated with the sync mechanism?
        - Doesn't feel likely.
     
     - The new KICK concept:
      - One idea is to make a moving wall do the job of the ball-to-ball contact so that the timing
        won't be critical anymore. Make cut to the roof between the signals and hang the piece
        there.
      - Another idea is to make a dedicated vertically hinged blade which gets rotated from side
        to side by the signaling channel. This then moves something else that switches the other
        channel.
       - This would be useful to many other modules as well. Even memory?
       - 
*/

module corner() {
  polyhedron(points=[[0, 0, 0], [corner_t, 0, 0], [0, corner_t, 0], [0, 0, corner_t]],
             triangles=[[3, 1, 0], [1, 3, 2], [0, 1, 2], [2, 3, 0]]);
}

module pins(pin_tol=0) {
  for (i = [0, l])
    for (j = [0, w])
      translate([i, j, 0])
        cylinder(r=pin_r+pin_tol, h=pin_h+pin_tol, $fn=24);
}

module frame_no_pins(bars=true, cross_supports=false, midsupport=0) {
//  cube(c);

  if (bars) {
  for (i = [0, w-frame_t])
    for (j = [0, h-frame_t])
      translate([0, i, j])
        cube([l, frame_t, frame_t]);
  for (i = [0, l-frame_t])
    for (j = [0, h-frame_t])
      translate([i, 0, j])
        cube([frame_t, w, frame_t]);
  for (i = [0, (l/2-frame_t/2)*midsupport, l-frame_t])
    for (j = [0, (w/2-frame_t/2)*midsupport, w-frame_t])
      translate([i, j, 0])
        if (i == (mid_h-frame_t/2) || j == (mid_h-frame_t/2)) {
          cube([frame_t, frame_t, mid_h]);
        } else {
          cube([frame_t, frame_t, h]); }
      }
  // Cross supports for ends
  if (cross_supports) {
        translate([l/2, w/2, mid_h])
    for (i = [0, 1])
      for (j = [0, 1])
        for (k = [0, 1])
          mirror([i, 0, 0])
            mirror([0, j, 0])
              mirror([0, 0, k])
                translate([-l/2, -w/2, -mid_h])
      rotate([-45, 0, 0])
        translate([0, -frame_t/2, 0])
            cube([frame_t, frame_t, h/1.41]);
  }
  // Printability supports for far end
  if (cross_supports) {
        translate([l/2, w/2, mid_h])
    for (i = [1])
      for (j = [0, 1])
        for (k = [0, 1])
          mirror([i, 0, 0])
            mirror([0, j, 0])
              mirror([0, 0, k])
                translate([-l/2, -w/2, -mid_h])
        translate([corner_t-frame_t, 0, 0])
      rotate([-45, 45, 0])
        translate([0, -frame_t/2, 0])
            cube([frame_t, frame_t, h/1.41]);
  }
  if (midsupport) {
    translate([0, w/2-frame_t/2, mid_h])
      cube([l, frame_t, frame_t]);
    translate([l/2-frame_t/2, 0, mid_h])
      cube([frame_t, w, frame_t]);
  } 
  translate([l/2, w/2, mid_h])
    for (i = [0, 1])
      for (j = [0, 1])
        for (k = [0, 1])
          mirror([i, 0, 0])
            mirror([0, j, 0])
              mirror([0, 0, k])
                translate([-l/2, -w/2, -mid_h])
                  corner();
}

module frame(midsupport=0, omit_pin_sockets=false) {
  difference() {
    frame_no_pins(midsupport=midsupport);
    if (!omit_pin_sockets)
      pins(tol);
  }
  intersection() {
    cube([l, w, h*2]);
    translate([0, 0, h]) pins();
  }
}

module light_frame() {
    difference() {
        intersection() {
            frame_no_pins(bars=false, cross_supports=true);
            cube([l, w, h]);
        }
        pins(tol);
    }
  intersection() {
    cube([l, w, h*2]);
    translate([0, 0, h]) pins();
  }
}

module small_frame(fl=20) {
  for (i = [0, w-frame_t])
    for (j = [0, h-frame_t])
      translate([0, i, j])
        cube([fl, frame_t, frame_t]);
  for (i = [0, fl-frame_t])
    for (j = [0, h-frame_t])
      translate([i, 0, j])
        cube([frame_t, w, frame_t]);
  for (i = [0, fl-frame_t])
    for (j = [0, w-frame_t])
      translate([i, j, 0])
        if (i == (mid_h-frame_t/2) || j == (mid_h-frame_t/2)) {
          cube([frame_t, frame_t, mid_h]);
        } else {
          cube([frame_t, frame_t, h]); }
}

// Basic divided 2D double track
module dpipe_2d(void=false, openroof=false, r_extra=0) {
    difference() {
      union() {
        translate([0, -r2r/2, 0])
          circle(r=r+r_tol+(void ? 0 : r_t)+r_extra, $fn=24);
        translate([0, r2r/2, 0])
          circle(r=r+r_tol+(void ? 0 : r_t)+r_extra, $fn=24);
      }
    if (openroof) {
        translate([-r-r_tol-r_t-0.1-r_extra, -roof_cut/2])
         square([r, roof_cut]);   
    }
  }
}

// Basic divided double track section
module dpipe(l, void=false, openroof=false, r_extra=0, labels=false) {
  translate([0, 0, (void ? -0.1 : 0)])
    linear_extrude(height=l + (void ? 0.2 : 0))
      dpipe_2d(void=void, openroof=openroof, r_extra=r_extra);
  if (labels) {
    translate([0, r2r/2-r/12, l/2-r/2])
      rotate([0, -90, 0])
        cube([r, r/6, r+r_tol+r_t+r_extra+r_t/2]);  
    translate([0, -r2r/2, l/2])
      rotate([0, -90, 0])
        difference() {
          cylinder(r=r/2, h=r+r_tol+r_t+r_extra+r_t/2, $fn=24);  
          cylinder(r=r/3, h=r+r_tol+r_t+r_extra+r_t/2+0.1, $fn=24);  
     }
  }
}

// Basic single track section
module pipe(l, void=false, r_extra=0) {
  translate([0, 0, (void ? -0.1 : 0)])
    cylinder(r=r+r_tol+(void ? 0 : r_t)+r_extra, h=l + (void ? 0.2 : 0), $fn=24);
}

// Twisting inverter. Note: does not work except for long lengths.
// Twisting circle extrude does not generally pass a sphere.
module dtwist(l, void=false) {
  linear_extrude(height=l, twist=180)
    dpipe_2d(void=void);
}

// Curve a pipe for the an 'angle' section of the torus
module pipe_curve(curve_r, angle, void=false) {
  translate([0, curve_r, 0])
  difference() {
    rotate_extrude(convexity = 10, $fn=60)
     translate([curve_r, 0, 0])
      circle(r=r+r_tol+(void ? 0 : r_t), $fn=24);
    translate([-r*2-curve_r, 0, 0])
      cube(r*4+curve_r*2, center=true);
    rotate([0, 0, 180+angle])
      translate([-r*2-curve_r, 0, 0])
        cube(r*4+curve_r*2, center=true);
  }
}

// Two back-to-back curve sections
module pipe_double_curve(curve_r, angle, void=false) {
  pipe_curve(curve_r, angle, void=void);
  translate([0, curve_r, 0])
    rotate([0, 0, angle])
      translate([0, -curve_r, 0])
        mirror([0, 1, 0])
          pipe_curve(curve_r, angle, void=void);
}

// Displace a pipe the given amount d in l
module pipe_displace(l, d, void=false, half=false) {
  chord = sqrt(pow(l/(half ? 2 : 4), 2) + pow(abs(d)/2, 2));
  chord_a = 90 - asin((abs(d)/2) / chord);
  angle = (90 - chord_a) * 2;
  curve_r = (chord / 2) / sin(angle/2); 
  echo(str(["Chord_a: ", chord_a]));
  echo(str(["Chord: ", chord, " Angle: ", angle, " Curve_r: ", curve_r]));
  mirror([0, (d<0) ? 1 : 0, 0]) {
    pipe_double_curve(curve_r, angle, void=void);
    if (!half)      
         translate([l/2, abs(d), 0]) mirror([0, 1, 0]) pipe_double_curve(curve_r, angle, void=void);
  }
}

/* Double pipe in which one track will curve outwards and back far enough to
   give a kick to the nearest track of an adjacent signal, if it has a corresponding
   switch section. */
module kick_dpipe(l, d, void=false) {
  translate([0, -r2r/2, void ? -0.1 : 0])
    linear_extrude(height=l + (void ? 0.2 : 0))
      circle(r=r+r_tol+(void ? 0 : r_t), $fn=24);
  translate([0, r2r/2, 0])
    rotate([0, -90, 0])
      pipe_displace(l, d, void=void);
  if (void) {
//    translate([0, r2r/2, -0.1]) cylinder(r=r+r_tol, h=0.2, $fn=24);
    translate([0, r2r/2, l-0.1]) cylinder(r=r+r_tol, h=0.2, $fn=24);
  }
}

/* 2D pipe section without the center divider */
module switch_dpipe_2d(void=false, roofonly=false, openroof=false) {
  difference() {
    union() {
      translate([0, -r2r/2, 0])
        circle(r=r+r_tol+(void ? 0 : r_t), $fn=24);
      translate([0, r2r/2, 0])
        circle(r=r+r_tol+(void ? 0 : r_t), $fn=24);
      if (roofonly) {
        translate([-(r+r_tol+(void ? 0 : r_t)), -r2r/2])
          square([(r+r_tol+(void ? 0 : r_t)), r2r]);
      } else {
        translate([-(r+r_tol+(void ? 0 : r_t)), -r2r/2])
          square([(r+r_tol+(void ? 0 : r_t))*2, r2r]);
      }
    }
    if (openroof) {
        translate([-r-r_tol-r_t-0.1, -roof_cut/2])
         square([r, roof_cut]);   
    }
  }
}

/* Double pipe section which allows the balls to move between
   tracks. With 'inverter' parameter adds X-shaped channels to divert the balls
   between the tracks. */
module switch_dpipe(l, inverter=false, void=false, roofonly=false, openroof=false) {
  if (void && inverter) {
     translate([0, -r2r/2, 0]) rotate([0, -90, 0]) pipe_displace(l, r2r, half=true, void=true);
     translate([0, r2r/2, 0]) rotate([0, -90, 0]) pipe_displace(l, -r2r, half=true, void=true);
  } else {
    translate([0, 0, (void ? -0.1 : 0)])
      linear_extrude(height=l + (void ? 0.2 : 0))
        switch_dpipe_2d(void=void, roofonly=roofonly, openroof=openroof);
  }
}

// Merges a double track into a single pipe
module merge_pipe(l, void=false) {
  rotate([0, -90, 0]) {
    translate([0, -r2r/2, 0])
      pipe_displace(l*2, r2r/2, half=true, void=void);
    mirror([0, 1, 0])
      translate([0, -r2r/2, 0])
        pipe_displace(l*2, r2r/2, half=true, void=void);
  }
}

// Produces a shaft holder void, including a gap along the side.
module shaft_holder_void(r, h, gap, gap_l=0, $fn=$fn) {
  cylinder(r=r, h=h, $fn=$fn);
  translate([0, -gap/2, 0])
    cube([r*3, gap, gap_l > 0 ? gap_l : h]);
}

// Produces a shaft holder, including printing support.
module shaft_holder(r, h, $fn=$fn) {
  cylinder(r=r, h=h, $fn=$fn);
  translate([0, -r, 0])
    cube([r*2, r*2, h]);
}

// Sync part parameters

gate_x = 14; // Gate positioning

// Wheel positioning in y: edges of the main cylinder relative to track centerline.
wheel_min_y = -8;
wheel_max_y = 8;

wheel_r = 10;
wheel_shaft_r = 4/2;
wheel_shaft_holder_r = 12/2;
wheel_shaft_holder_gap = 3.5;
wheel_shaft_square = 4;

wheel_void_tol = 1; // Tolerance for forming the void for the wheel

// Wheel shaft positioning in y
wheel_shaft_min_y = -12;
wheel_shaft_max_y = 12;

// Wheel ratchet parameters
wheel_ratchet_min_y = -13.5;
wheel_ratchet_max_y = -10;
wheel_ratchet_r = 16/2;
wheel_ratchet_tooth = 3;

// Wheel offset from track centerline vertically
wheel_offset_z = 12;

wheel_minor_r = 7;

// Ratchet arm parameters
ratchet_shaft_x = 39; // Shaft centerline x position
ratchet_shaft_r = 4/2;
ratchet_shaft_holder_r = 12/2;
ratchet_shaft_l = 16;
ratchet_shaft_z_offset = 11; // Shaft centerline offset from track centerline in y
ratchet_shaft_holder_gap = 3.5;
ratchet_arm_w = 8;
ratchet_arm_r = 3/2;
ratchet_arm_l = 24; // was 24
ratchet_arm_claw_h = 0;

ratchet_arm_release_r = 22;
ratchet_arm_release_w = 8;
ratchet_arm_release_gap = 4;
ratchet_arm_release_gap_r = 14; // Radius where the gap starts
ratchet_arm_release_tol = 0.5;
ratchet_arm_release_angle = -45;

sync_frame_l = 50;

// Ratchet arm. Origin is in the center of the rotating shaft.
module ratchet_arm() {
   rotate([90, 0, 0])
     translate([0, 0, -ratchet_shaft_l/2])
       cylinder(r=ratchet_shaft_r, h=ratchet_shaft_l, $fn=24);
    translate([0, -ratchet_arm_w/2, -ratchet_shaft_r])
      cube([ratchet_arm_l, ratchet_arm_w, ratchet_shaft_r*2]); 
    translate([ratchet_arm_l-ratchet_shaft_r*2, -ratchet_shaft_r, -ratchet_shaft_r])
      cube([ratchet_shaft_r*2, ratchet_shaft_r*2,
            ratchet_shaft_r*2 + ratchet_arm_claw_h]);
    intersection() {
      rotate([90, 0, 0])
        difference () {
          translate([0, 0, -ratchet_arm_release_w/2])
            cylinder(r=ratchet_arm_release_r, h=ratchet_arm_release_w, $fn=60);
          difference() {
            translate([0, 0, -ratchet_arm_release_gap/2])
              cylinder(r=ratchet_arm_release_r, h=ratchet_arm_release_gap, $fn=60);
            translate([0, 0, -ratchet_arm_release_gap/2])
              cylinder(r=ratchet_arm_release_gap_r, h=ratchet_arm_release_gap, $fn=60);
          }
        }
        rotate([0, ratchet_arm_release_angle, 0])
          translate([0, -ratchet_arm_w/2, -ratchet_arm_release_r])
            cube([ratchet_arm_release_r, ratchet_arm_w,
                  ratchet_arm_release_r]);
        translate([0, -ratchet_arm_w/2, 0])
            cube([ratchet_arm_release_r, ratchet_arm_w,
                  ratchet_arm_release_r]);
      }
}

module wheel(void=false, part1=true, part2=true) {
    t = void ? wheel_void_tol : 0;
    rotate([-90, 0, 0]) {
        if (part1)
        translate([0, 0, wheel_min_y-t])
           difference() { 
                // Double the tolerance for the radius of the main void
                cylinder(r=wheel_r+t*2, h=wheel_max_y-wheel_min_y+t*2, $fn=24);
            if (!void) {
                for (a = [0, 90, 180, 270])
                    rotate([0, 0, a])
                        translate([wheel_offset_z, 0, -1])
                            cylinder(r=r+wheel_void_tol, 
                                     h=wheel_max_y-wheel_min_y+t*2+2, $fn=24);
                
            }
            if (!part2)
              translate([-wheel_shaft_square/2-tol, -wheel_shaft_square/2-tol, wheel_min_y - tol])
                cube([wheel_shaft_square+tol*2, wheel_shaft_square+tol*2, 
                      (wheel_shaft_max_y-wheel_shaft_min_y+tol*2)/2]);
        }
        translate([0, 0, part2 ? wheel_shaft_min_y-t : 0])
            shaft_holder_void(r=wheel_shaft_r+t, 
                               h=(wheel_shaft_max_y-wheel_shaft_min_y+t*2)/(void ? 1 : 2)-(!part1 ? tol : 0), 
                               gap=void ? wheel_shaft_holder_gap : 0, $fn=24);
         if (!part1)
              translate([-wheel_shaft_square/2, -wheel_shaft_square/2, wheel_min_y])
                cube([wheel_shaft_square, wheel_shaft_square, 
                      (wheel_max_y-wheel_min_y)/2-tol]);
     }
}

module double_wheels() {
   for (mirror = [true, false])
     mirror([0, mirror ? 1 : 0, 0]) {
       translate([0, R2R/2, 0]) {
          rotate([-90, 0, 0]) {
           difference() {
             translate([0, 0, wheel_min_y])
              cylinder(r=wheel_r, h=wheel_max_y-wheel_min_y, $fn=24);             
                for (a = [0, 90, 180, 270])
                    translate([0, 0, wheel_min_y])
                    rotate([0, 0, a])
                        translate([wheel_offset_z, 0, -1])
                            cylinder(r=r, 
                                     h=wheel_max_y-wheel_min_y+2, $fn=24);
            translate([0, 0, -ratchet_arm_w/2-wheel_void_tol])
               cylinder(r=wheel_r, h=ratchet_arm_w+wheel_void_tol*2, $fn=24);
        }
        difference() {
         for (a = [0, 90, 180, 270])
          rotate([0, 0, a+45])
            translate([0, -wheel_shaft_r, -ratchet_arm_release_gap/2+ratchet_arm_release_tol])
              cube([wheel_minor_r, wheel_shaft_r*2, 
                    ratchet_arm_release_gap - ratchet_arm_release_tol*2]);
            /*translate([0, 0, -ratchet_arm_release_w/2-ratchet_arm_release_tol])
              cylinder(r=wheel_minor_r*2, h=ratchet_arm_release_w+ratchet_arm_release_tol*2); */
        }
    }
   }
   }         
   rotate([-90, 0, 0])
        translate([0, 0, -R2R/2+wheel_shaft_min_y])
          cylinder(r=wheel_shaft_r, h=wheel_shaft_max_y-wheel_shaft_min_y+R2R, $fn=24);
}

// Synchronization part void
module sync_void() {
  for (mirror = [true, false])
   mirror([0, mirror ? 1 : 0, 0]) {
       // Wheel cutout
       translate([gate_x, R2R/2, wheel_offset_z])
          rotate([0, -135, 0])
            wheel(void=true);
      // Ratchet shaft void
      translate([ratchet_shaft_x, R2R/2, ratchet_shaft_z_offset])
       rotate([90, 0, 0])
        rotate([0, 0, 135])
         translate([0, 0, -ratchet_shaft_l/2-wheel_void_tol])
           shaft_holder_void(r=ratchet_shaft_r+wheel_void_tol, 
                              gap=ratchet_shaft_holder_gap, h=ratchet_shaft_l+
                              wheel_void_tol*2, $fn=24);
     // Ratchet bar void
     translate([ratchet_shaft_x, R2R/2, ratchet_shaft_z_offset])
      rotate([90, 0, 0])
        rotate([0, 0, 45])
         translate([0, 0, -ratchet_arm_w/2-wheel_void_tol]) {
           cylinder(r=ratchet_shaft_holder_r+wheel_void_tol, 
                    h=ratchet_arm_w+wheel_void_tol*2, $fn=24);
             rotate([0, 0, 135])
              translate([0, -ratchet_shaft_holder_r-wheel_void_tol, 0])
              cube([ratchet_arm_l, (ratchet_shaft_holder_r+wheel_void_tol)*2,
                  ratchet_arm_w+wheel_void_tol*2]);
         }
    }
}

// Synchronization part frame
module sync_frame_parts() {
    for (mirror = [true, false])
        mirror([0, mirror ? 1 : 0, 0]) {
            translate([gate_x, R2R/2, wheel_offset_z])
              rotate([90, 0, 0])
                translate([0, 0, wheel_shaft_min_y])
                  rotate([0, 0, -45])
                     // Dropped the inner shaft holders,
                     // was h=wheel_shaft_max_y-wheel_shaft_min_y
                    shaft_holder(r=wheel_shaft_holder_r,
                                 h=wheel_max_y-wheel_shaft_min_y, $fn=24);
           translate([ratchet_shaft_x, R2R/2, ratchet_shaft_z_offset])
             rotate([90, 0, 0])
               translate([0, 0, -ratchet_shaft_l/2])
                 rotate([0, 0, -45])
                   shaft_holder(r=ratchet_shaft_holder_r, h=ratchet_shaft_l, $fn=24);
         }
}

/* Version of kick_dpipe which diverts the output to the sink channel. */
module kick_and_sink_dpipe(kick_l, total_l, d, void=false) {
  // Entering the kick
  translate([0, r2r/2, 0])
    rotate([0, -90, 0])
      pipe_displace(kick_l/2, d, half=true, void=void);
  // Non-kicking part to sink
//  mirror([0, 1, 0])
    translate([0, -r2r/2, 0])
      rotate([0, -90, 0])
        pipe_displace(total_l, -(w/2-R2R/2-r2r/2+ss_offset), half=true, void=void);
  // Kicking part to sink
  translate([0, r2r/2+d, kick_l/2])
      rotate([0, -90, 0])
        pipe_displace(total_l-kick_l/2, -(w/2-R2R/2+r2r/2+ss_offset+d), half=true, void=void);
  // Transfer void for the signaled channel
  if (void) {
    translate([0, R2R-r2r/2, kick_l/2])
      rotate([0, -90, 0])
        pipe_displace(20, r2r, half=true, void=void);   
  }
}

/* Full gate organization:
   0-5 mm straight section in input
   5-20 mm switch section
   20-70 mm sync section
   70-105 mm kick section
   105-110 mm straight intermediate section
   110-125 mm switch section
   125-130 mm straight section in output
*/
module full_gate(invert_a=false, invert_b=false, invert_c=false) {
  difference() {
    union() {
      translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(invert_a ? 5 : 20);
          if (invert_a)
            translate([0, 0, 5]) switch_dpipe(15, inverter=true); 
          translate([0, 0, 20]) switch_dpipe(sync_frame_l, roofonly=true);
          translate([0, 0, 20+sync_frame_l]) dpipe(40);
          //translate([0, 0, 20+sync_frame_l]) switch_dpipe(35);
          //translate([0, 0, 20+sync_frame_l+35]) dpipe(5);
          if (invert_c)
            translate([0, 0, gate_l-20]) switch_dpipe(15, inverter=false);
          translate([0, 0, gate_l-(invert_c ? 5 : 20)]) dpipe(invert_c ? 5 : 20); 
       }
      translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(invert_b ? 5 : 20);
          if (invert_b)          
            translate([0, 0, 5]) switch_dpipe(15, inverter=true);
          translate([0, 0, 20]) switch_dpipe(sync_frame_l, roofonly=true);   
          translate([0, 0, 20+sync_frame_l]) kick_and_sink_dpipe(35, 55, 7);
        }
      translate([70, w/2, mid_h])
        mirror([1, 0, 0])
          sync_frame_parts();
      translate([0, -ss_offset, mid_h])
        rotate([0, 90, 0])
          pipe(gate_l);
    }
    translate([70, w/2, mid_h])
      mirror([1, 0, 0])
        sync_void();
    translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(0.1, void=true);
          if (invert_a)
            translate([0, 0, 0]) switch_dpipe(20, inverter=false, void=true);
          else
            translate([0, 0, 0]) dpipe(20, void=true);
          translate([0, 0, 20]) switch_dpipe(sync_frame_l, roofonly=true, void=true);
          translate([0, 0, 20+sync_frame_l]) dpipe(40, void=true); 
          //translate([0, 0, 20+sync_frame_l]) switch_dpipe(35, void=true);
          //translate([0, 0, 20+sync_frame_l+35]) dpipe(5, void=true); 
          if (invert_c) {
            translate([0, 0, gate_l-20]) switch_dpipe(20, inverter=false, void=true);
            translate([0, 0, gate_l-0.1]) dpipe(0.1, void=true); 
          } else {
            translate([0, 0, gate_l-20]) dpipe(20, void=true);
          }
        }
    translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          if (invert_b) {
            dpipe(0.1, void=true);
            translate([0, 0, 0]) switch_dpipe(20, inverter=false, void=true);
          } else {
            translate([0, 0, 0]) dpipe(20, void=true);
          }
          translate([0, 0, 20]) switch_dpipe(sync_frame_l, roofonly=true, void=true); 
          translate([0, 0, 20+sync_frame_l]) kick_and_sink_dpipe(35, 55, 7, void=true);
          
        }
    translate([0, -ss_offset, mid_h])
      rotate([0, 90, 0])
        pipe(gate_l, void=true);
    // "inspection hatches"
    translate([110, -5, h/2]) cylinder(r=r, h=h); // Routes to sink
    translate([70+35/2, w/2+R2R/2, h/2]) cylinder(r=r, h=h); // Kick section
  }
}

/* Pipes to route balls from the source/sink channel into the nearest signal sync section. */
module source_route(l, void=false) {
  // Source to right channel negative value
  translate([0, -w/2+R2R/2-ss_offset, 0])
      rotate([0, -90, 0]) {
        translate([5, 0, 0]) pipe_displace(50, (w/2-R2R/2+r2r/2+ss_offset), void=void);
      }
  translate([0, r2r/2, 5+25]) pipe(35, void=void);
}

/* Full repeater organization:
   0-5 mm straight section in input
   5-20 mm switch section
   20-40 mm straight section
   40-90 mm sync section
   90-125 mm kick section
   125-130 mm straight section in output
*/
module full_repeater() {
  difference() {
    union() {
      translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5);          
          translate([0, 0, 5]) switch_dpipe(15, inverter=true);
          translate([0, 0, 20]) dpipe(20);
          translate([0, 0, 40]) switch_dpipe(sync_frame_l, roofonly=true);          
          translate([0, 0, 40+sync_frame_l]) mirror([0, 1, 0]) kick_dpipe(35, 6);
          translate([0, 0, 40+sync_frame_l+35]) dpipe(5); 
       }
      translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          source_route();
          difference() {
            translate([0, 0, 40]) switch_dpipe(sync_frame_l, roofonly=true);   
            translate([0, 0, 40]) switch_dpipe(sync_frame_l, roofonly=true, void=true); 
          }
          translate([0, 0, 40+sync_frame_l]) switch_dpipe(35);
          translate([0, 0, 40+sync_frame_l+35]) dpipe(5); 
        }
      translate([90, w/2, mid_h])
        mirror([1, 0, 0])
          sync_frame_parts();
      translate([0, -ss_offset, mid_h])
        rotate([0, 90, 0])
          difference() {
            pipe(gate_l);
            pipe(gate_l, void=true);
          }
    }
    translate([90, w/2, mid_h])
      mirror([1, 0, 0])
        sync_void();
    translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(0.1, void=true);
          translate([0, 0, 0]) switch_dpipe(20, inverter=true, void=true);
          translate([0, 0, 20]) dpipe(20, void=true);
          translate([0, 0, 40]) switch_dpipe(sync_frame_l, roofonly=true, void=true);          
          translate([0, 0, 40+sync_frame_l]) mirror([0, 1, 0]) kick_dpipe(35, 6, void=true);
          translate([0, 0, 40+sync_frame_l+35]) dpipe(5, void=true); 
        }
    translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          source_route(void=true);
          translate([0, 0, 40+20]) switch_dpipe(sync_frame_l-20, roofonly=true, void=true); 
          translate([0, 0, 40+sync_frame_l]) switch_dpipe(35, void=true);
          translate([0, 0, 40+sync_frame_l+35]) dpipe(5, void=true); 
          
        }
    //translate([0, -ss_offset, mid_h])
    //  rotate([0, 90, 0])
    //    pipe(gate_l, void=true);
    // "inspection hatches"
    translate([48, -6, h/2]) cylinder(r=r*.8, h=h); // Route to sink
  }
}

connector_l = 10;
leg_l = 4;
leg_d = 8;
input_l = 15;
output_l = 15;

module connector(level=0, input=false, output=false) {
  translate([0, 0, mid_h])
  rotate([0, 90, 0])
  translate([0, 0, -connector_l/2])
  difference() {
    union() {
      translate([0, w/2+R2R/2, 0]) {
        dpipe(connector_l, r_extra=r_t+tol, labels=true);
        if (input) translate([0, 0, -input_l-r_t]) dpipe(input_l+r_t);
        if (output) translate([0, 0, 0]) dpipe(connector_l+output_l+r_t);
      }
      translate([0, w/2-R2R/2, 0]) {
        dpipe(connector_l, r_extra=r_t+tol, labels=true);
        if (input) translate([0, 0, -input_l-r_t]) dpipe(input_l+r_t);
        if (output) translate([0, 0, 0]) dpipe(connector_l+output_l+r_t);
      }
     translate([0, -ss_offset, 0]) {
        pipe(connector_l, r_extra=r_t+tol);
        if (input) translate([0, 0, -input_l-r_t]) pipe(input_l+r_t);
        if (output) translate([0, 0, 0]) pipe(connector_l+output_l+r_t);
     }
     for (offset = [w/2+R2R/2, w/2-R2R/2, -ss_offset])
       translate([r+r_t, offset, connector_l/2])
         rotate([0, 90-slope, 0])
           cylinder(r=leg_d/2, h=leg_l+gate_l*sin(slope)*level);
     if (output) 
      for (offset = [w/2+R2R/2, w/2-R2R/2, -ss_offset])
       translate([r+r_t, offset, connector_l/2])
         rotate([0, 90-slope, 0])
           translate([-output_l, 0, 0])
           cylinder(r=leg_d/2, h=leg_l+gate_l*sin(slope)*level);
    }
    translate([0, w/2+R2R/2, output?-connector_l/2:(input?connector_l/2:0)]) {
       dpipe(connector_l, void=true, r_extra=r_t+tol);
       if (input) translate([0, 0, -input_l-connector_l/2]) dpipe(input_l+connector_l, void=true);
       if (output) translate([0, 0, connector_l/2]) dpipe(output_l+connector_l, void=true);
    }
    translate([0, w/2-R2R/2, output?-connector_l/2:(input?connector_l/2:0)]) {
      dpipe(connector_l, void=true, r_extra=r_t+tol);
      if (input) translate([0, 0, -input_l-connector_l/2]) dpipe(input_l+connector_l, void=true);
      if (output) translate([0, 0, connector_l/2]) dpipe(output_l+connector_l, void=true);
    }
    translate([0, -ss_offset, output?-connector_l/2:(input?connector_l/2:0)]) {
      pipe(connector_l, void=true, r_extra=r_t+tol);
      if (input) translate([0, 0, -input_l-connector_l/2]) pipe(input_l+connector_l, void=true);
      if (output) translate([0, 0, connector_l/2]) pipe(output_l+connector_l, void=true);
    }
    if (input) translate([-h, -w/2, -input_l-connector_l]) cube([h, w*2, input_l+connector_l]);
    if (output) translate([-h, -w/2, connector_l]) cube([h, w*2, output_l+connector_l]);
  }
}

// Basic sync frame, 50mm long. Wheel action prototype.
module sync_frame(all_parts=false) {
  difference() {
    union() {
      //small_frame(fl=sync_frame_l);
      translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, openroof=false);          
       }
      translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, openroof=false);
        }
      translate([0, w/2, mid_h])
        sync_frame_parts();
    }
    translate([0, w/2, mid_h])
      sync_void();
    translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, void=true);          
        }
    translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, void=true); 
        }
  }
  if (all_parts) {
    translate([gate_x, w/2, mid_h+wheel_offset_z])
      rotate([0, -45, 0]) double_wheels();
    translate([ratchet_shaft_x, w/2+R2R/2, mid_h + ratchet_shaft_z_offset])
      rotate([0, 205, 0]) ratchet_arm();
    translate([ratchet_shaft_x, w/2-R2R/2, mid_h + ratchet_shaft_z_offset])
      rotate([0, 220, 0]) ratchet_arm();
  }
}

// Basic invert frame
module invert_frame() {
   difference() {
    union() {
      translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5);          
          translate([0, 0, 5]) switch_dpipe(15, inverter=true);
          translate([0, 0, 20]) dpipe(5); 
       }
      translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5);
          translate([0, 0, 5]) switch_dpipe(15);
          translate([0, 0, 20]) dpipe(5); 
        }
    }
    translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5, void=true);
          translate([0, 0, 5]) 
            switch_dpipe(25, inverter=true, void=true);
          translate([0, 0, 20]) dpipe(5, void=true); 
        }
    translate([0, w/2-R2R/2, mid_h]) {
        rotate([0, 90, 0]) {
           dpipe(0.1, void=true);
          translate([0, 0, 24.9]) dpipe(0.1, void=true); 
        }
      translate([0, -r2r/2, 0]) pipe_displace(25, r2r, half=true, void=true);
      translate([0, r2r/2, 0]) pipe_displace(25, -r2r, half=true, void=true);
    }
  }
}

module kick_frame() {
  small_frame(fl=40);
  difference() {
    union() {
      translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(35);
          translate([0, 0, 35]) dpipe(5); 
       }
      translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          kick_dpipe(35, 7);
          translate([0, 0, 35]) dpipe(5); 
        }
    }
    translate([0, w/2+R2R/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(35, void=true);
          translate([0, 0, 35]) dpipe(5, void=true); 
        }
    translate([0, w/2-R2R/2, mid_h])
        rotate([0, 90, 0]) {
          kick_dpipe(35, 7, void=true);
          translate([0, 0, 35]) dpipe(5, void=true); 
        }
  }
}


//kick_dpipe(30, 7, void=true);
//kick_dpipe(30, 7);

//kick_and_sink_dpipe(35, 55, 7, void=true);

//difference() {
//  switch_dpipe(30, roofonly=true);
//  switch_dpipe(30, roofonly=true, void=true);
//}


//rotate([0, slope, 0])
//rotate([0, -90, 0])
//connector(level=1, input=true);

//rotate([0, slope, 0])
//translate([gate_l, 0, 0])
//connector(level=0, output=true);

rotate([0, -90, 0])
//rotate([0, slope, 0])
difference() {
    full_gate();
    translate([62, w/2+2, 10]) cube([150, 150, 50]);
    translate([-1, -50, 0]) cube([15+1, 150, 50]);
//full_repeater();
//sync_frame(all_parts=true);
}
//rotate([90, 0, 0]) 
//{
//wheel(part1=false);
//wheel(part2=false); 
//%wheel(void=true);
//}
//double_wheels();
//ratchet_arm();
//repeater_frame();
//rotate([0, 180, 0]) sync_bar();
//invert_frame();
//kick_frame();
//clip();
//light_frame();
