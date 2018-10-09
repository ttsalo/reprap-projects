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
     - Design pretty much done, testing missing
   2. Develop the mounting tower for the drives
     - Basic tower done
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

t = 0.2;
lh = 0.3;

// Arm bearing parameters
bearing_R = 22/2;
bearing_r = 8/2;
bearing_h = 7;
bearing_tol = 0.2;
bearing_holder_r = 13/2;
bearing_holder_t = 3;
bearing_holder_extra_z = 20;
washer_t = 1.5;

// Bearing holder parameters for second section of upper arm
bearing_holder_lower_flat_t = 4; // Thickness of the flat part of bearing holder
bearing_holder_lower_flat_r = drive_truss_w/2;
bearing_holder_upper_flat_t = 6;
bearing_holder_upper_flat_r = 10;
bearing_holder_upper_brace_w = 9;
bearing_holder_upper_brace_l = 28;
bearing_holder_far_R = 20;
bearing_holder_far_r = 10;
bearing_holder_far_t = 4;

// Arm lengths.
arm_1 = 120; // Totals between the rotation axes
arm_2 = 120;
arm_1_w = drive_truss_w; // Main width of arm 1 sctructure
arm_1_h = drive_truss_h; // Main height of arm 1 sctructure
arm_1_l = arm_1 - drive_truss_x_offset - drive_truss_l;

// Second section of upper arm (1)
arm_2_1_w = drive_truss_w;
arm_2_1_h = arm_1_h + 2*washer_t + bearing_holder_lower_flat_t + bearing_holder_upper_flat_t + 6; // Uses a fudge factor
arm_2_1_z_offset = -washer_t-bearing_holder_lower_flat_t; // Offset relative to first section
arm_2_1_truss_x_offset = 14; // Where the truss starts
arm_2_1_truss_l = 95; // Truss part length
arm_2_1_truss_t = 4;
arm_2_1_truss_2_t = 3;

// Tower parameters
tower_platform_r = 40; // Mounting platform radius
tower_platform_inner_r = 25; // Mounting platform radius
tower_platform_t = 4; // Mounting platform thickness
tower_h = 100;

tower_truss_l = 40;
tower_truss_w = 30;
tower_truss_t = 3;
tower_truss_offset = 48;

// Arm bearing Z placement relative to assembly origin, arm joints top down
// Position of bearing open edge
arm_1_1_bearing_1_z = drive_truss_z_offset + tower_platform_t/2 + drive_truss_h;
arm_1_1_bearing_2_z = drive_truss_z_offset + tower_platform_t/2;

echo(str("Drive truss h: ", (arm_2_1_h)));

// Bearing holder, open upwards, bearing upper edge at Z=0
module bearing_holder(void=false) {
  if (!void) {
    translate([0, 0, -bearing_h-bearing_holder_t-bearing_holder_extra_z])
      difference() {
        cylinder(r=bearing_R+bearing_holder_t, 
                 h=bearing_h+bearing_holder_t+bearing_holder_extra_z, $fn=32);
      }
  } else {
    translate([0, 0, -bearing_h])
      cylinder(r=bearing_R + bearing_tol, h=bearing_h+1, $fn=32);
    // Platforms for the bearing to rest on with square cutout
    intersection() {
      translate([-bearing_holder_r, -bearing_R-bearing_tol, -bearing_h-bearing_holder_t-1])
        cube([bearing_holder_r*2, bearing_R*2+bearing_tol*2, bearing_h+bearing_holder_t]);
      translate([0, 0, -bearing_h-bearing_holder_t-1])
        cylinder(r=bearing_R+bearing_tol, h=bearing_h+bearing_holder_t, $fn=32);
    }
    translate([0, 0, -bearing_h-bearing_holder_t-bearing_holder_extra_z])
      cylinder(r=bearing_R+bearing_tol, 
               h=bearing_holder_extra_z, $fn=32);
  }    
}

module tower() {
    translate([0, 0, -tower_platform_t/2])
      difference() {
        union() {
          cylinder(r=tower_platform_r, h=tower_platform_t, $fn=64);
          for (i = [0, 90, 180])
            rotate([0, 0, i]) {
              translate([0, tower_truss_offset, -tower_h]) {
                pyramid_box_truss(tower_truss_l, tower_truss_w, tower_h, 2, 1, 6,
                                    tower_truss_t, tower_truss_t, tower_truss_t, tower_truss_t, tower_truss_t, 
                                    tower_truss_t, tower_truss_t, 16);
                translate([0, 0, tower_h])
                  mirror([0, 0, -1])
                  box_bolt_pattern_upper(tower_truss_l, tower_truss_w, tower_h, tower_truss_t,
                                           tower_truss_t, 4/2, 8/2, 12/2, lh, bolt_fn=16);
              }
              translate([0, 0, 0])
                cube([tower_truss_l, tower_truss_offset + tower_truss_w, tower_platform_t]);
            }
        }
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
module inner_arm(arm_n=1) {
  difference() {
    union() {
      translate([drive_truss_x_offset+drive_truss_l, -drive_truss_w/2, 
                tower_platform_t/2 + drive_truss_z_offset]) {
          pyramid_box_truss(arm_1_l, drive_truss_w, drive_truss_h, 2, 1, 2,
                              drive_truss_t, drive_truss_t, drive_truss_t, drive_truss_t, drive_truss_t, 
                              drive_truss_t, drive_truss_t, 16);
          translate([-arm_1_l+drive_truss_t, drive_truss_w, 0])
            rotate([0, 0, -90])
              box_bolt_pattern_side(drive_truss_w, arm_1_l, drive_truss_h, drive_truss_t, drive_truss_t,
                                     4/2, 8/2, false);
       }
       if (arm_n == 1) {
         translate([arm_1, 0, arm_1_1_bearing_1_z])
           bearing_holder();
         translate([arm_1, 0, arm_1_1_bearing_2_z])
           mirror([0, 0, -1])
             bearing_holder();
       }
   }
   if (arm_n == 1) {
     translate([arm_1, 0, arm_1_1_bearing_1_z])
       bearing_holder(void=true);
     translate([arm_1, 0, arm_1_1_bearing_2_z])
       mirror([0, 0, -1])
         bearing_holder(void=true);   
    }
  }
}

module upper_outer_arm() {
    translate([arm_1, 0, tower_platform_t/2 + drive_truss_z_offset + arm_2_1_z_offset]) {
      difference() {
        union() {
          cylinder(r=bearing_holder_lower_flat_r, h=bearing_holder_lower_flat_t, $fn=24);
          translate([0, -bearing_holder_lower_flat_r, 0])
            cube([arm_2_1_truss_x_offset, bearing_holder_lower_flat_r*2, bearing_holder_lower_flat_t]);
          translate([0, 0, bearing_holder_lower_flat_t + washer_t*2 + drive_truss_h])
            cylinder(r=bearing_holder_upper_flat_r, h=bearing_holder_upper_flat_t, $fn=24);
          translate([0, -bearing_holder_upper_brace_w/2, 
                    bearing_holder_lower_flat_t + washer_t*2 + drive_truss_h])
            cube([bearing_holder_upper_brace_l, bearing_holder_upper_brace_w, bearing_holder_upper_flat_t]);
          translate([arm_2_1_truss_x_offset, 0, 0])
            triangular_truss(arm_2_1_truss_l, 5, arm_2_1_w, arm_2_1_h, arm_2_1_w, 5,
            arm_2_1_truss_t, arm_2_1_truss_t, arm_2_1_truss_t, arm_2_1_truss_t,
            arm_2_1_truss_2_t, arm_2_1_truss_2_t, arm_2_1_truss_2_t, arm_2_1_truss_2_t,
            16, use_truss=true);
            translate([arm_2, 0, 0])
              cylinder(r=bearing_holder_far_R, h=bearing_holder_far_t, $fn=24);
        }
        cylinder(r=bearing_r, h=bearing_holder_lower_flat_t, $fn=24);
        translate([0, 0, bearing_holder_lower_flat_t + washer_t*2 + drive_truss_h])
            cylinder(r=bearing_r, h=bearing_holder_upper_flat_t, $fn=24);
        translate([0, 0, bearing_holder_lower_flat_t])
            cylinder(r=bearing_R+bearing_holder_t+bearing_tol*3, h=drive_truss_h+washer_t*2, $fn=32);
        translate([arm_2, 0, 0])
            cylinder(r=bearing_holder_far_r, h=bearing_holder_far_t, $fn=24);
    }
    // Printing support for upper holder
    cylinder(r=bearing_r-t, h=lh);
    cylinder(r=bearing_r-1, h=40);
    translate([0, 0, bearing_holder_lower_flat_t + washer_t*2 + drive_truss_h - 15.4])
      cylinder(r1=bearing_r-1, r2=bearing_holder_upper_flat_r, h=15);
  }  
}

module assembly() {
    tower();
    translate([0, 0, tower_platform_t/2])
      drive_assembly();
    mirror([0, 0, -1])
      translate([0, 0, tower_platform_t/2])
        drive_assembly();
    inner_arm(arm_n=1);
    rotate([180, 0, 0]) inner_arm(arm_n=2);
    upper_outer_arm();
}

//assembly();

//tower();
//inner_arm();
upper_outer_arm();
