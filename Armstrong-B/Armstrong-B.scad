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
   
   Project Plan:
   1. Develop the harmonic drive ready for use in Armstrong-B
     - Almost done
   2. Develop the mounting tower for the drives
   3. Prototype with the arm designs to figure out what is needed for sufficient rigidity
   4. Figure out the effector mount
   4.1 Optionally a pen holder
   5. Figure out homing switches
   6. Develop the bed Z mechanism
   7. Functional testing
   
*/

use <../HarmonicDrive/HarmonicDrive.scad>;
use <../PyramidSpaceTruss/PyramidSpaceTruss.scad>;
include <Armstrong-B-Configuration.scad>;

// Configuration

// Bunch of parameters are inherited from the HarmonicDrive project which is an
// integral part of this one.

// Assembly origin is at the midpoint of the tower

// Arm lengths.
arm_1 = 120;
arm_2 = 120;
arm_1_w = drive_truss_w; // Main width of arm 1 sctructure
arm_1_h = drive_truss_h; // Main height of arm 1 sctructure
arm_1_l = arm_1 - drive_truss_x_offset - drive_truss_l;

// Tower parameters
tower_platform_r = 40; // Mounting platform radius
tower_platform_inner_r = 25; // Mounting platform radius
tower_platform_t = 4; // Mounting platform thickness
tower_h = 50;

module tower() {
    translate([0, 0, -tower_platform_t/2])
      difference() {
        cylinder(r=tower_platform_r, h=tower_platform_t, $fn=64);
        translate([0, 0, -0.5]) {
          cylinder(r=tower_platform_inner_r, h=tower_platform_t+1, $fn=64);
          for (i = [0 : 360/drive_mount_n : 360]) {
            rotate([0, 0, i+360/drive_conn_n/2]) 
              translate([drive_mount_r, 0, 0]) 
                cylinder(r=drive_mount_bolt_r, h=tower_platform_t+1, $fn=16);
          } 
        }
      }
}

// Arm origin is at the midpoint of the tower
module inner_arm() {
  translate([drive_truss_x_offset+drive_truss_l, -drive_truss_w/2, 
            tower_platform_t/2 + drive_truss_z_offset])
    pyramid_box_truss(arm_1_l, drive_truss_w, drive_truss_h, 2, 1, 2,
                        drive_truss_t, drive_truss_t, drive_truss_t, drive_truss_t, drive_truss_t, 
                        drive_truss_t, drive_truss_t, 16);
}

module assembly() {
    tower();
    translate([0, 0, tower_platform_t/2])
      drive_assembly();
    mirror([0, 0, -1])
      translate([0, 0, tower_platform_t/2])
        drive_assembly();
    inner_arm();
    rotate([180, 0, 0]) inner_arm();
}

assembly();
//inner_arm();
