Ball Bearing Logic by Tomi T. Salo <ttsalo@iki.fi>

Logic ideas:
  
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
      - What is the easiest, most space-efficient way to do the kick?
       - Idea: a movable latch for the A channel, activated by the B channel. (Or vice versa)
       - This also allows creating memory cells in which the latch acts as the memory element.
       - For the gate element, the latch would be partial so that it forces the movement in only
         one direction.
       - Idea 2: let's make a "follower" which snaps to the empty middle part of the sync wheel
         shaft. It can then have trigger wedges and guides whereever needed. In the kick case the
         B0 channel would have a trigger edge which lifts out a guide from A0 channel. If
         the B signal is 1, the guide remains down and kicks the A signal from 0 to 1.

     - Testing 23.10.2018:
      - Implemented the moving follower kick idea and looks like it's a workable concept with some
        tuning.
      - DONE:
       - Constrain the follower movement better - add shaft holders on one or both sides of
         the wheel. (Requires extending wheel shaft) DONE
       - Fix the gate cutout printability DONE
       - Fix gate ends DONE
       - Make bigger input/output trays for repeatability testing DONE
       - Make the follower shaft holder bigger, requires cutout in the main body DONE
       - Maybe add a crossover floor section at the kicker part DONE
       - Add a little bit of slope to the design, the original seems a little bit marginal. DONE

      - Testing 24.10.2018:
       - TODO after second iteration:
        - Evaluate whether the trigger/kicker geometry is right (requires better constraining)
	  Working pretty good! Constraining is fine, no major glitches. Tuning required:
	 - The crossover is actually too far forward. The kicker deflects the ball into the central
	   divider which slows it down. DONE, moved 4 mm back, length still 16 mm.
        - Reimplement directing channel B to source/sink (later)
        - Add back the output inverter - required for NAND and NOR (and plain NOT). Different followers
	  can handle AND, OR and XOR plus B channel input inversion by switching the trigger side.
       - Other notes:
        - We need a double kicker for the XOR gate. Implementing it as a basic gate would save a lot
	  of hardware. This requires each kicker to not interfere with the ball that is entering
	  the channel on that side. Looking at the crossover geometry, the 16 mm long section leaves
	  quite a little space for this. 25 mm leaves a lot more. After that there are lessening
	  benefits.
	- TODO: Redesign the crossover to 25 mm long. Redesign a double sided kicker that performs
	  the inversion smoothly for each channel. It should be pretty much front-to-back symmetric.

      - Repeater optimization:
       - In the basic gate the B signal doesn't change. Instead of routing it to the SS channel and
         losing the value, it is possible to route it to the second output and reuse it for a second
         (or more) gate(s), eliminating a lot of hardware which would be required to replicate the value
         before the first gate and route it to the second gate.

      - Testing 28.10.2018:
       - XOR gate, tuned the tolerances a bit.
       - Very promising, some glitches but nothing major. Works OK with the original
         7 degree slope but it also seems that with a bit more slope the action is more definite.
         (Sync gate at least). So it seems that the 10 degree slope is the way to go.
       - Testing the switch section by hand:
        - There is just enough space with the kickers down for the ball to cross the tracks freely.
          Tilting the gate back and forth shows quite consistent cross movement in all directions.
        - The ball requires enough speed to get enough of a kick to move to the other side.
          Meaning that the kickers with size dictated by the track configuration will in turn
          dictate a minimum slope.

      - Next: GEOMETRY design.
       - Let's design a few building blocks which allow constructing more elaborate logic
       - Some design goals:
        - Two main modules, gates and interchanges. Gates are as expected, interchanges are
          square modules which can potentially connect to four different gates at the same time.
          They will also support dropping signals to lower levels for routing purposes.
        - The framework connects the gates and interchanges in an extensible grid pattern.
        - The framework allows assembling the gates and interchanges from top down without
          taking apart more than a single stack of modules.
       - Idea: 
        - A lot of time the signals will need to bypass a lot of modules. This is inconvenient
          in a linear arrangement (a sloping plane or a helix)
        - Instead, let's make a central interconnection area and have the gates loop back to it.
        - The interconnection area contains a grid of vertical signals. Different pieces allow
          diverting signals into gates and receiving them back. Other pieces allow switching
          signals laterally between the different channels.
        - Idea 2:
         - Let's base the signal routing on a regular grid which is then
           built out of rectangular interlocking blocks.
         - Let's also simplify the routing by using a combination of 
           horizontal lines and drops instead of steady slope. This
           allows routing in every direction within one interconnection
           area. Just need to take care of getting enough speed from a
           drop to reach the next element.
         - Implement the whole gate as two modules in the grid system?
	 - Implement the interlocking system along the ball route.
	  - Dovetail joints?
	  - Whole height dovetail joints problematic. Let's use partial height ones with the
	    tail in the originating part and the slot in the accepting part. These should be
	    feasible to print in either orientation.
	   - No, this both won't support the accepting part and make building of the route hard
	     (can't just drop in further sections, as they need to be pushed from below)
	  - Let's instead use separate connectors and grid blocks only have slots.
	   - Connectors have 4 round pins, grid blocks have two holes each. Connectors are laid
	     down, grid blocks inserted from top, connectors will support and hold the alignment.
	     For unsupported spans we can have longer and/or taller connector blocks that
	     span multiple grid blocks.
	   - Connectors don't need to connect to the blocks below, they can simply rest on them.
	     This makes removing whole sections simple.
	    - OTOH this means that the 
	  - Grid sizing
	   - The gates need to fit the grid so that they drop the signals one level
	   - The interconnection plane needs to be able to take a double pipe signal, drop it
	     and turn it 90 degrees in a 1x1x2 block.

      - Testing 23.1.2020:
       - Grid system idea seems sound. Testing with 36x36x24 grid (4 mm reserved for base,
         3 for connector blocks)
       - The fabric switch block works great, the one level drop gives enough speed for the
         balls to travel 4 blocks (individual, 2 inverting). Just barely fits into the grid
	 dimensions.
       - The non-sloping travel design gives some restrictions on the design (the size of the
         switching fabric from gate to switch to gate).
	- Try longer blocks
	- Go back to original print orientation so that balls don't travel across layers
	- Otherwise the fabric will simply need more Z difference from input to output. The
	  extra can be allocated to slopes in the signal routes. For example a signal travelling
	  two times the whole dimension of the fabric would drop half a level halfway to
	  switch block, then again another half on the way from switch block to the output.
	  This can obviously continue, scaling the fabric as large as we need.
	 - Same applies to longer signals, needs enough Z drop on the way.
	 - But the placement flexibility is probably worth it compared to a sloping build plane.
	- TODO:
	 - Longer blocks DONE
	 - Multi-block connector setups. Since not everything has support
           on every edge at the top, building over these requires longer
           signal blocks or connectors that span over the gap. DONE

      - Testing 29.1.2020:
       - Tested longer blocks. Balls clear 4+3 blocks easily after 1 level drop, except if
         there is crud on the ceiling, which is annoying to clean.
	- Omit the intermediate ceilings altogether? And add supports on the sides for the
	  upper levels instead.
        - TODO:
         - Scaffolding for filling empty spaces. DONE
         - Some kind of slot (but not snap-in) system between block tops
           and connectors. DONE
	   
      - Testing 13.2.2020:
       - Tested spacer (scaffolding) blocks with adjusted fit. Seems good
         for now. Connector to block bottom fit is pretty tight and
	 connector to block top is not loose, but pretty easy to remove.
       - The idea of when to use these:
        - The signal route must use connectors the whole way to ensure
	  the flow
	- The multi-connectors may be used to construct modules with
	  multiple parallel signals tied together, for example switching
	  fabric assemblies.
	- The spacers have slots for the connectors so that they can be
	  tied together at the top as well as on the bottom. Otherwise
	  we would have the modules simply resting on the spacers.
	- Also if we really want to scale this up, there will be a need
	  for larger scale module system. With just the block system,
	  replacing anything at the bottom requires disassembling anything
	  above. 
        - TODO:
	 - Remove unnecessary roofs from longer blocks, add side supports
	 - Obviously, the gate
	 - Source/sink signals (combine/diverge non-binary signals)
	 - Simpler ways of combining gates without building a whole switch 
           fabric section (one- or maybe two-level lateral movement between
           rows of gates oriented the same way)

      - Refactoring 17.3.2020-17.2.2021:
       - Scrap the connector system, too fiddly and too much stuff to print.
       - Replace with direct module-to-module interlocking system.
        - Let's go back to the dovetail idea.
        - Female connector on input, male on output.
         - Allows building from bottom up
         - Female connector has a floor which the male rests on, this allows
           for example the fabric switch blocks to support the incoming signals
           themselves. The input side of the signal still needs support though,
           but this can be much simpler than the previous pin connector idea,
           since the dovetail fit guarantees the signal paths.
         - Non-signal block connections can be simple square pegs and holes
           to roughly hold things together. The signals will then tie the
           structure together.
        - Macroblock structure?
         - Simplest form: plate with pegs to build on. However, connecting
           macroblocks together needs something else, as connecting lots of
           dovetail joints at the edge in one go is not really feasible.
         - Maybe something where a short and tall interconnection block slides
           from top to tie two macroblocks together at each position where
           they have a signal crossing between them. Ensures both the signal
           connectivity and locks the blocks together. If the connection is good
           enough, would even allow lifting several macroblocks together.
          - Would it also be a good idea to use these interconnection spaces to
            drop signals down to a lower layer of macroblocks? Probably depends
            on how specialized the macroblocks end up being. If the design is
            usually more efficient when dropping down inside a macroblock, it
            would be a waste to require routing the signal to the edge, dropping
            it there and routing it back inside the next block again.

      - TODO+DONE 11.3.2021:
       - Design a dovetail connection between modules
        - DONE, actually more of a jigsaw puzzle connection
       - Make the signal block minimal
        - DONE for the version with no support for blocks above
       - Redesign the scaffolding block with peg connections
        - DONE
       - Redesign a minimal scaffolding block. Remove the top and bottom solid
         blocks and use just the truss structure and peg blocks.
        - DONE
       - Redesign the switch fabric block with peg connections
        - DONE, but:
         - The printability now needs some work

      - 13.3.2021 Connection issues and possible solutions:
       - Change the setup so that signal tracks have negative connectors and other
         elements have positive ones and reverse the conicality
       - This actually makes a lot of sense, allowing straight signals to act as
         simple bridges with no other support.
         
      - Picking up again on 23.9.2022
       - The new connector idea still seems sound. It reinforces the signal path
         specifically and keeps the scaffolding as simple support. On the negative
         side, printability when off the printing surface is not great, but for
         multi block high structures it's going to be a problem anyways.
       - Redesigning the gate as roofless track-like structure, printed in the
         final orientation.
        - Make the gate from two separate single signal blocks?
       
       - Testing 6.10.2022
        - Tried improving the printability of the fabric block
         - There was a possibility of a bounce from inner to outer track on high
           speed input
         - However making the input curves higher slows down the balls. Might be
           useful for slowing down the signals in some designs.
         - Removing upper portions of output curves didn't work, would allow balls
           to move between tracks
	 - After tuning various parameters the block can be printed with minimal
	   supports and cleanup. Remember to adjust the support angles so that
	   the ball channel only gets support right as the exit end.

       - Development on 9.12.2022
        - Refactor the gate for the new connector system and solve some problems
	- Use roofless tubes for the gate, requires some work for refitting
	  the moving parts
	- What supports the upper end of the gate?
	 - It needs to have something along the full length to put it on
	   support blocks underneath. Adjusted 3x1 spacer block so that it
	   works also as a print support?
	  - Probably just the base plate and then whatever on top
	- How do we put anything on top of the gate?
	 - Either an integral structure or external supports
	 - Thinking of a larger circuit, each gate drops the ball one level
	   and the switch fabric another level.
	 - Meaning that the gate above will be 8 levels up, leaving 6 empty
	   grid levels between them (if we want to make a helix structure)
	 - This makes fully printed superstructure a very big print for any
	   larger circuit and the sane approach would be to use non-printed
	   parts

       - Testing 10.12.2022:
        - Modular interlocking build plate DONE
	- This is a must, assembling on flat surface is a no-go
	- However it turns out that making the spacer pegs loose is a bad
	  idea. The tightly fitting track system is not going to be exactly
	  precise and if everything under it is loose, it will tend to knock
	  the spacer towers over when doing anything.
	 - TODO: change the fit to be precise. The original idea of being able
	   to easily remove and insert large track modules is not worth the
	   downside of everything being built on a shaky foundation.
        - Thinking about supporting larger circuits...
	 - 1 gate wide (2 signals) fabric block requires 2 supports and the
	   gate block 4 supports.
	 - 2 gate wide fabric 4 supports and gate block 8 supports
	 - 3 gate wide fabric 6 supports and gate block 12 supports
	 - The fabric blocks are never in a line so they will require
	   a set of single towers
	 - However the gate block supports are always in two straight lines
	 - So, let's say we are 6 high, 3 gate wide, we would need total
	   of 12*6=72 spacer blocks
	 - But we can also use just 2 6 wide single height spacers (12 blocks)
	   and 4 5 high towers at the ends (20 blocks) cutting the total to
	   just 32.
	 - From this we could calculate the spacer block count for a given
	   circuit length and width. For a 3 wide circuit, 1 additional length
	   would require 6+4 blocks.
	 - Also, the fabric can turn signals in both directions so we can
	   build a zig-zag pattern (l-r-l-r) or a series of u-turns (l-l-r-r)
	   The first gives a less wide staight line and the second wider but
	   shorter straight line, with neither requiring building on top of
	   the existing circuit. Both leave empty space though.

       - Testing 13.12.2022:
        - Some interesting spacer results:
	 - 1 and 2 high spacers don't need crossbracing. Using just vertical
	   bars seems to work fine.
	 - 3 or higher vertical bars don't print nicely, there's too much
	   wobble at the top. This means we have to split higher supports
	   into at most 2-high sections.
	 - 3mm diameter crossbraces don't print nicely either, too little
	   cross section and the print ends uneven and weak.
	 - Increased crossbraces to 4mm dia and this helped, but because
	   of the overhangs the print doesn't go that smooth and now the
	   accompanying vertical bars are a problem even 2-high.
	 - However it turns out that with 2-high sections and 4mm crossbraces
	   the vertical bars are not even needed, the structure is strong
	   enough with just the cross-truss.
	 - So, TODO: remove vertical bars from spacers 3 or higher.
	   - Question: is the 3 high spacer ok with just one section?

        - Now for a new problem:
	 - Because the fabric blocks and gates are both now planned to have
	   peg connectors, they need to have at least one length of track
	   between them. This will add significant extra length to the
	   circuit.
	 - The fabric blocks need pegs on both input and output since the
	   curvature begins right away (well, 1mm away)
	 - So, change the gate to have peg holes instead, so we can plug
	   a gate directly to two fabric blocks when needed. This should
	   not be a problem since the gate does already have straight
	   sections at input and output (these might need to be lengthened)
	 - This now also means that the track sections need redesign'
	  - Which then raises the problem that the peg sections were
	    supposed to be the supporting ones and the holes supported ones.
	  - However, by inverting the wedge shape we can just as well
	    make the hole the supporting one.
	   - Which then raises another problem, how do we fit supporting
	     peg directly to supporting hole? The peg widens downwards
	     and the hole narrows downwards.
	 - WHAT IF... we just make the gate the supported one? This might
	   solve other problems as well. The track sections were supposed
	   to be bridges, but it shouldn't be an issue to move the spacers
	   from the gate ends one space to the adjacent track end when needed.
	   There's the slight problem of connecting two gates directly to
	   each other but that should be solvable with a special spacer.
	  - Nice features:
	   - Gate base track is now printable slanted with no supports
	   - Signal track blocks will be chainable with no extra effort
	   - DONE

       - Testing 14.12.2022:
        - The new gate track works great. Now only needs the logic bits.
	- The fabric block still has the problem that a ball can bounce
	  from the inner to the outer track. At least too much speed
	  triggers this, maybe something else (spin?). Same thing can
	  happen after the exit.
	 - Might not be a problem in practice as this test was with smooth
	   gate tracks, real gates are not so fast.
        - Modified the signal track connectors to work with the new idea
	- Also a note about the build plate sections: The fabric block
	  sections need to be square but the gate section N*3 by W.
	- Problem: The integral support for the fabric block now prevents
	  putting a supported 1-length signal section at the input, this
	  will be needed in circuits now that the signal supports the gate

       - Testing 15.12.2022:
        - Fixed generating non-square build plate sections, printing
	  some 4x3 to put between previous 4x4 plates (also 3x4, for
	  putting after turning 90 degrees while keeping the peg
	  orientations constant)

       - Testing 20.12.2022:
        - Printing some 4x3 and 3x4 plates to construct a build plate
	  assembly for longer circuits
	- TODO: End piece for signal tracks to stop balls from going everywhere
	 - DONE, works fine
	 - We'll also need a variant that fits into a gate directly.
	- Printing a gate track with an output support, seems this will be
	  needed pretty often
	 - However chaining gates also needs either a peg-peg adapter piece
	   or changing the gate output to a peg, so it can support the next
	   gate
	 - TODO: design the gate-to-gate support block
	  - DONE, and we can probably rely on the two jigsaw pegs, just
	    have small notch on the uphill gate to clear the center peg
	    of the spacer block
	   - Minor TODO: make sure this works on longer blocks, we'll
	     want to have one full-width block to support all gates at once
	- Fabric block fed directly from a empty gate track has serious
	  problems with balls jumping the track
	 - Adding a 2-long signal between the gate track output and fabric
	   input seems to fix this
	 - Solution maybe just avoiding feeding fabrics directly from
	   transfer tracks?
	 - Or adding some sort of a speed bump? Maybe just the wheel from
	   the gate. That should work, it will have some friction and it
	   will allow using a single kind of part for transfer tracks and gates.
	 

       - Full adder planning 20.12.2022:
        - Needs 7 gates total, 2 repeaters, 5 actual gates
	- 5 gates deep, circuit has only 3 but the need to repeat signals
	  dictates this.
	- 5 signals wide, 2 gates wide
	- Only one fabric block needed
	- The inputs are at level 6 if output is level 0

       - Porting the old full gate mechanics to grid system 21.12.2022:
        - First iteration of the new gate with old mechanism ported to it
	- Bugs:
	 - Ratchet arms will tend to fall of even with the collars added
	  - DONE: added collars to both sides, this should fix the issue.
	 - Wheel arm will also fall off from the shorter side
	  - DONE: added collars to the shorter side only, idea is to avoid
	    jamming as the gate track sections are not one piece
	 - Wheel is a little bit too low, balls will get stuck
	  - DONE: raised by 1mm
         - The moving parts are now as far up as possible, which means that
	   balls arriving at minimal speed will not get much more before
	   hitting the mechanical parts. Move the assembly downhill?
	 - The wheel is too low, balls can pass but just barely.
	 - The ratchet-tooth angle may be slightly wrong, meaning that
	   when one ball is loading the wheel and the other channel's
	   ratchet arm, that may cause too much friction for the second ball.

       - Testing 22.12.2022:
        - Moved the mechanicals 15mm downhill
	- Adjusted the wheel 1mm up
	- Other ideas:
	 - Maybe make the gate track pair one piece?
	  - Yeah, this is a good idea. The grid system itself doesn't locate the
	    gates well enough.

       - Testing 28.12.2022:
        - Constructing the gates on top of single towers is not a great idea.
	  Fixed the gate support piece to allow wider structures. These should
	  fix the gates in place pretty well.
	- The gate mechanicals have some problems... 
	 - The holders are too fragile, depending on plastic used.
	  - The ratchet arms don't need to rotate around so they can have a
	    flat on the shaft for inserting
	 - The wheel shaft gets pushed up by the balls and can jam itself
	   in the insertion gap. The ball can also get wedged against the
	   flat on wheel spoke.
	 - Print imperfections can also cause the ratchet arm to jam,
	   either it doesn't raise and can jam the ball (probably only
	   happens when the ball is slow), or doesn't fall back down and
	   fails to stop the wheel

       - Testing and development 29.12.2022:
        - DONE: reshaped the wheel teeth to be pointy, hoping to avoid
	  balls getting stuck leaning against the flat ends.
	- DONE: tuned the wheel shaft supports to be more minimal
	 - Doing a test print before any other improvements
	- DONE: make the shaft holders thicker and stronger
	 - Maybe just thicken them on the inside and subtract the
	   ball track out. There's plenty of extra space on the
	   inside as long as the balls clear the shaft holders.
	 - Made them a lot thicker, still broke a couple.
	- TODO: make the ratchet shaft flat on both sides so it can be
	  inserted easier? (maybe not worth it since we can't do that
	  to the wheel shaft anyways, it would jam)
        - DONE: the ratchet contact angle is wrong, ball arriving on
	  one side can also pop the ratchet on the other side.
	  Move ratchet 1mm back? Would that be enough?
	- TODO: the shaft holders are snapping at a specific point
	  (around or little below the shaft centerpoint),
	  reshape the holder to add some material there.
	  
       - Testing and development 30.12.2022:
        - Tested with new ratchet position, wheel printed with 0.15
	  layers and cleaned up better, seems to work a lot better now.
	 - However balls arriving fast enough, from the top of an empty
	   second gate track will start to cause problems. The first
	   ball can make the second signal ratchet to jump, and somehow
	   the second ball can also pass while leaving the first ball
	   still waiting (the wheel rotates so fast that the first ball
	   doesn't have time to accelerate and take the passing slot?)
	 - Also tested feeding several balls into one side
	  - Loading 3 balls seems to work fine. The fourth will sit on
	    the flat bit between gates.
	 - TODO: The follower arm lift wedge can actually kick the static
	   ball into the other track because the switch section allows it.
	  - Change the gates to have just one switch section? Maybe the
	    safest bet, but will limit part reusability. Planning the
	    full adder showed that optimizing the part count requires
	    quite a lot of differently handed gates.
	  - Or refactor the follower arm to keep the ball on the track?
	- Next steps:
	 - Print more components and test several gates in sequence.
	   See if we are then getting consistent action.
	  - Starting from entering a fabric block and then passing two
	    gates, the speed seems about right.
         - Seeing two problems: the wheel spoke may be in a position
	   to wedge the arriving ball and a faster ball may pass without
	   releasing the earlier one, the ratchet falls back down before
	   the other ball has started moving. Why does this even happen?
	   The wheels are on a single shaft, both balls should always
	   move forward when it rotates. Is this also the case of
	   the first ball leaning against the wheel arm instead of
	   taking the slot?
	  - TODO: Let's reshape the wheel so that once the ball arrives
	    at the locked position, it's in a wheel slot so that it's
	    not possible for one ball to proceed without the other.
	   - Wheel radius now 12 from 10, made the spoke symmetrically
	     pointy.
	   - One thing to watch out with adjustments is that the ratchet
	     stopper tooth has to rotate under the ratchet before the
	     ball lets it fall. Maybe reshape the ratchet release wedge
	     to make it stay up longer?
           - The second thing is that if possible, the wheel spoke should
	     clear the possible second ball in the queue.

       - Testing 3.1.2023:
        - The rehaped wheel seems to be working better, but there is still
	  a glitch. What seems to happen is that balls are arriving almost
	  at the same time, the ratchets release but slightly before the
	  balls are in the wheel slots. So, the first ball starts to rotate
	  the wheel and this blocks the second ball from entering the
	  slot.
         - How to fix?
	 - Adjust the ratchet wedge to release later? This way we should
	   be able to make sure that the ball is in the slot when the
	   wheel gets released and starts to rotate.
         - Change to three spoke wheel?
	 
       - Testing 4.1.2023:
        - Three spoke wheel with adjusted angles seems to have finally
	  fixed the issue of leaving one ball behind. Couple of glitches
	  but those seemed to be just some print inaccuracies jamming
	  the ratchet.
	 - This design doesn't work at all with more than one ball
	   queued but the four spoke one didn't work either. We'll
	   need something else to feed a queue into a signal.
	 - It also still has the problem with fast balls (fabric +
	   empty gate section).
	- Widen the lower parts of the shaft holders and the design might
	  be ready for a larger scale test.
	- TODO: Label holders. Something that just clips to the track
	  edges and has a label, either a printed letter or flat surface
	  for writing.
	- DONE: Followers for the rest of the gate types. Can we actually
	  fit two gates side by side with the current design? Also, could
	  the follower work with only the middle arm? TESTED, no, with
	  only middle arm it tilts too much when one input raises it, and
	  the other input gets inverted even with arm activated.
	  Also TESTED, the wheel shaft extension needs to be 2mm shorter. DONE
	  And the wedge didn't clear the wheel spokes, made 2mm shorter as
	  well.
	- DONE: The shaft holders still want to break. Cut off a bit from
	  the top? The gap for the axle doesn't need to be that long.
        - TODO: 1/8x slomo is enough for checking the gate action. Was
	  really easy to see how the fast ball kicks the first ball back.
	  Meaning that the wheel spokes still do not properly force the
	  balls to same movement.

       - IDEAS 5.1.2023:
        - Could the kinda inconvenient connections be replaced by magnets?
	  Insert from below, small spacing, snaps sections together...
	  Except that would rule out metal balls...
	- Something like this could work for the input
	  https://www.printables.com/model/318143-marblevator-starting-gate
	- Circuits do not need fully populated build plates, if we imagine
	  someone starting with a circuit idea they want to implement.
	  We could well minimize the ground pieces to much less as long
	  as everything stays somewhat interconnected on the bottom level.
	  The track connections are strong enough to ensure the actual
	  signal flows correctly. This will save a lot of plastic.
	 - Minimal design:
	  - The exit edge of the fabric square needs a full length
	    single width section (to support the signal ends or fabric
	    blocks which support the next gates)
	  - The enter edge likewise needs full length section to support
	    the gates feeding it
	  - The rest of the fabric square only needs some configuration
	    to support the fabric blocks not on the edges.
	  - The gate sections between need connections only along the
	    edged to join fabric blocks. The gates will be supported at
	    both ends by fabric blocks (for one gate sections) or
	    by intermediate support scaffolds if more than one gate
	    in sequence.
	   - Full adder design: 59 ground plate sections needed, 47
	     saved from compared to minimal fully populated design,
	     and somewhat more when compared to standard size rectangular
	     plate design.
        - Hermaphroditic ground connections maybe? These don't need
	  support from the sloping design. 

       - Testing 6.1.2023:
        - Starting the final assembly of the full adder
        - The base plate constructed from smaller pieces works great.
	  Also the peg tolerances are fine once printed with correct
	  Z leveling.
	- The shaft holders still consistently break when trying to
	  insert the shaft. Seems that making them stronger didn't help,
	  now that they are stiffer there is more force when inserting
	  the shaft and the end result is the same.
	 - Fix? Increase the gap? For the ratchet shaft, there should
	   never be anything pushing it up. For the wheel shaft,
	   the force should be forwards when the ratchet is holding it
	   and the ball tries to rotate it. 
	- If a signal needs to terminate before the final lowest level,
	  the standard end piece doesn't fit. Will need an end piece
	  that can replace a gate track section (currently the end piece
	  has a male peg that doesn't fit into the gate support block
	  that the preceding gate rests on, and the possible next
	  gate support block doesn't allow a spacer to be placed on it)

       - Testing 7.1.2023:
        - Full adder base plate printed and assembled
	- DONE: Design a tower that can fit on the gate support block
	  (needs to fit the peg)
	- DONE: The basic one height rectangular spacer corners need some
	  attention. Vertical spokes breaking really easily and some of
	  the bridging is pretty bad. Added some low-poly spheres into the
	  corners.

       - Testing 8.1.2023:
        - Proceeding with the full adder prototype.
	 - Tried an empty gate section feeding a gate again, same problem,
	   the fast ball bounces the stationary ball back.
	 - Need to design a section which can slow the ball down. Feeling
	   like adjusting the sync parts to deal with fast balls will cause
	   problems with reliablity in the common case.
	 - Maybe put two inverters (or even more?) into the section
	 - Or maybe a ramp with a stop at the end, the stop kills forward
	   momentum before allowing the ball to drop down and continue
	   along the slope
	 - DONE: slope section with two inverters, can add more if needed.
	   Just needs testing.
	 - Tested the 2-inverting slope, hard to say how much it helps.
	   Will test with series of 4 and 6 inverters as well.
	 - Tested 4 and 6, 6 is a no go, will randomize balls. 4 seems
	   to work, needs some more testing to see whether this are
	   reliable and sufficient. 2 doesn't work, it will throw the
	   ball into the gate in a curve which makes it invert once more.
	   If 4 starts showing problems, we may need some alternative
	   solution.
	- TODO: We'll also need (for some even larger circuits) a way to
	  force signals to zero, when feeding unnecessary balls to
	  repeaters. This should be a fairly simple variant of the inverter,
	  which we can put into either a flat or sloped signal section,
	  but what if we want to feed a gate from another directly?
	  Because we have the switch section on both sides of the gate,
	  it might be possible to force a set or clear on also the
	  triggering signal which otherwise just passes through unchanged.

       - Testing 9.1.2023:
        - The 3mm square vertical and 4mm round truss bars in spacer
	  blocks are proving quite annoying to print. Verticals break
	  and truss bars become blobby very easily, especially in the
	  middle joint (also overhang problems, as usual)
	 - Prototyped a solid block spacer, it's fine but even with just
	   2 perimeters and almost no infill, takes noticeably more plastic
	   (not time though).
	 - Now printing a version with 8mm truss bars, 2 perimeters,
	   0% infill. Hopefully the larger hollow structures fix the
	   blobbing issues. Time is about the same and plastic used
	   something like 15% more.
	 - DONE, 3 high spacers printed pretty much perfectly as a pair
	   and the strength seems very good. Seems like we can standardize
	   on these for spacers 3 or higher. What about 1 and 2?
	  - Looks like 2 can use the same design. Maybe a bit overkill though.
	  - 1 is probably fine with vertical bars now that we have the
	    reinforced corners.
	  - 5 high spacers were fine as well (the middles remained a
	    bit too hot though). Dunno what the practical maximum for
	    this design is. 

       - Testing 10.1.2023:
        - Printing the final two pieces! After that just some cleanup,
	  installation and can try some full circuit tests.
	- What about the labeling? Now that the 1-length input chutes
	  seem like the practical option, placing anything on top of them
	  is not a great idea.
	- We could simply subtract the letters from the 1-length pieces.
	 - This seems like the easiest idea. The end pieces need two
	   variants though, unless we use two variants of signal blocks,
	   which seems more annoying.
	 - Design ready, need to test in practice.
	- Looking at the lettered blocks gives an idea... could we add
	  some kind of a living spring mechanism to the pin (vertical
	  connectors, should rename those in the source file) connection?
	  Would be so nice to get a better snap-in action.

       - Testing 14.1.2023:
        - Final assembly done
	 - One of the 5-long gate supports has really bad fit for some reason
	   Can't get the upper section to fit well enough to get balls
	   rolling reliably. Will reprint with 0.2mm to hopefully get
	   better fit.
	  - Also the gate to gate connection doesn't seem to have any
	    clearance. DONE, add some tolerance in both ends.
	 - Printed some 6-high supports, seems to work fine. 
	 - TODO: fix the grid spacer gate support piece, it's using the
	   wrong pyramid truss call.
	 - The 4-inversion slowdown piece seems to be working fine for
	   the slowdown but it seems to flip signals. Need to brainstorm
	   something else for that. Otherwise the sync action looks
	   really promising, several runs through the whole set of
	   gates passed with no issues (except the inversions).
	  - Ideas?
          - Testing a series of 4 ski jumps (when printed, almost horizontal
	    when placed to the design... may need to reduce the slopes a
	    bit, but let's see).
	  - If just the jumps don't work, then we may need to look into
	    putting a top structure which completely stops the horizontal
	    speed, lets the ball drop down and start rolling from there.
          - Turns out the ramp sequence doesn't work at all, the bouncing
	    goes way too uncontrolled by the end.
	  - Go back to the top obstacle idea. The already implemented
	    ramps should work fine with that.
	  - DONE, implemented the ramp+tunnel idea and finally the action
	    seems foolproof. Even saw some balls bounce back, then continue
	    just as intended. Also feeding a 4-long straight section into
	    a fabric block is not a problem at all.

       - Testing 16.1.2023:
        - Several full test runs with all the logic done! But some
	  bugs seen...
	 - Some gates can get stuck. Seems there is 2 or 3 with some
	   finish issues, between the ratchet arm and the wheel, and
	   maybe in the wheel teeth as well.
	 - The double sided connectors in the gate support blocks
	   turned out more finicky than expected. Probably because
	   there are three parts to fit together there and the gates
	   were missing the clearances. Also because the truss flexes
	   a bit, when fitting one end, the other wants to pop out or
	   at least twist, which then causes signal glitches later.
	   Tuned some of the gates already, looks like the upper section
	   still needs some work. Also maybe we should make the gates
	   less stiff, put just one connector near the wheel shaft?
	   That's the only positioning-critical part.
	 - The logic arm trigger side can flip the ball, looks like.
	   Move the trigger closer to the center? Looks like it can
	   be moved 2 mm to the center. That should make it push the
	   triggering ball toward the edge rather than center. DONE
	- How to improve?
	 - Test everything individually and incrementally.
	  - "Test bench" for the gates at least, easy way to stress test
	    them a bit.
	  - When building the circuit, test fit every connection before
	    trying to build on the scaffolding. Check that there are air
	    gaps between track walls at each connection!
	  - Once the circuit is built, test run it before installing
	    the moving parts and check that there are no signal flips
	    or stuck balls (gates without moving parts might be too fast?)
          - For demo purposes the I/O markings are important.


       - Wild ideas 17.1.2023:
        - Elevators! The vertical screw conveyor can lift multiple channels
	  without mixing them. Multi-slot chain conveyor can as well. This
	  could be used to construct long circuits while keeping the height
	  low, but maybe the more interesting part would be to loop the
	  signals back up.
	- Vertical design. Could we stack the fabric squares and have the
	  other parts outside it? Meaning some kind of a block construction
	  of the fabric, not built on scaffolding. There would be two
	  advantages here, we could drop signals a long way into a further
	  part of a circuit whereas in the plane setup the number of
	  parallel signals determines the width, which will become
	  prohibitive maybe after 8 or so? And the other would be that
	  the xy size would stay compact and you could just build up.
	  Additionally we could have lift screws (or belts) running up
	  the tower. 
        - Thinking about the simplest possible programmable computer...
	 - Memory cells. We could have a diverter on a vertical shaft,
	   in the read channel it's placed at one of the edges of the
	   channel just like the gate kickers. The write channel instead
	   moves it according to channel it's in.
	  - TODO this should be easily done with a literal flip-flop.
	    Shaft in the center, triggers before and after it, kickers
	    accordingly in the other channel.
	  - For ROM it would obviously be just manually set, or we could
	    omit the triggers and use a more compact design.
	 - Memory addressing? In our case it would be just a demultiplexer
	   to direct the read or write signal to the correct memory cell,
	   then we can simply combine the cell outputs into a single
	   output signal. However our gate implementation would be
	   absolutely massive because of the internal signal fanout.
           So there needs to be some non-gate solution to this.
	  - Large scale memory is divided into blocks, upper part of the
	    address selects the block, lower part selects the cell inside
	    the block, only lower part needs to be routed to every block.
	    Inside the block, a row and column setup can be used to
	    select a single cell.
	    https://www.geeksforgeeks.org/what-is-memory-decoding/
          - There needs to be some sort of non-gate demultiplexer
	    solution for addressing memory cells. Using gates would
	    require a shitton of hardware.
	   - Binary tree of switchable routes to the cells? Then send
	     the address to the switches, after that the data route
	     is ready. For this we just need a controllable switch.
	     For reading it doesn't need to preserve the signal, but
	     for writing it obviously needs to.
	   - If the binary tree grows larger, we can't control all the
	     switches at later levels, it would be too much friction
	     to overcome. Instead what we would need to do is route
	     both the data and the subsequent address bits to the
	     correct route. This way each address bit would need to
	     only control two switches, one for the data and one
	     for the remaining address bits. With this idea we would
	     need a pretty complex switch action with three states,
	     unset, set to 0 and set to 1. Each address bit arriving
	     at unset gate would set the route and next bits would
	     follow it. Then we would need the routed data bit to
	     unset the switches it passes so that the next address
	     can be set.
	   - The other mux/demux action we would need is sending
	     words bit by bit to the adder (this needs looping the
	     carry back) and then collecting them back to a
	     register.
	    - This would be a fun next project after the full
	      adder, build a program counter. After that memory
	      access to fetch instructions. And after that we
	      can start about thinking of an instruction set.
	   - Demux idea:
	    - We can probably fit a diverting signal path into a
	      space of a gate. If the path is clear, the signal
	      continues straight (set to 0). If there are
	      kickers/diverters down, it gets directed to the
	      other track (set to 1). The interesting part will
	      be implementing the unset state, where the arriving
	      signal needs to both choose a path and set the
	      switch.
	    - How do we distinguish the data signal? Since we know
	      the number of address bits, we could count them and
	      use just a single channel throughout. The other option
	      would be to implement a whole separate data path.
	      This would make the switch simpler and we'll probably
	      need that anyways to actually get the data to the
	      memory cell. And we can send the r/w bit last and
	      direct the data bit to either the read or write channel
	      of the memory cell.

