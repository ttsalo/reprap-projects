/* Rigid chain screw actuator by Tomi T. Salo <ttsalo@iki.fi> */

/* Screw-driven rigid chain actuator (see https://en.wikipedia.org/wiki/Rigid_chain_actuator)
   with Tsubaki-style zipper action. 
   
   A lifter column which can be mounted between a solid surface and a solid load
   and does not need to extend vertically below the surface or above the load in any
   position. A zipper mechanism prevents buckling sideways when lifting the load. */

use <../includes/Thread_Library.scad>;
use <../includes/parametric_involute_gear_v5.0.scad>;

// Chain parameters
pitch = 20; // Link-to-link pitch
width = 18; // Width of links
wall_t = 0.5;  // Wall thickness (before adding threads)
bar_d = 4;  // Bar diameter
lat_pitch = 20;  // Bar-to-bar distance for opposing sides of chain
depth = 30;   // Total clearance along the bar-to-bar distance
l_tol = 0.2;  // Lengthwise (pitch-wise) tolerance
tol = 0.2;  // Chain segment fit tolerance
snap_tol = 0.4;  // Connector snap element tolerance
conn_t = 2;  // Connector snap element thickness
bar_offset = (depth - lat_pitch) / 2;  // Offset of the chain connecting bar from the outer edge
center_t = depth - (bar_offset * 4);  // Thickness of the center part between pivoting bar round parts
minor_r = center_t/4; // Hook parts roundness
conn_width = width - wall_t*2 - snap_tol*2; // Connector width
guide_width = width - wall_t*2 - snap_tol*4; // Guide has double tolerance

// Screw parameters
screw_d = 40;   // Screw diameter
screw_p = pitch/8;  // Screw pitch
screw_fn = 60;  // Screw sections

module screw(screw_tl) {
  trapezoidThread(length=screw_tl,
                  pitch=screw_p,
                  pitchRadius=screw_d/2-screw_p/2,	
                  threadHeightToPitch=0.5,
                  profileRatio=0.5,
                  threadAngle=29,			
                  RH=true,				
                  clearance=0.15,
                  backlash=0.1,
                  stepsPerTurn=screw_fn);
}

module screw_void(screw_tl) {
  trapezoidThreadNegativeSpace(length=screw_tl,
                               pitch=screw_p,
                               pitchRadius=screw_d/2-screw_p/2,	
                               threadHeightToPitch=0.5,
                               profileRatio=0.5,
                               threadAngle=29,
                               RH=true,	
                               clearance=0.15,
                               backlash=0.1,
                               stepsPerTurn=screw_fn);
}

/* Flat bar with rounded ends, freely positioned in the Y plane */
module rounded_bar(start_x, start_z, end_x, end_z, r, t) {
  translate([start_x, 0, start_z])
    rotate([-90, 0, 0]) cylinder(r=r, h=t, $fn=32);
  translate([end_x, 0, end_z])
    rotate([-90, 0, 0]) cylinder(r=r, h=t, $fn=32);
  translate([start_x, 0, start_z])
    rotate([0, atan2(start_z - end_z, end_x - start_x), 0])
      translate([0, 0, -r])
        cube([sqrt(pow(end_x - start_x, 2) + pow(start_z - end_z, 2)), 
              t, r*2]);
}

/* Main chain segment shape. Stacks and hooks together with adjacent segments. */
module shape(t) {
  difference() {
    intersection() {
      cube([depth, width, pitch-l_tol]);
      union() {
        // Bar-to-bar main part
        translate([0, 0, bar_offset])
          cube([bar_offset*2, t, (pitch - bar_offset*2)]);
        // Main part round ends
        translate([bar_offset, 0, pitch * .25])
          rotate([-90, 0, 0])
            cylinder(r=pitch/4, h=t, $fn=32);
        translate([bar_offset, 0, pitch * .75])
          rotate([-90, 0, 0])
            cylinder(r=pitch/4, h=t, $fn=32);
        // Hook tip
        translate([bar_offset*2 + center_t * .75, 0, pitch/4])
          rotate([-90, 0, 0])
            cylinder(r=center_t/4-tol, h=t, $fn=32);
        // Hook main shape
        rounded_bar(bar_offset, pitch-minor_r,
                    depth/2 - pitch/4 - minor_r*sin(22.5), 
                    pitch-minor_r, minor_r-tol, t);
        second_bar_l = ((depth - bar_offset*2 - minor_r) - 
                        (depth/2 - pitch/4- minor_r*sin(22.5))) * sqrt(2);
        rounded_bar(depth/2 - pitch/4- minor_r*sin(22.5), pitch-minor_r, 
                    depth/2 - pitch/4- minor_r*sin(22.5) + second_bar_l/sqrt(2), 
                    (pitch-minor_r) - second_bar_l/sqrt(2),
                    minor_r-tol, t);
        rounded_bar(depth/2 - pitch/4- minor_r*sin(22.5) + second_bar_l/sqrt(2), 
                    (pitch-minor_r) - second_bar_l/sqrt(2),
                    bar_offset*2 + center_t * .75, pitch/4,
                    minor_r-tol, t);
        // Hook fill-in
        translate([pitch/4, 0, pitch/4]) 
          cube([pitch/4 + center_t*.75, t, pitch/4]);
        // Hook fill-in 2
        translate([pitch/4, 0, pitch/2-1]) 
          cube([pitch/4 + center_t*.5, t, pitch/4]);
      }
    }
    // Opposite hook tip void
    translate([bar_offset*2 + center_t * .25, -1, pitch/4])
      rotate([-90, 0, 0])
        cylinder(r=center_t/4, h=t+2, $fn=32);
  }
}

/* Basic chain link. */
module chain_link() {
  translate([-depth/2, -width/2, 0]) {
    shape(wall_t);
    translate([0, width - wall_t, 0])
      shape(wall_t);
    translate([bar_offset, 0, pitch * .25])
      rotate([-90, 0, 0])
        cylinder(r=bar_d/2, h=width, $fn=32);
    translate([bar_offset, 0, pitch * .75])
      rotate([-90, 0, 0])
        cylinder(r=bar_d/2, h=width, $fn=32);
  }
  intersection() {
    union () {
      translate([-depth/2, width/2-0.1, 0]) shape(width);
      translate([-depth/2, -width*1.5+0.1, 0]) shape(width);
    }
    rotate([0, 0, 45])
      translate([0, 0, -screw_p*2])
      screw(pitch + screw_p*4);
  }
}

/* Partially open ring that snaps around a cylindrical shaft. */
module snap_in(inner_r, outer_r, opening, h) {
  rotate([90, 0, 180]) rotate([0, 0, -opening/2]) {
    difference() {
      cylinder(r=outer_r, h=h, $fn=32);
      cylinder(r=inner_r, h=h, $fn=32);
      cube([outer_r, outer_r, h]);
      rotate([0, 0, opening-90]) cube([outer_r, outer_r, h]);
    }
    _r = (outer_r-inner_r)/2;
    translate([inner_r+_r, 0, 0])
      cylinder(r=_r, h=h, $fn=16);
    rotate([0, 0, opening])
      translate([inner_r+_r, 0, 0])
        cylinder(r=_r, h=h, $fn=16);
  }   
}

/* A connector element between two links. */
module connector() {
  translate([-depth/2+bar_offset, -conn_width/2, pitch/4])
    snap_in(bar_d/2+snap_tol, bar_d/2+snap_tol+conn_t, 120, conn_width);
  translate([-depth/2+bar_offset, -conn_width/2, pitch/4*3])
    snap_in(bar_d/2+snap_tol, bar_d/2+snap_tol+conn_t, 120, conn_width);
  translate([-depth/2+bar_offset+bar_d/2+snap_tol, -conn_width/2, pitch/4-bar_d/2])
    cube([conn_t*2, conn_width, pitch/2 + bar_d]);
}

/* Chain mock-up */
module chain() {
  chain_link();
  translate([0, 0, pitch]) chain_link();
  translate([0, 0, pitch * 1.5]) rotate([0, 180, 0]) chain_link();
  translate([0, 0, pitch * 2.5]) rotate([0, 180, 0]) chain_link();
}

/* Terminating piece for the chain. */
module top() {
  difference() {
    union() {
      chain_link();
      translate([0, 0, pitch * 1.5]) rotate([0, 180, 0]) chain_link();
      translate([0, 0, pitch]) cylinder(r=screw_d/2+4, h=4);
      difference() {
        translate([0, 0, pitch * .75]) cylinder(r=screw_d/2+4, h=pitch*.25+1);
        translate([0, -screw_d/2-5, 0]) cube(screw_d+10);
      }
    }
    translate([0, 0, pitch-1+4]) cylinder(r=screw_d/2+4, h=pitch);
  }
}

// Static base parameters.
base_inner_d = screw_d;
base_wt = 4;
base_h = 10;
guide_offset = depth/2 - bar_offset + bar_d/2 + 1.5;
joiner_r = 20;
guide_t = 4;
guide_curved_space = 12;
support_w = 16;
support_t = 4;
crank_holder_w = 16;
crank_holder_t = 5;

/* The static base part. Implements the joiner, guides and the holder for
   the driver nut. */
module base() {
  difference() {
    translate([0, 0, base_h-driver_seat_wt])
      cylinder(r=screw_d/2+driver_seat_wt+base_wt, h=driver_seat_wt+driver_seat_h, $fn=60);
    cylinder(r=base_inner_d/2, h=base_h+driver_seat_h, $fn=60);        
    translate([0, 0, base_h])
      cylinder(r=screw_d/2+driver_seat_wt+tol, h=base_h+driver_seat_h, $fn=60);
  }
  translate([guide_offset, -guide_width/2, 0])
    cube([base_inner_d/2 - guide_offset, guide_width, base_h]);
  translate([-base_inner_d/2, -guide_width/2, 0])
    cube([base_inner_d/2 - guide_offset, guide_width, base_h]);
  translate([-joiner_r-guide_offset, 0, 0])
    quad_xz_cyl_shell(joiner_r-guide_t, joiner_r, guide_width, 60);
  mirror([1, 0, 0])
    translate([-joiner_r-guide_offset, 0, 0])
      quad_xz_cyl_shell(joiner_r-guide_t, joiner_r, guide_width, 60);
  difference() {
    union() {
      translate([-joiner_r-guide_offset, 0, 0])
        quad_xz_cyl_shell(joiner_r+guide_curved_space, joiner_r+guide_curved_space+guide_t, guide_width, 60);
      mirror([1, 0, 0])
        translate([-joiner_r-guide_offset, 0, 0])
        quad_xz_cyl_shell(joiner_r+guide_curved_space, joiner_r+guide_curved_space+guide_t, guide_width, 60);
      translate([-joiner_r-guide_offset, -guide_width/2, -joiner_r-guide_curved_space-guide_t])
        cube([(joiner_r+guide_offset)*2, guide_width, guide_t]);
    }
    translate([-joiner_r-guide_offset, 0, 0])
      quad_xz_cyl_shell(joiner_r, joiner_r+guide_curved_space, guide_width, 60);
    mirror([1, 0, 0])
      translate([-joiner_r-guide_offset, 0, 0])
        quad_xz_cyl_shell(joiner_r, joiner_r+guide_curved_space, guide_width, 60);
  }
  translate([-joiner_r-guide_offset, -guide_width/2, -joiner_r-guide_curved_space-guide_t])
    cube([(joiner_r+guide_offset)*2, guide_width, guide_t]);
  translate([-support_w/2, -base_inner_d/2-base_wt, -joiner_r-guide_curved_space-guide_t])
    cube([support_w, base_inner_d+base_wt*2, guide_t]);
  translate([-support_w/2, -base_inner_d/2-base_wt, -joiner_r-guide_curved_space-guide_t])
    cube([support_w, support_t, joiner_r+guide_curved_space+guide_t+base_h]);
  mirror([0, 1, 0])
    translate([-support_w/2, -base_inner_d/2-base_wt, -joiner_r-guide_curved_space-guide_t])
      cube([support_w, support_t, joiner_r+guide_curved_space+guide_t+base_h]);
  translate([-crank_holder_w/2, -driver_pitch_radius-crank_holder_t, base_h-driver_seat_wt])
    cube([crank_holder_w, (driver_pitch_radius-base_inner_d/2-driver_seat_wt-1) + crank_holder_t, 
          driver_seat_h+driver_seat_wt]);
  difference() {
    translate([-crank_holder_w/2, -driver_pitch_radius-crank_holder_t, base_h-driver_seat_wt])
      cube([crank_holder_w, crank_holder_t, 
            driver_gear_height_to_pitch+crank_pitch_radius+driver_seat_h+driver_seat_wt+crank_holder_w/2]);
    // Extra space for the driver gear
    translate([0, 0, driver_seat_h+base_h])
      cylinder(r=driver_pitch_radius+2, h=driver_gear_height_to_pitch+3, $fn=32);
    translate([0, 0, driver_gear_height_to_pitch+crank_pitch_radius+driver_seat_h+base_h])
      rotate([90, 0, 0])
        cylinder(r=crank_shaft_r+tol, h=screw_d, $fn=32);
  }
}

module quad_xz_cyl_shell(r, R, h, $fn) {
  translate([0, -h/2, 0])
    rotate([-90, 0, 0])
    intersection() {
      difference() {
        cylinder(r=R, h=h, $fn=$fn);
        cylinder(r=r, h=h, $fn=$fn);
      }
      cube(R*2);
  }
}

// Gear parameters
driver_gear_height_to_pitch = 5;
driver_teeth = 43;
driver_teeth_width = 8;

crank_gear_t = 8;
crank_teeth = 11;
crank_shaft_r = 3;
crank_hole_r = 3;

circular_pitch = 250;
axis_angle = 90;

driver_tl = 15;
driver_seat_h = 8;
driver_seat_wt = 5;

driver_pitch_radius = driver_teeth * circular_pitch / 360;
crank_pitch_radius = crank_teeth * circular_pitch / 360;
driver_pitch_apex=crank_pitch_radius * sin (axis_angle) + 
  (crank_pitch_radius * cos (axis_angle) + driver_pitch_radius) / tan (axis_angle);
cone_distance = sqrt (pow (driver_pitch_apex, 2) + pow (driver_pitch_radius, 2));

module driver() {
  difference() {
    union() {
      difference() {
        translate([0, 0, driver_gear_height_to_pitch + driver_seat_h])
          bevel_gear(number_of_teeth=driver_teeth,
                     cone_distance=cone_distance,
                     face_width=driver_teeth_width,
                     outside_circular_pitch=circular_pitch,
                     pressure_angle=30,
                     clearance = 0.4,
                     bore_diameter=0,
                     gear_thickness = driver_gear_height_to_pitch,
                     backlash = 0.4,
                     involute_facets=0,
                     finish = -1);
        cylinder(r=screw_d, h=driver_seat_h+tol, $fn=60);
      }
      cylinder(r=screw_d/2+driver_seat_wt, h=driver_seat_h+tol+1, $fn=60);
    }
    screw_void(driver_tl);
  }
}

module crank_gear() {
  difference() {
    bevel_gear(number_of_teeth=crank_teeth,
               cone_distance=cone_distance,
               face_width=crank_gear_t,
               outside_circular_pitch=circular_pitch,
               pressure_angle=30,
               clearance = 0.4,
               bore_diameter=0,
               gear_thickness = crank_gear_t,
               backlash = 0.4,
               involute_facets=0,
               finish = -1);
    cylinder(r=crank_hole_r+tol, h=crank_gear_t, $fn=4);
  }
}

module shaft() {
  cylinder(r=crank_hole_r, h=crank_gear_t, $fn=4);
  translate([0, 0, crank_gear_t])
    cylinder(r=crank_shaft_r+tol, h=crank_holder_t, $fn=32);
  translate([0, 0, crank_gear_t+crank_holder_t])
    cylinder(r=7/2, h=10, $fn=6);
}

// Enable individual modules and render to export STLs. Preferred printing orientations
// included in the rotate on the same line.
//chain();
//base();
//translate([0, 0, base_h]) 
//driver();
//rotate([0, 0, -90])
//translate([driver_pitch_radius, 0, driver_gear_height_to_pitch+crank_pitch_radius+driver_seat_h+base_h])
//rotate([0, -axis_angle, 0])
//crank_gear();
//shaft();
//rotate([90, 0, 0]) connector();
//rotate([0, 180, 0]) chain_link();
rotate([0, 180, 0]) top();
//screw(10);
