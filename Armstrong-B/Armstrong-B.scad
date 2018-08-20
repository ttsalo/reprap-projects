/* Armstrong-B by Tomi T. Salo <ttsalo@iki.fi> 2018 */

/* Model B of the Armstrong parallel SCARA printer
   
   Design goals:
   - Very highly printable
   - Reach a level of movement precision that is enough to be a useful printer
   
   Main problems in the original Armstrong-A design:
   - Arm movement was simply not stable enough:
    - Extending the arms farther would cause them to sag
     - Cause for this was the flexibility in the bearing setup combined with the arm
       geometry (fairly flat in the X-Y plane).
    - Rotating wave driver would cause other kinds of movement in the arms than the
      intended rotation.
     - Cause for this was the flexibility in the bearing setup. Even a small amount of flex
       in the arm base produces a lot of movement in the effector end.
   
   Main improvements in the new design:
   - Much larger main arm bearings, which should properly constrain the arm movement to
     the intended rotation.
   - Arm sections, as well as attachments, are higher in the Z dimension to resist sagging.
   
*/

// Configuration
// Assembly origin is at the midpoint of the tower

// Arm lengths.
arm_1 = 100;
arm_2 = 100;
arm_1_w = 20; // Main width of arm 1 sctructure
arm_1_h = 40; // Main height of arm 1 sctructure

// Arm origin is at the midpoint of the tower
module inner_arm() {
    
    
    
}

module assembly() {
    inner_arm();
    rotate([180, 0, 0]) inner_arm();    
}

assembly();
//inner_arm();