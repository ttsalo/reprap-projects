/* Harmonic Drive NG by Tomi T. Salo <ttsalo@iki.fi> 2018 */

/* New Generation Harmonic Drive. 

   Design principles: 
   - Two relatively closely spaced round flanges, which rotate relative to each other
   - Flanges connect to the inner and outer rims of a large diameter bearing, offering
     good stability.
   - The flexspline fits inside the bearing, making the whole assembly compact.
   - The flexspline flange's outside surface is smooth, allowing mounting to a solid surface, 
     if necessary, and all the drive parts can be disassembled from the circspline side while 
     both flanges and the main bearing remain attached to the main application.
*/

/* Prototype notes:
   6012 bearing, size 60x95x18

   Results/todo:
   21.3.2013: First fitting of 12-conn flex flange to bearing. Fit seems very good.
   Fitting of flexspline to flange: rifled connection seems very good, except that the
   bridge sag prevents it from seating completely. Add some space to the flexspline side
   void to help it seat correctly. Clearance with the bearing holders needs to be
   checked, seems very tight. AP: more height to rifled cylinder void, check that the spline
   slope is above the bearing holder.

   DONE: Added extra space to rifled cylinder void, took 1 mm out from flexspline slope
   and another from flex flange to bearing separation to make the slope clear the bearing
   connectors.
   
   DONE: Changed to smaller 6812 bearing.
   
   DONE: Reprint and check fit with 6812 bearing. The shorter braces are now too stiff
   for inserting the bearing. Reduced the upper hook, which should now allow bearing insertion.
   Implemented an adjustment parameter for the lockring to improve fit. 0.4 and 0.6 both make
   the bearing mount solid.
   
   DONE: Circspline and motor mount. These should be just one unit. 
   
   DONE: Adjust bearing assembly dimensions:
   - Reduce flex flange diameter, check bolt pattern. DONE
   - Increase circ flange inner diameter, need clearance vs. the flex flange, check bolt pattern. DONE
   - Increase circ flange outer diameter by 1mm, put that also to the supports. DONE
   - Change support extra tolerance to radial as well as vertical, just vertical spacing doesn't fix
     the fit issues. DONE
   - Allocate some of the extra diameter to the lock ring. DONE
   - Increase the rifled connector diameter and tooth size. DONE
   - Add a conical section to the circ flange to get rid of the need to use supports. DONE
   
   TODO: Full assembly and functional testing
     DONE: Bearing assembly (flanges, lockrings, bearing)
     DONE: Full assembly, worked fine except for the flexspline base fit. No powered testing but
             manually seems to work fine.
     TODO: Powered testing
   
   DONE: Single piece circspline side unit assembly including arm attachment truss.
      - But it doesn't work. The much stiffer bearing attachment is cannot reasonably be placed
        over the bearing and trying to insert the driver onto the flexspline at the same time is
        hard.

*/   

use <../includes/parametric_involute_gear_v5.0.scad>;
use <../PyramidSpaceTruss/PyramidSpaceTruss.scad>;

// Use some common configuration parameters from Armstrong-B when used as a component
include <../Armstrong-B/Armstrong-B-Configuration.scad>;

tol = 0.2;
lh = 0.3;

/* 6012 size bearing */
/* bearing_inner_r = 60/2;
bearing_outer_r = 95/2;
bearing_h = 18;
bearing_cone_l = 1.25; */ // Length of the bearing conical section 

/* 6812 size bearing */
bearing_inner_r = 60/2;
bearing_outer_r = 78/2;
bearing_h = 10;
bearing_cone_l = 1.25; // Length of the bearing conical section 

flange_r = 45;
flange_h = 2;

/* Flexspline side flange details. */
flex_flange_r = 36;
flex_flange_h = 3;
flex_flange_sep = 4; // Distance from bearing to flange
flex_inner_t = 2.5; // Outer side thickness of the bearing support
flex_below_hook = 2;
flex_above_hook = 1.1; // Was 2
flex_above_h = 3;
flex_base_t = 6;
flex_lockring_h = 2;
flex_lockring_t = 2;
flex_conn_w = 5;
flex_conn_n = drive_conn_n;
flex_mount_r = drive_mount_r;
flex_mount_n = drive_mount_n;
flex_bolt_r = drive_mount_bolt_r;

/* Circspline side flange details. */
circ_flange_r = bearing_outer_r+4;
circ_flange_cut_r = 32;
circ_flange_h = flange_h;
circ_flange_sep = 4; // Distance from bearing to flange
circ_outer_t = 4; // Outer side thickness of the bearing support
circ_below_hook = 3;
circ_above_hook = 1.2; // Was 2
circ_above_h = 3;
circ_base_t = 8;
circ_lockring_h = 2;
circ_lockring_t = 3;
circ_conn_w = 5;
circ_conn_n = 12;
circ_mount_r = 38;
circ_mount_n = 12;
circ_bolt_r = 2.5/2;
circ_bolt_head_r = circ_bolt_r*3;
circ_bearing_extra_tol = 0.2; // Extra tolerance for bearing outer edge

/* Flexspline details. */
flexspl_h = 36;
flexspl_tooth_h = 6;
flexspl_bottom_h = 2;
flexspl_slope_h = 5;
flexspl_inner_r = 25.3;
flexspl_outer_r = 27.3;
flexspl_bolt_r = 2;
flexspl_nut_r = 4;
flexspl_nut_h = 3;
flexspl_wall_t = 0.81;
flexspl_extra_wall_t = 0.4;
flexspl_lip = 1.4;
flexspl_rifling_extra_r=5;
flexspl_rifling_extra_h=1;

/* Driver details. */
drive_bearing_r = 13/2;
drive_bearing_h = 7;
wave_radius = 52.75/2;
driver_h = 12;
driver_w = 10;
drive_bearing_spacing_r = wave_radius - drive_bearing_r;

/* Circspline unit details */
circ_outer_r = 29;
circ_unit_wall_t = 3;
circ_unit_flange_h = flange_h;
circ_unit_offset = 0; // Offset from circ flange - space for mounting another flange in between.
circ_bottom_h = 3; // Bottom thickness for the motor mount part
stepper_shaft_l = 20;
// Unit height from motor mount to circ flange, derived from other parameters
circ_unit_h = stepper_shaft_l - driver_h/2 + flexspl_h - flex_flange_sep - bearing_h - circ_flange_sep - circ_flange_h;
// Attachment truss parameters
circ_truss_offset = 25;
circ_truss_w = 30;
circ_truss_h = 47;
circ_truss_l = 30;
circ_truss_supp_w = 40; // Width of the supporting structure in bearing mount
circ_truss_t = 4;

/* Rifling connects flexspline to the flange. Details below. */
flex_rifling_r = 12;
flex_rifling_w = 3;
flex_rifling_l = 3;
flex_rifling_n = 12;
flex_rifling_h = 2;
flex_rifling_tol = 0.2;

/* Circspline details. */
circspl_tooth_h = 6; // 10
circspl_total_h = 20;
circspl_outer_r = 32;
circspl_inner_r = 27;
circspl_bottom_h = 4;
circspl_clearance = -0.25;
circspl_backlash = -0.2;

/* Drive tooth profile main variables. */
press_angle = 35;
flex_teeth = 80;
teeth_diff = 2;
pitch = 120.5;

$fn=64;

echo(str("Inner clearance diameter: ", (bearing_inner_r-flex_inner_t)*2));

module roundedCylinder(r, h, rr_top=0, rr_bot=0, $fn) {
  difference() {
    union() {
      cylinder(r=r-rr_bot, h=abs(rr_bot), $fn=$fn);
      translate([0, 0, h-abs(rr_top)]) cylinder(r=r-rr_top, h=abs(rr_top), $fn=$fn);
      translate([0, 0, abs(rr_bot)]) cylinder(r=r, h=h-abs(rr_top)-abs(rr_bot), $fn=$fn);
      if (rr_bot > 0) {
        translate([0, 0, rr_bot])
          rotate_extrude(convexity=10, $fn=$fn)
            translate([r-rr_bot, 0, 0]) 
              circle(r=rr_bot, $fn=16);
      }
      if (rr_top > 0) {
        translate([0, 0, h-rr_top])
          rotate_extrude(convexity=10, $fn=$fn)
            translate([r-rr_top, 0, 0]) 
              circle(r=rr_top, $fn=16);
      }
    }
    if (rr_bot < 0) {
      translate([0, 0, -rr_bot])
        rotate_extrude(convexity=10, $fn=$fn)
          translate([r-rr_bot, 0, 0]) 
            circle(r=-rr_bot, $fn=16);
    }
    if (rr_top < 0) {
      translate([0, 0, h+rr_top])
        rotate_extrude(convexity=10, $fn=$fn)
          translate([r-rr_top, 0, 0]) 
            circle(r=-rr_top, $fn=16);
    }
  }
}

//roundedCylinder(r=10, h=10, rr_top=-3, rr_bot=-2, $fn=30);

module bearing() {
  color("blue")
  difference() {
    cylinder(r=bearing_outer_r, h=bearing_h);
    translate([0, 0, -1]) cylinder(r=bearing_inner_r, h=bearing_h+2);
    cylinder(r1=bearing_inner_r+bearing_cone_l, r2=bearing_inner_r, h=bearing_cone_l);
    translate([0, 0, bearing_h-bearing_cone_l])
      cylinder(r1=bearing_inner_r, r2=bearing_inner_r+bearing_cone_l, h=bearing_cone_l);
    difference() {
      cylinder(r=bearing_outer_r, h=bearing_cone_l);
      cylinder(r1=bearing_outer_r-bearing_cone_l, r2=bearing_outer_r, h=bearing_cone_l);
    }
    translate([0, 0, bearing_h-bearing_cone_l])
      difference() {
        cylinder(r=bearing_outer_r, h=bearing_cone_l);
        cylinder(r1=bearing_outer_r, r2=bearing_outer_r-bearing_cone_l, h=bearing_cone_l);
      }
  }
}

/* Flex and circ flange Z=0 is at the outer surface of the flange, with positive Z towards
   the flange. */

module flex_flange() {
  difference() {
    union() {
      cylinder(r=flex_flange_r, h=flex_flange_h);
      // Rifled mounting
      translate([0, 0, flex_flange_h])
        rifled_cylinder(r=flex_rifling_r, h=flex_rifling_h, 
                        r_l=flex_rifling_l,
                        r_w=flex_rifling_w, r_n=flex_rifling_n, $fn=30);
    }
    cylinder(r=flexspl_nut_r, h=flexspl_nut_h, $fn=6);
    translate([0, 0, flexspl_nut_h+lh])
      cylinder(r=flexspl_bolt_r, h=flex_flange_h+flex_rifling_h);
    for (i = [0 : 360/flex_mount_n : 360]) {
      rotate([0, 0, i+360/flex_mount_n/2]) 
        translate([flex_mount_r, 0, 0]) cylinder(r=flex_bolt_r, h=flex_flange_h);
    } 
  }
  for (i = [0 : 360/flex_conn_n : 360]) {
    intersection() {
    rotate([0, 0, i])
    translate([0, -flex_conn_w/2, -50])
      cube([bearing_outer_r, flex_conn_w, 100]);
  rotate_extrude(convexity=10)
    polygon([[bearing_inner_r-flex_inner_t, 0],
             [bearing_inner_r-flex_inner_t,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h-flex_lockring_h],
             [bearing_inner_r-flex_inner_t+flex_lockring_t,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h-flex_lockring_h],
             [bearing_inner_r-flex_inner_t+flex_lockring_t,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h],
             [bearing_inner_r+flex_above_hook,
              flex_flange_h+flex_flange_sep+bearing_h+flex_above_h],
             [bearing_inner_r+flex_above_hook,
              flex_flange_h+flex_flange_sep+bearing_h+tol],
             [bearing_inner_r+bearing_cone_l-tol*0.7,
              flex_flange_h+flex_flange_sep+bearing_h+tol],
             [bearing_inner_r-tol,
              flex_flange_h+flex_flange_sep+bearing_h-bearing_cone_l+tol*0.7],
             [bearing_inner_r-tol,
              flex_flange_h+flex_flange_sep+bearing_cone_l-tol*0.7],
             [bearing_inner_r+bearing_cone_l-tol*0.7,
              flex_flange_h+flex_flange_sep-tol],
             [bearing_inner_r+flex_below_hook,
              flex_flange_h+flex_flange_sep-tol],
             [bearing_inner_r+flex_base_t, flex_flange_h],
             [bearing_inner_r+flex_base_t, 0],
            ]);
   }
  }
}

module circ_flange(full_unit=false) {
  difference() {
    // Flange disk
    cylinder(r=circ_flange_r, h=circ_flange_h);
    // Flange disk cutout
    translate([0, 0, -0.5]) cylinder(r=circ_flange_cut_r, h=circ_flange_h+1);
    // Mounting holes for flange
    if (!full_unit)
      for (i = [0 : 360/circ_mount_n : 360]) {
        rotate([0, 0, i+360/circ_conn_n/2]) 
          translate([circ_mount_r, 0, 0]) cylinder(r=circ_bolt_r, h=circ_flange_h);
      }
  }
  // Output truss
  difference() {
    translate([circ_truss_offset, -circ_truss_w/2, 0]) {
       pyramid_box_truss(circ_truss_l, circ_truss_w, circ_truss_h-circ_unit_h, 1, 1, 2,
                           circ_truss_t, circ_truss_t, circ_truss_t, circ_truss_t, circ_truss_t, 
                           circ_truss_t, circ_truss_t, 16);
       translate([0, circ_truss_w, 0])
           rotate([0, 0, -90]) {
             box_bolt_pattern_side(circ_truss_w, circ_truss_l, circ_truss_h-circ_unit_h, 
                                    circ_truss_t, circ_truss_t, 4/2, 8/2, false, lower=false);
               box_bolt_pattern_lower(circ_truss_w, circ_truss_l, circ_truss_t, circ_truss_t, 
                                        3/2, 8/2);
          }
    }
    // Cutout for truss
    translate([0, 0, -0.5]) cylinder(r=circ_flange_r-1, h=circ_truss_h-circ_unit_h+1);
  }
  for (i = [0 : 360/circ_conn_n : 360]) {
    intersection() {
    rotate([0, 0, i])
    translate([0, -(i == 0 ? circ_truss_supp_w : circ_conn_w)/2, -50])
      cube([bearing_outer_r+50, (i == 0  ? circ_truss_supp_w : circ_conn_w), 100]);
   rotate_extrude(convexity=10)
    polygon([[bearing_outer_r+circ_outer_t-circ_base_t, circ_flange_h],
             [bearing_outer_r+circ_outer_t-circ_base_t, 0],
             [bearing_outer_r+circ_outer_t, 0],
             [bearing_outer_r+circ_outer_t,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h-circ_lockring_h],
             [bearing_outer_r+circ_outer_t-circ_lockring_t,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h-circ_lockring_h],
             [bearing_outer_r+circ_outer_t-circ_lockring_t,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h],
             [bearing_outer_r-circ_above_hook,
              circ_flange_h+circ_flange_sep+bearing_h+circ_above_h],
             [bearing_outer_r-circ_above_hook,
              circ_flange_h+circ_flange_sep+bearing_h+tol+circ_bearing_extra_tol],
             [bearing_outer_r-bearing_cone_l+tol*0.7,
              circ_flange_h+circ_flange_sep+bearing_h+tol+circ_bearing_extra_tol],
             [bearing_outer_r+tol+circ_bearing_extra_tol,
              circ_flange_h+circ_flange_sep+bearing_h-bearing_cone_l+tol*0.7+circ_bearing_extra_tol],
             [bearing_outer_r+tol+circ_bearing_extra_tol,
              circ_flange_h+circ_flange_sep+bearing_cone_l-tol*0.7-circ_bearing_extra_tol],
             [bearing_outer_r-bearing_cone_l+tol*0.7,
              circ_flange_h+circ_flange_sep-tol-circ_bearing_extra_tol],
             [bearing_outer_r-circ_below_hook,
              circ_flange_h+circ_flange_sep-tol-circ_bearing_extra_tol],
            ]);
    }
  }
}

module flex_lockring(adjust=0.0) {
  difference() {
    cylinder(r=bearing_inner_r-flex_inner_t+flex_lockring_t-tol+adjust,
             h=flex_lockring_h-tol);
    translate([0, 0, -.5]) cylinder(r=bearing_inner_r-flex_inner_t,
             h=flex_lockring_h-tol+1);
  }
}

module circ_lockring() {
  difference() {
    cylinder(r=bearing_outer_r+circ_outer_t,
             h=circ_lockring_h-tol);
    translate([0, 0, -.5]) cylinder(r=bearing_outer_r+circ_outer_t-circ_lockring_t+tol,
             h=circ_lockring_h-tol+1);
  }
}

module spline_gear(teeth, height, backlash, clearance) {
  gear(number_of_teeth=teeth,
       circular_pitch=pitch,
       pressure_angle=press_angle,
       clearance = clearance,
       gear_thickness = height,
       rim_thickness = height,
       rim_width = 5,
       hub_thickness = height,
       hub_diameter=0,
       bore_diameter=0,
       circles=0,
       backlash=backlash,
       twist=0
       );
}


module rifled_cylinder(r, h, r_l, r_w, r_n, $fn) {
  cylinder(r=r, h=h, $fn=$fn);
  for (i = [0 : 360/r_n : 360]) {
    rotate([0, 0, i]) translate([0, -r_w/2, 0]) cube([r+r_l, r_w, h]);
  }
}

module flexspline(omit_gear=false) {
  difference() {
    intersection() {
      // Non-zero backlash results in a non-manifold object
      if (!omit_gear) spline_gear(flex_teeth, flexspl_h, 0.0, 0.0);
      union() {
        // The flexspline is made lighter by intersecting the main
        // gear shape with the union of the following shapes.
        
        // The flat area, thickness from the wall thickness parameter.
        roundedCylinder(r=flexspl_inner_r+flexspl_wall_t, h=flexspl_h, rr_bot=1, $fn=60);
        
        // Slope from the flat area to the top teeth.
        translate([0, 0, flexspl_h-flexspl_tooth_h-flexspl_slope_h])
          cylinder(r1=flexspl_inner_r+flexspl_wall_t, r2=flexspl_outer_r, 
                   h=flexspl_slope_h, $fn=60);
        
        // Top tooth area
        translate([0, 0, flexspl_h-flexspl_tooth_h])
          cylinder(r=flexspl_outer_r, h=flexspl_tooth_h+1, $fn=60);
      }
    }
    /* The inner hollow is made by subtracting the following from the lightened gear shape */
    difference() {
      union () {
        // Main internal void
        difference() {
          translate([0, 0, flexspl_bottom_h])
            roundedCylinder(r=flexspl_inner_r, 
                     h=flexspl_h - flexspl_bottom_h - flexspl_tooth_h, rr_bot=1, $fn=60);
          translate([0, 0, flexspl_bottom_h])
            roundedCylinder(r=flexspl_rifling_extra_r+flex_rifling_r, 
                            h=flex_rifling_h+flexspl_rifling_extra_h, 
                            rr_bot=-1, rr_top=1, $fn=60);
        }
        translate([0, 0, flexspl_h-flexspl_tooth_h])
          cylinder(r=flexspl_inner_r-flexspl_extra_wall_t, 
                   h=flexspl_tooth_h, $fn=60);
      }
      // Driver retaining lip is made be subtracting it from the main void.
      difference() {
        translate([0, 0, flexspl_h-flexspl_tooth_h-flexspl_lip])
          cylinder(r=flexspl_inner_r, h=flexspl_lip, $fn=60);
        translate([0, 0, flexspl_h-flexspl_tooth_h-flexspl_lip])
           cylinder(r1=flexspl_inner_r, r2=flexspl_inner_r-flexspl_lip, 
                    h=flexspl_lip, $fn=60);
      }
    }
    
    // Rifled mounting void
    rifled_cylinder(r=flex_rifling_r+flex_rifling_tol, h=flex_rifling_h+flexspl_rifling_extra_h, 
                    r_l=flex_rifling_l+flex_rifling_tol,
                    r_w=flex_rifling_w, r_n=flex_rifling_n, $fn=30);
    // Central bolt hole with printing support
    translate([0, 0, flexspl_bottom_h+flexspl_rifling_extra_h+lh])
      cylinder(r=flexspl_bolt_r, h=flexspl_bottom_h);
  }
}

module circspline(omit_gear=false) {
  difference() {
    union() {
      cylinder(r=circspl_outer_r, h=circspl_total_h, $fn=60);
    }
    cylinder(r1=circspl_outer_r, r2=circspl_inner_r, h=(circspl_total_h - circspl_tooth_h)/2, $fn=60);
    if (!omit_gear)
      spline_gear(flex_teeth + teeth_diff, circspl_total_h, circspl_backlash, circspl_clearance);
    translate([0, 0, circspl_total_h - (circspl_total_h - circspl_tooth_h)/2])
      cylinder(r1=circspl_inner_r, h=(circspl_total_h - circspl_tooth_h)/2, r2=circspl_outer_r, $fn=60); 
  }
}

// Circspline that mounts to the carriage.
module circspline_unit(circ_unit_offset=0, omit_gear=false, full_unit=false) {
  color("teal")
  difference() {
    union() {
      translate([0, 0, -(circspl_total_h - circspl_tooth_h)/2])
      circspline(omit_gear=omit_gear);
      // Motor mounting plate
      translate([0, 0, -stepper_shaft_l+driver_h/2])
        cylinder(r=circ_outer_r, h=circ_bottom_h, $fn=60);
      // Main unit frame
      translate([0, 0, -stepper_shaft_l+driver_h/2])
        difference() {
          union() {
            // Primary cylinder frame
            cylinder(r=circ_outer_r+circ_unit_wall_t, h=circ_unit_h-circ_unit_offset, $fn=60);
            // Output truss
            translate([circ_truss_offset, -circ_truss_w/2, 0]) {
              pyramid_box_truss(circ_truss_l, circ_truss_w, circ_unit_h, 1, 1, 2,
                                  circ_truss_t, circ_truss_t, circ_truss_t, circ_truss_t, circ_truss_t, 
                                  circ_truss_t, circ_truss_t, 16);
            translate([0, circ_truss_w, 0])
              rotate([0, 0, -90]) {
                box_bolt_pattern_side(circ_truss_w, circ_truss_l, circ_unit_h, circ_truss_t, circ_truss_t,
                                       4/2, 8/2, false, upper=false);
                box_bolt_pattern_upper(circ_truss_w, circ_truss_l, circ_unit_h, circ_truss_t, circ_truss_t, 
                                         3/2, 6/2, 8/2, lh, bolt_fn=16);
              }
            }
         translate([0, 0, circ_unit_h-circ_unit_flange_h-circ_unit_offset])
          // Flange
          intersection() {
            union() {
              cylinder(r=circ_flange_r, h=circ_unit_flange_h);
              translate([0, 0, -circ_flange_r])
              cylinder(r1=0, r2=circ_flange_r, h=circ_flange_r);
             }
            // Optimization for the individual unit size, can optionally cut in Y
            translate([-circ_flange_r, (-circ_outer_r-circ_unit_wall_t), -circ_flange_r/2])
              cube([circ_flange_r*2, (circ_outer_r+circ_unit_wall_t)*2, circ_flange_r]);
           } 
          }
          // Main inner cylinder cutout
          cylinder(r=circ_outer_r, h=circ_unit_h-circ_unit_offset+1, $fn=60);
          // Flange mounting holes
          if (!full_unit) {
            translate([0, 0, circ_unit_h-circ_flange_h])
            for (i = [0 : 360/circ_mount_n : 360]) {
              rotate([0, 0, i+360/circ_conn_n/2]) {
                translate([circ_mount_r, 0, 0]) cylinder(r=circ_bolt_r, h=circ_unit_flange_h+1);
                translate([circ_mount_r, 0, -circ_flange_r/2-lh]) cylinder(r=circ_bolt_head_r, 
                                                                          h=circ_flange_r/2);
           }
          }
         }
        }          
      }
    translate([0, 0, -stepper_shaft_l+driver_h/2])
    {        
       // NEMA17 screw holes
       for (i = [45 : 90 : 315]) {
        rotate(i, [0, 0, 1])
        translate([0, 21.8, 0])
        union() {
          cylinder(r = 1.5, h = circ_bottom_h, $fn=8);
          translate([0, 0, circ_bottom_h - 1.5])
            cylinder(r1 = 1.5, r2 = 3, h = 1.5, $fn=16);
        }
      }
      // Lightening the construction. Also peepholes.
      for (i = [0 : 90 : 360]) {
        rotate(i, [0, 0, 1])
        translate([0, 21, 0])
        cylinder(r = 7, h = circ_bottom_h, $fn=24);
      }
      cylinder(r = 12, h = circ_bottom_h); // NEMA17 central hole
    }
  }
}

module circspline_full_void() {
    translate([0, 0, -circ_unit_flange_h])
      cylinder(r=circ_flange_r, h=circ_unit_flange_h + circ_flange_h + circ_flange_sep + bearing_h + flex_flange_sep);
    translate([0, 0, -circ_unit_h])
      cylinder(r=circ_outer_r, h=circ_unit_h);
}

// Full unit combining the bearing attachment and the circspline unit
module circspline_full() {
    circ_flange(full_unit=true);
    translate([0, 0, -(circ_unit_h-stepper_shaft_l+driver_h/2-circ_unit_flange_h-circ_unit_offset-
                      -circ_unit_flange_h)])
      circspline_unit(circ_unit_offset=0, full_unit=true);
    difference() {
      translate([circ_truss_offset, -circ_truss_w/2, -circ_unit_h]) {
        pyramid_box_truss(circ_truss_l, circ_truss_w, circ_truss_h, 1, 1, 2,
                           3, 3, 3, 3, 3, 3, 3, 16);
        translate([0, circ_truss_w, 0])
          rotate([0, 0, -90])
            box_bolt_pattern_side(circ_truss_w, circ_truss_l, circ_truss_h, 3, 3,
                                    4/2, 8/2, false);
              
      }
      circspline_full_void();
    }
}

// Assembly Z=0 is at the lower surface of the bearing
module drive_assembly() {
  translate([0, 0, flex_flange_sep+flex_flange_h])
difference() {
  union() {
    bearing();
    translate([0, 0, -flex_flange_h-flex_flange_sep])
      #flex_flange();
    //translate([0, 0, bearing_h+circ_flange_sep+circ_flange_h])
    //  mirror([0, 0, -1]) circspline_full();
    translate([0, 0, bearing_h+circ_flange_sep+circ_flange_h])
      mirror([0, 0, -1]) circ_flange();
    translate([0, 0, flexspl_h-flex_flange_sep])
      mirror([0, 0, -1]) circspline_unit(circ_unit_offset=circ_unit_offset, omit_gear=true);
    translate([0, 0, -circ_above_h]) circ_lockring();
    translate([0, 0, bearing_h+flex_above_h-flex_lockring_h+tol]) flex_lockring();
    translate([0, 0, -flex_flange_sep]) flexspline(omit_gear=true);
  }
  translate([0, 0, -50]) cube([100, 100, 100]);
}
}

drive_assembly();

//circspline_full();
//circspline();
//circspline_unit(circ_unit_offset=0);
//circ_flange();
//circ_lockring();
//flex_flange();
//flex_lockring(adjust=0.4);
//flexspline();