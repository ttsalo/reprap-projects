/* Ball Bearing Logic by Tomi T. Salo <ttsalo@iki.fi> */

use <../PyramidSpaceTruss/PyramidSpaceTruss.scad>;

// Main parameters

// Main module dimensions (l=x, w=y, h=z)
l = 100; // Not really used
gate_l = 130; // Full gate length
w = 54; // Nominal width
h = 30; // Nominal height

ss_offset = 8; // How far the source/sink channel is offset from the main module (to negative y)

tol = 0.2;     // Fit tolerance

slope = 10; 

angle = -atan((h+tol)/(l+tol));
l_pitch = sqrt(pow((l+tol), 2)+pow((h+tol), 2));
h_pitch = h*cos(-angle);

r = 12.7/2;    // Ball radius
r2r = 10;       // Ball separation in a double track
R2R = 26;      // Track separation OBSOLETE, replaced by grid_xy
r_tol = 1;   // Ball track tolerance
r_t = 1.8;       // Ball track wall thickness
mid_h = r+r_tol+r_t; // Pipe vertical midpoint - as low as possible to make room on top
sync_frame_pos = 15; // Sync frame start

switch_ramp_l = r + 0.5; // Length of the ramp in the switch section
roof_cut = r*2; // Width of the cut in open-roof pipe sections

// Basic divided 2D double track. Openroof omits a small width of the roof,
// top_cut takes off a percentage of the diameter from the whole top part.
module dpipe_2d(void=false, openroof=false, r_extra=0, top_cut=0.0) {
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
    if (top_cut > 0.0) {
      translate([-r-r_tol-r_t-0.1-r_extra, -r2r/2-r-r_tol-r_t-0.1-r_extra])
        square([(r+r_tol+r_t+0.1+r_extra)*top_cut*2,               
                 r2r+r*2+r_tol*2+r_t*2+0.2+r_extra*2]);   
    }
  }
}

// Basic divided double track section
module dpipe(l, void=false, openroof=false, r_extra=0, labels=false, top_cut=0.0) {
  translate([0, 0, (void ? -0.1 : 0)])
    linear_extrude(height=l + (void ? 0.2 : 0))
      dpipe_2d(void=void, openroof=openroof, r_extra=r_extra, top_cut=top_cut);
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
module pipe(l, void=false, r_extra=0, top_cut=0.0) {
  difference() {
    translate([0, 0, (void ? -0.1 : 0)])
      cylinder(r=r+r_tol+(void ? 0 : r_t)+r_extra, h=l + (void ? 0.2 : 0), $fn=24);
    if (top_cut > 0.0 && !void) {
      translate([-0.1-r*3-r_tol-r_t-r_extra+(r+r_tol+r_t+r_extra)*top_cut*2, 
                 -r-r_tol-r_t-r_extra, -0.1])
      cube([r*2+0.2, r*2+r_tol*2+r_t*2+r_extra*2, l+0.2]);
    }  
  }    
}

//pipe(30, top_cut=0.5);

// Twisting inverter. Note: does not work except for long lengths.
// Twisting circle extrude does not generally pass a sphere.
module dtwist(l, void=false) {
  linear_extrude(height=l, twist=180)
    dpipe_2d(void=void);
}

// Curve a pipe for the an 'angle' section of the torus
// Currently limited to 50% top cut.
module pipe_curve(curve_r, angle, void=false, top_cut=0.0) {
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
    if (top_cut != 0.0 && !void)
      rotate_extrude(convexity = 10, $fn=60)
        translate([curve_r+(top_cut > 0 ? 0 : -r-r_tol-r_t), (-r-r_tol-r_t-0.1), 0])
          square([r+r_tol+r_t, r*2+r_tol*2+r_t*2+0.2]);
  }
}

//pipe_curve(grid_z/2, 90, top_cut=-0.5);
//pipe_curve(14, 90, top_cut=-0.5);

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
// The gap_angle parameter makes the gap widen towards the outside.
module shaft_holder_void(r, h, gap, gap_l=0, gap_angle=0, $fn=$fn) {
  cylinder(r=r, h=h, $fn=$fn);
  if (gap_angle == 0) {
    translate([0, -gap/2, 0])
      cube([r*3, gap, gap_l > 0 ? gap_l : h]);
  } else {
    for (rot = [-gap_angle, gap_angle])
      rotate([0, 0, rot])
        translate([0, -gap/2, 0])
          cube([r*3, gap, gap_l > 0 ? gap_l : h]);
  }
  translate([r*1.5, -r*2, 0])
    cube([r*3, r*4, h]);
}

// Produces a shaft holder, including printing support.
module shaft_holder(r, h, t, $fn=$fn) {
  cylinder(r=r, h=h, $fn=$fn);
  difference() {
    union() {
      rotate([0, 0, -30])
        translate([0, -r, 0])
          cube([t*2, r*2, h]);
      rotate([0, 0, 30])
        translate([0, -r, 0])
          cube([t*2, r*2, h]);
    }
    translate([t, -r*3, 0])
      cube([t*2, r*6, h]);
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


/* Partial void equivalent for the snap_in module */
module snap_in_void(inner_r, outer_r, opening, h) {
  rotate([90, 0, 180]) rotate([0, 0, -opening/2]) {
      cylinder(r=inner_r, h=h, $fn=32);
  }
}

// Sync part parameters

gate_x = 52; // Gate positioning (wheel shaft offset inside frame)

// Wheel positioning in y: edges of the main cylinder relative to track centerline.
wheel_min_y = -8;
wheel_max_y = 8;

wheel_r = 12; // Was 10
wheel_shaft_r = 4/2;
wheel_shaft_holder_r = 12/2;
wheel_shaft_holder_gap = 3.5;
wheel_shaft_square = 4;

wheel_void_tol = 1; // Tolerance for forming the void for the wheel

// Wheel shaft positioning in y (from shaft end to shaft end for single channel)
wheel_shaft_min_y = -12;
wheel_shaft_max_y = 12;
wheel_cutout_offset = 11; // Offset of the ball cutouts from the axis centerline
wheel_shaft_rh_extra = 4; // Extra extension for the double wheel shaft on the right hand side
wheel_shaft_collar_r = 8/2; // Short side collar to locate the shaft sideways
wheel_shaft_collar_w = 2;
wheel_shaft_holder_t = 4;

// Wheel ratchet parameters
wheel_ratchet_min_y = -13.5;
wheel_ratchet_max_y = -10;
wheel_ratchet_r = 16/2;
wheel_ratchet_tooth = 3;

// Wheel offset from track centerline vertically
wheel_offset_z = 35;

wheel_minor_r = 7;

// Ratchet arm parameters
ratchet_shaft_x = 27; // Shaft centerline x position
ratchet_shaft_r = 4/2;
ratchet_shaft_holder_r = 12/2;
ratchet_shaft_holder_t = 4;
ratchet_shaft_l = r2r+r*2+r_tol*2+r_t*2;
ratchet_shaft_z_offset = 40; // Shaft centerline offset in z
ratchet_shaft_holder_gap = 3.5;
ratchet_shaft_collar_r = 8/2;
ratchet_shaft_collar_w = 2;
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

// Logic part parameters

follower_l = 30; // Total length of the follower arm from wheel shaft centerline
follower_shaft_holder_w = 6; // Width of the pivot attachment
follower_shaft_holder_opening = 120; // Degrees of opening for the pivot attachment
follower_shaft_holder_t = 3; // Thickness of the follower's holder around wheel shaft
follower_arm_w = 4; // Width of the main follower arm
follower_arm_t = 3; // Thickness of the main follower arm
follower_rest_angle = 10; // Rest position for the follower

// Trigger parameters
trigger_w = 3; // Trigger wedge thickness
trigger_l = 16; // Length of the trigger wedge
trigger_h = 8; // How far the trigger contact surface start extends from follower arm origin in z
trigger_angle = 20; // Angling of the contact surface of the trigger
trigger_offset = 5; // Distance of the trigger outer edge from the centerline

// Kicker side parameters
kicker_outer_offset = 11; // Kicker part outer edge offset from double track centerline
kicker_t = 4; // Kicker thickness
kicker_l = 8; // Kicker length (in x)
kicker_h = 10; // How far kicker extend from follower arm origin in z

module follower_arm(trigger_pos=4, kicker_ch=2, 
                    kicker_clears=true, kicker_sets=true) {
  difference() {
    union() {
      // Shaft holder  
      translate([0, -follower_shaft_holder_w/2, 0])
        rotate([0, 90, 0])
          snap_in(wheel_shaft_r+tol*2, wheel_shaft_r+follower_shaft_holder_t, 
                  follower_shaft_holder_opening, follower_shaft_holder_w);
      // Secondary shaft holder  
      translate([0, grid_xy/2+wheel_void_tol+r2r/2+r+r_t+wheel_void_tol, 0])
        rotate([0, 90, 0])
          snap_in(wheel_shaft_r+tol*2, wheel_shaft_r+follower_shaft_holder_t, 
                  follower_shaft_holder_opening, wheel_shaft_rh_extra - wheel_void_tol);
      // Main arm
      translate([0, -follower_arm_w/2, -wheel_shaft_r-follower_shaft_holder_t])
        cube([follower_l, follower_arm_w, follower_arm_t]);
      // Cross-arm
      translate([follower_l-follower_arm_w, -grid_xy/2 - kicker_outer_offset, 
                -wheel_shaft_r-follower_shaft_holder_t])
        cube([follower_arm_w, grid_xy + wheel_shaft_max_y + kicker_outer_offset + wheel_shaft_rh_extra,
              follower_arm_t]);
      // Secondary main arm
      translate([0, grid_xy/2+wheel_void_tol+r2r/2+r+r_t+wheel_void_tol, 
                 -wheel_shaft_r-follower_shaft_holder_t])
        cube([follower_l, wheel_shaft_rh_extra - wheel_void_tol, follower_arm_t]);
      // Trigger
      translate([follower_l-trigger_l,
                 (trigger_pos <= 2 ? -1 : 1) * grid_xy/2 
                 + ((trigger_pos == 2 || trigger_pos == 4) ? 
                     trigger_offset - trigger_w : -trigger_offset), 
                -wheel_shaft_r-follower_shaft_holder_t])
        difference() {
          cube([trigger_l, trigger_w, trigger_h*2]);
          translate([0, -0.01, trigger_h])
            rotate([0, -trigger_angle, 0])
              cube([trigger_l*2, trigger_w+0.02, trigger_h]);  
        }
      // Outer kicker
      if (kicker_sets)
      translate([follower_l-kicker_l, 
                 (kicker_ch == 1 ? -1 : 1) * grid_xy/2 - kicker_outer_offset, 
                -wheel_shaft_r-follower_shaft_holder_t/4]) {
        // Support / printing help
        translate([0, 0, -follower_shaft_holder_t*0.75])
          cube([kicker_l, kicker_t, kicker_t]);
        rotate([0, follower_rest_angle, 0])
          difference() {
            cube([kicker_l, kicker_t, wheel_shaft_r + follower_shaft_holder_t/4 + kicker_h]);  
            translate([0, kicker_t, 0])
              cylinder(r=kicker_t, h=kicker_h*2, $fn=24);
            translate([kicker_l, kicker_t, 0])
              cylinder(r=kicker_t, h=kicker_h*2, $fn=24);
          }
      }
      // Inner kicker
      if (kicker_clears)
      translate([follower_l-kicker_l, 
                 (kicker_ch == 1 ? -1 : 1) * grid_xy/2 + kicker_outer_offset - kicker_t, 
                -wheel_shaft_r-follower_shaft_holder_t/4]) {
        // Support / printing help
        translate([0, 0, -follower_shaft_holder_t*0.75])
          cube([kicker_l, kicker_t, kicker_t]);
        rotate([0, follower_rest_angle, 0])
          difference() {
            cube([kicker_l, kicker_t, wheel_shaft_r + follower_shaft_holder_t/4 + kicker_h]);  
            translate([0, 0, 0])
              cylinder(r=kicker_t, h=kicker_h*2, $fn=24);
            translate([kicker_l, 0, 0])
              cylinder(r=kicker_t, h=kicker_h*2, $fn=24);
          }
      }
    }
    // Additional shaft holder voids to cut other components
    translate([0, -follower_shaft_holder_w/2, 0])
        rotate([0, 90, 0])
          snap_in_void(wheel_shaft_r+tol*2, wheel_shaft_r+follower_shaft_holder_t, 
                        follower_shaft_holder_opening, follower_shaft_holder_w);
    translate([0, grid_xy/2+wheel_void_tol+r2r/2+r+r_t+wheel_void_tol, 0])
      rotate([0, 90, 0])
          snap_in_void(wheel_shaft_r+tol*2, wheel_shaft_r+follower_shaft_holder_t, 
                        follower_shaft_holder_opening, wheel_shaft_rh_extra - wheel_void_tol);

    // Main void for rotation
    translate([0, -w/2, 0])
      rotate([-90, 0, 0])
        difference() {
          cylinder(r=follower_l*2, h=w, $fn=64);
          cylinder(r=follower_l, h=w, $fn=64);
        }
  }
}

// Ratchet arm. Origin is in the center of the rotating shaft.
module ratchet_arm() {
   rotate([90, 0, 0]) {
     // Main shaft
     translate([0, 0, -ratchet_shaft_l/2-r_tol-ratchet_shaft_collar_w])
       cylinder(r=ratchet_shaft_r, 
                h=ratchet_shaft_l+r_tol*2+ratchet_shaft_collar_w*2, $fn=24);
     difference() {
       union() {
         // Shaft collars (inner)
         translate([0, 0, -ratchet_shaft_l/2+ratchet_shaft_holder_t+r_tol])
           cylinder(r=ratchet_shaft_collar_r, h=ratchet_shaft_collar_w, $fn=24);
         translate([0, 0, ratchet_shaft_l/2-ratchet_shaft_holder_t
                    -r_tol-ratchet_shaft_collar_w])
           cylinder(r=ratchet_shaft_collar_r, h=ratchet_shaft_collar_w, $fn=24);
         // Shaft collars (outer)
         translate([0, 0, -ratchet_shaft_l/2-ratchet_shaft_collar_w-r_tol])
           cylinder(r=ratchet_shaft_collar_r, h=ratchet_shaft_collar_w, $fn=24);
         translate([0, 0, ratchet_shaft_l/2+r_tol])
           cylinder(r=ratchet_shaft_collar_r, h=ratchet_shaft_collar_w, $fn=24);
         }
         // Cut out sections of the collars to allow supportless printing
         translate([-ratchet_shaft_l/2, -ratchet_shaft_l-ratchet_shaft_r, 
                    -ratchet_shaft_l])
           cube([ratchet_shaft_l, ratchet_shaft_l, ratchet_shaft_l*2]);
      } 
    }
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
              cylinder(r=ratchet_arm_release_gap_r, 
                       h=ratchet_arm_release_gap, $fn=60);
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
       translate([0, grid_xy/2, 0]) {
          rotate([-90, 0, 0]) {
           difference() {
             translate([0, 0, wheel_min_y])
              cylinder(r=wheel_r, h=wheel_max_y-wheel_min_y, $fn=24);             
                for (a = [0, 120, 240]) //  [0, 90, 180, 270])
                    translate([0, 0, wheel_min_y])
                      rotate([0, 0, a+45]) {
                        translate([wheel_cutout_offset, 0, -1])
                            cylinder(r=r+1, 
                                     h=wheel_max_y-wheel_min_y+2, $fn=24);
                         // Extra cutouts to make the wheel "arms" pointy
/*                         rotate([0, 0, -15]) 
                           translate([6, 4, -1]) // XXX non-parametrized
                            cube([r, r, wheel_max_y-wheel_min_y+2]);
                         rotate([0, 0, 15]) 
                           translate([4, 6, -1]) // XXX non-parametrized
                            cube([r, r, wheel_max_y-wheel_min_y+2]);*/
                         rotate([0, 0, 0]) 
                           translate([7, -r*2, -1]) // XXX non-parametrized
                            cube([r, r*4, wheel_max_y-wheel_min_y+2]);
                      }
            translate([0, 0, -ratchet_arm_w/2-wheel_void_tol])
               cylinder(r=wheel_r+0.01, h=ratchet_arm_w+wheel_void_tol*2, $fn=24);
        }
        difference() {
         for (a = [0, 120, 240]) // [0, 90, 180, 270])
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
   rotate([-90, 0, 0]) {
     translate([0, 0, -grid_xy/2-r2r/2-r-r_tol-r_t-wheel_shaft_rh_extra])
          cylinder(r=wheel_shaft_r, 
                   h=grid_xy+r2r+r*2+r_t*2+r_tol*3+wheel_shaft_collar_w           
                     +wheel_shaft_rh_extra, $fn=24);
     translate([0, 0, grid_xy/2+r2r/2+r+r_tol*2+r_t])
       cylinder(r=wheel_shaft_collar_r, h=wheel_shaft_collar_w, $fn=24);
     translate([0, 0, 
       grid_xy/2+r2r/2+r+r_t-wheel_shaft_holder_t-wheel_shaft_collar_w])  
       cylinder(r=wheel_shaft_collar_r, h=wheel_shaft_collar_w, $fn=24);
   }
        
}

// Synchronization part void
module sync_void() {
  for (mirror = [true, false])
   mirror([0, mirror ? 1 : 0, 0]) {
      // Wheel shaft void
      translate([gate_x, grid_xy/2, wheel_offset_z])
       rotate([90, 0, 0])
        rotate([0, 0, 90-gate_io_curve_angle])
         translate([0, 0, -ratchet_shaft_l/2-wheel_void_tol])
           shaft_holder_void(r=wheel_shaft_r+wheel_void_tol,
                              gap=wheel_shaft_holder_gap, h=ratchet_shaft_l+
                              wheel_void_tol*2, gap_angle=5, $fn=24);
      // Wheel void
      translate([gate_x, grid_xy/2, wheel_offset_z])
       rotate([90, 0, 0])
         rotate([0, 0, 45])
           translate([0, 0, -r2r/2-r-r_t-r_tol+wheel_shaft_holder_t]) {
             cylinder(r=wheel_shaft_holder_r+wheel_void_tol+6, 
                      h=r2r+r*2+r_t*2+r_tol*2-wheel_shaft_holder_t*2, $fn=24);
           }
      // Ratchet shaft void
      translate([ratchet_shaft_x, grid_xy/2, ratchet_shaft_z_offset])
       rotate([90, 0, 0])
        rotate([0, 0, 90-gate_io_curve_angle])
         translate([0, 0, -ratchet_shaft_l/2-wheel_void_tol])
           shaft_holder_void(r=ratchet_shaft_r+wheel_void_tol, 
                              gap=ratchet_shaft_holder_gap, h=ratchet_shaft_l+
                              wheel_void_tol*2, gap_angle=5, $fn=24);
     // Ratchet bar void
     translate([ratchet_shaft_x, grid_xy/2, ratchet_shaft_z_offset])
      rotate([90, 0, 0])
        rotate([0, 0, 45])
         translate([0, 0, -r2r/2-r-r_tol-r_t+ratchet_shaft_holder_t]) {
           cylinder(r=ratchet_shaft_holder_r+wheel_void_tol+5, 
                    h=r2r+r*2+r_tol*2+r_t*2-ratchet_shaft_holder_t*2, $fn=24);
         }
    }
}

// Synchronization part frame
module sync_frame_parts() {
    for (mirror = [true, false])
        mirror([0, mirror ? 1 : 0, 0]) {
            translate([gate_x, grid_xy/2, wheel_offset_z])
              rotate([90, 0, 0])
                // Re-use the ratchet shaft measurements for the holders here
                translate([0, 0, -ratchet_shaft_l/2])
                  rotate([0, 0, -90-gate_io_curve_angle])
                    shaft_holder(r=wheel_shaft_holder_r, t=wheel_shaft_holder_r+5,
                                 h=ratchet_shaft_l, $fn=24);
           translate([ratchet_shaft_x, grid_xy/2, ratchet_shaft_z_offset])
             rotate([90, 0, 0])
               translate([0, 0, -ratchet_shaft_l/2])
                 rotate([0, 0, -90-gate_io_curve_angle])
                   shaft_holder(r=ratchet_shaft_holder_r, h=ratchet_shaft_l,
                                 t=ratchet_shaft_holder_r+4, $fn=24);
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
        pipe_displace(total_l, -(w/2-grid_xy/2-r2r/2+ss_offset), half=true, void=void);
  // Kicking part to sink
  translate([0, r2r/2+d, kick_l/2])
      rotate([0, -90, 0])
        pipe_displace(total_l-kick_l/2, -(w/2-grid_xy/2+r2r/2+ss_offset+d), half=true, void=void);
  // Transfer void for the signaled channel
  if (void) {
    translate([0, grid_xy-r2r/2, kick_l/2])
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
      translate([0, w/2+grid_xy/2, mid_h])
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
      translate([0, w/2-grid_xy/2, mid_h])
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
    translate([0, w/2+grid_xy/2, mid_h])
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
    translate([0, w/2-grid_xy/2, mid_h])
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
    translate([70+35/2, w/2+grid_xy/2, h/2]) cylinder(r=r, h=h); // Kick section
  }
}


/* Full gate NG organization:
   0-5 mm straight section in input
   5-? mm sync section
   105-110 mm straight intermediate section
   110-125 mm switch section
   125-130 mm straight section in output
*/
module full_gate_ng(invert_c=false) {
  difference() {
    union() {
      translate([0, w/2+grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          translate([0, 0, sync_frame_pos-5]) dpipe(5);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l]) switch_dpipe(25);
          translate([0, 0, sync_frame_pos+sync_frame_l+25]) switch_dpipe(10, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l+35]) dpipe(5);
         /* if (invert_c)
            translate([0, 0, gate_l-20]) switch_dpipe(15, inverter=false);
          translate([0, 0, gate_l-(invert_c ? 5 : 20)]) dpipe(invert_c ? 5 : 20);  */
       }
      translate([0, w/2-grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          translate([0, 0, sync_frame_pos-5]) dpipe(5);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l]) switch_dpipe(35, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l+35]) dpipe(5);
          //translate([0, 0, 20+sync_frame_l]) kick_and_sink_dpipe(35, 55, 7);
        }
      translate([sync_frame_pos, w/2, mid_h])
          sync_frame_parts();
      // SS channel
     /*  translate([0, -ss_offset, mid_h])
        rotate([0, 90, 0])
          pipe(gate_l); */
    }
    translate([sync_frame_pos, w/2, mid_h])
      sync_void();
    translate([0, w/2+grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          translate([0, 0, 0]) dpipe(5, void=true);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true, void=true);
          //translate([0, 0, 5+sync_frame_l]) dpipe(4, void=true); 
            
          // Crossover section
          translate([0, 0, 5+sync_frame_l]) switch_dpipe(25, inverter=true, void=true); 
          translate([0, 0, 5+sync_frame_l]) dpipe(25, void=true); 
            
          translate([0, 0, 5+sync_frame_l+25]) dpipe(15, void=true); 
          //translate([0, 0, 20+sync_frame_l]) switch_dpipe(35, void=true);
          //translate([0, 0, 20+sync_frame_l+35]) dpipe(5, void=true); 
          if (invert_c) {
            translate([0, 0, gate_l-20]) switch_dpipe(20, inverter=false, void=true);
            translate([0, 0, gate_l-0.1]) dpipe(0.1, void=true); 
          } else {
            translate([0, 0, gate_l-20]) dpipe(20, void=true);
          }
        }
    translate([0, w/2-grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          translate([0, 0, 0]) dpipe(5, void=true);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true, void=true); 
          translate([0, 0, 5+sync_frame_l]) switch_dpipe(35, roofonly=true, void=true);   
          translate([0, 0, 5+sync_frame_l+35]) dpipe(5, void=true);   
          //translate([0, 0, 20+sync_frame_l]) kick_and_sink_dpipe(35, 55, 7, void=true);
        }
    translate([0, -ss_offset, mid_h])
      rotate([0, 90, 0])
        pipe(gate_l, void=true);
    // "inspection hatches"
    translate([110, -5, h/2]) cylinder(r=r, h=h); // Routes to sink
  }
}

/* Pipes to route balls from the source/sink channel into the nearest signal sync section. */
module source_route(l, void=false) {
  // Source to right channel negative value
  translate([0, -w/2+grid_xy/2-ss_offset, 0])
      rotate([0, -90, 0]) {
        translate([5, 0, 0]) pipe_displace(50, (w/2-grid_xy/2+r2r/2+ss_offset), void=void);
      }
  translate([0, r2r/2, 5+25]) pipe(35, void=void);
}

connector_l = 10;
leg_l = 4;
leg_d = 8;
input_l = 80;
output_l = 80;

module connector(level=0, input=false, output=false) {
  translate([0, 0, mid_h])
  rotate([0, 90, 0])
  translate([0, 0, -connector_l/2])
  difference() {
    union() {
      translate([0, w/2+grid_xy/2, 0]) {
        dpipe(connector_l, r_extra=r_t+tol, labels=true);
        if (input) translate([0, 0, -input_l-r_t]) dpipe(input_l+r_t);
        if (output) translate([0, 0, 0]) dpipe(connector_l+output_l+r_t);
      }
      translate([0, w/2-grid_xy/2, 0]) {
        dpipe(connector_l, r_extra=r_t+tol, labels=true);
        if (input) translate([0, 0, -input_l-r_t]) dpipe(input_l+r_t);
        if (output) translate([0, 0, 0]) dpipe(connector_l+output_l+r_t);
      }
     translate([0, -ss_offset, 0]) {
        pipe(connector_l, r_extra=r_t+tol);
        if (input) translate([0, 0, -input_l-r_t]) pipe(input_l+r_t);
        if (output) translate([0, 0, 0]) pipe(connector_l+output_l+r_t);
     }
     for (offset = [w/2+grid_xy/2, w/2-grid_xy/2, -ss_offset])
       translate([r+r_t, offset, connector_l/2])
         rotate([0, 90-slope, 0])
           cylinder(r=leg_d/2, h=leg_l+gate_l*sin(slope)*level);
     if (output) 
      for (offset = [w/2+grid_xy/2, w/2-grid_xy/2, -ss_offset])
       translate([r+r_t, offset, connector_l/2])
         rotate([0, 90-slope, 0])
           translate([-output_l, 0, 0])
           cylinder(r=leg_d/2, h=leg_l+gate_l*sin(slope)*level);
    }
    translate([0, w/2+grid_xy/2, output?-connector_l/2:(input?connector_l/2:0)]) {
       dpipe(connector_l, void=true, r_extra=r_t+tol);
       if (input) translate([0, 0, -input_l-connector_l/2]) dpipe(input_l+connector_l, void=true);
       if (output) translate([0, 0, connector_l/2]) dpipe(output_l+connector_l, void=true);
    }
    translate([0, w/2-grid_xy/2, output?-connector_l/2:(input?connector_l/2:0)]) {
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
      translate([0, w/2+grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, openroof=false);          
       }
      translate([0, w/2-grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, openroof=false);
        }
      translate([0, w/2, mid_h])
        sync_frame_parts();
    }
    translate([0, w/2, mid_h])
      sync_void();
    translate([0, w/2+grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, void=true);          
        }
    translate([0, w/2-grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          switch_dpipe(sync_frame_l, roofonly=true, void=true); 
        }
  }
  if (all_parts) {
    translate([gate_x, w/2, mid_h+wheel_offset_z])
      rotate([0, -45, 0]) double_wheels();
    translate([ratchet_shaft_x, w/2+grid_xy/2, mid_h + ratchet_shaft_z_offset])
      rotate([0, 205, 0]) ratchet_arm();
    translate([ratchet_shaft_x, w/2-grid_xy/2, mid_h + ratchet_shaft_z_offset])
      rotate([0, 220, 0]) ratchet_arm();
  }
}

// Basic invert frame
module invert_frame() {
   difference() {
    union() {
      translate([0, w/2+grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5);          
          translate([0, 0, 5]) switch_dpipe(35, inverter=true);
          translate([0, 0, 40]) dpipe(5); 
       }
      translate([0, w/2-grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5);
          translate([0, 0, 5]) switch_dpipe(15);
          translate([0, 0, 20]) dpipe(5); 
        }
    }
    translate([0, w/2+grid_xy/2, mid_h])
        rotate([0, 90, 0]) {
          dpipe(5, void=true);
          translate([0, 0, 5]) 
            switch_dpipe(45, inverter=true, void=true);
          translate([0, 0, 40]) dpipe(5, void=true); 
        }
    translate([0, w/2-grid_xy/2, mid_h]) {
        rotate([0, 90, 0]) {
           dpipe(0.1, void=true);
          translate([0, 0, 24.9]) dpipe(0.1, void=true); 
        }
      translate([0, -r2r/2, 0]) pipe_displace(25, r2r, half=true, void=true);
      translate([0, r2r/2, 0]) pipe_displace(25, -r2r, half=true, void=true);
    }
  }
}

module assembly() {
    full_gate_ng();
    translate([sync_frame_pos + gate_x, w/2, mid_h + wheel_offset_z])
      double_wheels();
    translate([sync_frame_pos + gate_x, w/2, mid_h + wheel_offset_z])
      rotate([0, follower_rest_angle, 0])
        rotate([180, 0, 0])
          follower_arm();
    //follower_arm();
}

/*
    REFACTORED GRID-BASED SYSTEM STARTS HERE
*/

// Grid elements

grid_xy = 36; // Grid horizontal pitch
grid_z = 24; // Grid vertical pitch
grid_base_t = 4; // Grid block base thickness

grid_spacer_truss_t = 3;
grid_spacer_cross_t = 8;
grid_spacer_corner_extra = 5;

// Grid alignment peg dimensions
grid_peg_xy = 5;
grid_peg_z = 2.5;
grid_peg_tol = 0.2; // 0.4 is loose, 0.3 semi-snap, 0.2 should be firm connection

module grid_peg(height=1, void=false) {
  translate([-grid_peg_xy/2-(void?grid_peg_tol:0), 
             -grid_peg_xy/2-(void?grid_peg_tol:0), 0])
    cube([grid_peg_xy+(void?grid_peg_tol*2:0), 
          grid_peg_xy+(void?grid_peg_tol*2:0),
          (height==0 ? 
          (void ? grid_peg_z+grid_peg_tol : grid_peg_z*3) :
          grid_z*height+grid_peg_z+(void?grid_peg_tol:0))]);
  if (!void) {
    translate([-grid_peg_xy, -grid_peg_xy, 0])
      cube([grid_peg_xy*2, grid_peg_xy*2, grid_peg_z*2]);
  }
}

module grid_block_base(height=1, length=1, width=1, void=false) {
  if (!void) {
    for (i = [0 : length-1]) {
      for (j = [0 : width-1]) {
        translate([grid_xy*i, grid_xy*j, 0])
          grid_peg(height=height);
      }
    }
  } else {
    for (i = [0 : length-1]) {
      for (j = [0 : width-1]) {
        translate([grid_xy*i, grid_xy*j, -grid_z*height])
          grid_peg(height=height, void=true);
      }
    }
  }
}

module grid_spacer(length=1, height=1, for_peg=false, v_bars=true, c_bars=false) {
  difference() {
    union() {
      translate([-grid_xy/2+tol, -grid_xy/2+tol, 0])
        pyramid_box_truss(grid_xy*length-tol*2, grid_xy-tol*2, grid_z*height-tol,
                      length, 1, height<7 ? 2 : (height + height % 2),
                      grid_spacer_truss_t, grid_spacer_truss_t, grid_spacer_truss_t, 
                      (c_bars ? grid_spacer_cross_t : 0), 
                      (v_bars ? grid_spacer_truss_t : 0),
                      false, false, (v_bars ? grid_spacer_corner_extra : 0), 16);
      grid_block_base(length=length, height=height);
      if (for_peg)
        translate([-grid_xy/2, -grid_xy/2, 0])
          grid_spacer_pegholes(length=length);
    }
    grid_block_base(length=length, height=height, void=true);
    if (for_peg)
      translate([-grid_xy/2, -grid_xy/2, 0])
        grid_spacer_pegholes(length=width, void=true);
  }
}

module grid_spacer_solid(length=1, height=1, for_peg=false) {
  difference() {
    union() {
      translate([-grid_xy/2+tol, -grid_xy/2+tol, 0])
        cube([grid_xy*length-tol*2, grid_xy-tol*2, grid_z*height-tol]);
      grid_block_base(length=length, height=height);
      if (for_peg)
        translate([-grid_xy/2, -grid_xy/2, 0])
          grid_spacer_pegholes(length=length);
    }
    grid_block_base(length=length, height=height, void=true);
    if (for_peg)
      translate([-grid_xy/2, -grid_xy/2, 0])
        grid_spacer_pegholes(length=width, void=true);
  }
}

module grid_spacer_pegs(length=1, width=1) {
    for (i = [0 : width-1]) {
        translate([-grid_xy/2 + length*grid_xy, grid_xy/2 + i*grid_xy, 0])
          difference() {
            grid_connector(extra_back=1);
            translate([grid_conn_wedge_y, -grid_conn_wedge_y, grid_peg_z*2])
              cube([grid_conn_wedge_y*2, grid_conn_wedge_y*2, grid_signal_minimal_h]);
          }
      }
    
}

module grid_spacer_pegholes(length=1, width=1, void=false) {
  for (i = [0 : width-1]) {
    translate([-grid_xy/2, grid_xy/2 + i*grid_xy, 0])
      difference() {
        union() {
          grid_connector(void=true, extra_back=1);
          if (!void) translate([grid_xy/2+tol, -grid_conn_wedge_y/2-1, 0])
            cube([grid_conn_total_x+grid_spacer_truss_t, 
              grid_conn_wedge_y+2, grid_peg_z*2]);
        }
        //translate([grid_conn_wedge_y, -grid_conn_wedge_y, grid_peg_z*2])
        //  #cube([grid_conn_wedge_y*2, grid_conn_wedge_y*2, grid_signal_minimal_h]);

      }
  }
}

module grid_spacer_zeroh(length=1, width=1) {
  difference() {
    union() {
      translate([grid_xy/2, grid_xy/2, 0])
        grid_block_base(height=0, length=length, width=width);
      x_pitch = (grid_xy*length-tol*2-grid_spacer_truss_t)/length;
      y_pitch = (grid_xy*width-tol*2-grid_spacer_truss_t)/width;
      translate([tol, tol, 0])
        truss_lattice(grid_xy*length-tol*2, grid_xy*width-tol*2, 
                      length, width, x_pitch, y_pitch,
                      grid_peg_z*2, grid_spacer_truss_t, grid_spacer_truss_t);
      // Right side pegholes
      grid_spacer_pegs(length=length, width=width); // Right side
      translate([grid_xy*length, grid_xy*width, 0])
        rotate([0, 0, 90])
          translate([-grid_xy*width, 0, 0])
            grid_spacer_pegs(length=width, width=length); // Far side
      grid_spacer_pegholes(length=length, width=width);
      translate([grid_xy*length, 0, 0]) rotate([0, 0, 90])
        grid_spacer_pegholes(length=width, width=length);
    }
    translate([grid_xy/2, grid_xy/2, 0])
      grid_block_base(height=0, length=length, width=width, void=true);
    grid_spacer_pegholes(length=length, width=width, void=true);
    translate([grid_xy*length, 0, 0]) rotate([0, 0, 90])
      grid_spacer_pegholes(length=width, width=length, void=true);
  }
}

module grid_spacer_gate_support(length=1, height=1) {
  difference() {
    union() {
      translate([-grid_xy/2+tol, -grid_xy/2+tol, (height-1)*grid_z])
        pyramid_box_truss(grid_xy*length-tol*2, grid_xy-tol*2, grid_z-tol,
                      length, 1, 2,
                      grid_spacer_truss_t, grid_spacer_truss_t, grid_spacer_truss_t, 
                      0, grid_spacer_truss_t,
                      false, false, 16);
      if (height > 1)
        translate([-grid_xy/2+tol, -grid_xy/2+tol, 0])
         pyramid_box_truss(grid_xy*length-tol*2, grid_xy-tol*2, grid_z*(height-1)-tol,
                      length, 1, (height-1)<3 ? 2 : 4,
                      grid_spacer_truss_t, grid_spacer_truss_t, grid_spacer_truss_t, 
                      ((height-1)<3 ? 0 : grid_spacer_cross_t), grid_spacer_truss_t,
                      false, false, 16);
      grid_block_base(length=length, height=height);
      for (j = [0 : length - 1])
        translate([j*grid_xy, 0, (height-1)*grid_z])
        rotate([0, 0, 90])
      for (i = [0, 180]) {
        rotate([0, 0, i]) translate([i == 180 ? grid_xy : 0, 0, ]) {
      // Input connector
      rotate([0, 0, 180]) translate([0, 0, grid_z]) grid_connector(extra_back=1);
      // Support structure for the input connector
      difference() {
        translate([0, 0, grid_z]) rotate([180, 0, 180]) 
          grid_connector(extra_back=(i == 180 ? 1 : 12));
        translate([0, 0, -grid_z/2]) cube([grid_xy*2, grid_xy, grid_z], center=true);
        // Sloping cutout
        translate([-grid_xy/2-grid_conn_total_x, 0, grid_z])
          rotate([0, 70, 0])
            translate([0, -grid_xy/2, -grid_z])
              cube([grid_xy, grid_xy, grid_z]);          
        // Cutout for the extra back part, easier to do here
        translate([-grid_xy/2+4, -grid_xy/2, 0])
           cube([grid_xy, grid_xy, grid_z]);          
      }
  }
      }
    }
    grid_block_base(length=length, height=height, void=true);
    // Signal cutout for the next level
    for (j = [0 : length - 1])
        translate([j*grid_xy, 0, (height-1)*grid_z])
    rotate([0, 0, 90])
    translate([-grid_xy, 0, 
               grid_base_t+r+r_tol+grid_z]) rotate([0, 90, 0])
      dpipe(grid_xy, void=true);
  }
}


grid_signal_base_w = 20;  // The width of the signal base
grid_signal_minimal_h = 9; // Total height of the minimal signal block
grid_conn_wedge_y = 15; // Grid connector wedge width in y
grid_conn_wedge_x = 4; // Grid connector wedge depth in x
grid_conn_total_x = 7; // Grid connector total depth (extension into another block)
grid_conn_tol = 0.2; // Grid connector fit tolerance

/* Increasing the below parameter will slow down incoming signals as there is a 
   risk of a high speed signal bouncing back when entering the block. This can
   be used to create a block to slow down too fast signals (use 14 instead of 9) */
grid_block_top_minimal_h = 9; // Fabric block top minimal height variation

/* Module for the positive and negative sides of the grid block connector.
   The input connections of each module should have the negative side and the
   outputs the positive. */
module grid_connector(void=false, extra_back=1) {
  translate([grid_xy/2-extra_back, -grid_conn_wedge_y/4-(void?grid_conn_tol:0), 0])
    cube([grid_conn_total_x+extra_back+(void?grid_conn_tol:0), 
          grid_conn_wedge_y/2+(void?grid_conn_tol*2:0), 
          (void?grid_z/2:grid_z/2)+extra_back]);
  linear_extrude(height=grid_z/2, scale=[1,0.5]) {
    hull() {
      translate([grid_xy/2+grid_conn_total_x-grid_conn_wedge_x/2,
                 -grid_conn_wedge_y/2+grid_conn_wedge_x/2])
        circle(d=grid_conn_wedge_x+(void?grid_conn_tol*2:0), $fn=16);
      translate([grid_xy/2+grid_conn_total_x-grid_conn_wedge_x/2,
                 grid_conn_wedge_y/2-grid_conn_wedge_x/2])
        circle(d=grid_conn_wedge_x+(void?grid_conn_tol*2:0), $fn=16);
    }
  }
}

/* Submodule forming the signal block base, including the end connectors. */
module grid_signal_base(height=1, length=1, void=false, omit_peg=false,
                        omit_peg_void=false) {
  if (!void) {
    for (i = [0 : length-1]) {
      translate([grid_xy*i, 0, 0])
        grid_peg();
    }
    translate([-grid_xy/2+tol, -grid_signal_base_w/2, 0])
      cube([grid_xy*length-tol*2, grid_signal_base_w, grid_base_t]);
    if (!omit_peg) {
      translate([(length-1)*grid_xy, 0, 0])
         //rotate([0, 0, 180])
           grid_connector();
    }
  } else {
    for (i = [0 : length-1]) {
      translate([grid_xy*i, 0, -grid_z])
        grid_peg(void=true);
     }
     /* Cut out the top part of the signal tube for the roofless minimal
        track segment */
     translate([-grid_xy/2, -grid_xy/2, grid_signal_minimal_h])
       cube([grid_xy*length, grid_xy, grid_z]);
     if (!omit_peg_void)
       translate([-grid_xy, 0, 0])
         grid_connector(void=true);
  }
}

/* Signal element, a minimal straight conduit of given length. */
module grid_block_signal(length=1, invert=false) {
  difference() {
    union() {
      translate([-grid_xy/2+tol, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
        if (invert) 
          switch_dpipe(grid_xy*length-tol*2, inverter=invert);
        else
          dpipe(grid_xy*length-tol*2);
      grid_signal_base(length=length);
    }
    grid_signal_base(void=true, length=length);
    translate([-grid_xy/2, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
      if (invert)
        switch_dpipe(grid_xy*(length), void=true, inverter=invert);
      else
        switch_dpipe(grid_xy*(length), void=true, roofonly=true);
      // Cutout for the peg block
    translate([grid_xy*(length-1), 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
      switch_dpipe(grid_xy, void=true, roofonly=true);
/*     for (i = [0 : length-1]) {
       translate([grid_xy*i, 0, r*3])
         sphere(r=grid_xy/3);
       translate([grid_xy*i+grid_xy/8, -grid_xy/8*3/sqrt(2), r*2])
        rotate([0, -45, 0])
          cube([grid_xy/4*3/sqrt(2), grid_xy/4*3/sqrt(2), grid_z-grid_conn_z-r*2]);
     } */
  }
}

/* Variant of the signal element with the end blocked. (peghole variant) */
module grid_block_signal_end_neg(length=1) {
  difference() {
    union() {
      translate([-grid_xy/2+tol, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
        dpipe(grid_xy*length-tol*2);
      grid_signal_base(length=length, omit_peg=true);
    }
    grid_signal_base(void=true, length=length);
    translate([-r-r_t, 0, 0])
    translate([-grid_xy/2, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
      switch_dpipe(grid_xy*(length), void=true, roofonly=true);
    for (i = [-r2r/2, r2r/2]) {
      translate([grid_xy*(length-0.5)-r-r_t, i, grid_base_t+r+r_tol])
        sphere(r=r+r_tol, $fn=20);
    }
  }
}

/* Variant of the signal element with the end blocked. (peg variant) */
module grid_block_signal_end(length=1) {
  difference() {
    union() {
      translate([-grid_xy/2+tol, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
        dpipe(grid_xy*length-tol*2);
      grid_signal_base(length=length);
    }
    grid_signal_base(void=true, length=length, omit_peg_void=true);
    translate([-grid_xy/2+r+r_t, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
      switch_dpipe(grid_xy*(length), void=true, roofonly=true);
    for (i = [-r2r/2, r2r/2]) {
      translate([grid_xy*-0.5+r+r_t, i, grid_base_t+r+r_tol])
        sphere(r=r+r_tol, $fn=20); 
    }
  }
}
/* Switch fabric element. Takes signal, drops it one level and turns it 
90 degrees to the side. */
module grid_block_fabric() {
  difference() {
    union() {
      grid_block_base(height=2);
      // Output base
      rotate([0, 0, 90]) translate([-grid_xy/2+tol, -grid_signal_base_w/2, 0])
        cube([grid_xy-tol*2, grid_signal_base_w, grid_base_t]);
      // Output connector
      rotate([0, 0, -90]) grid_connector();
      // Input connector
      rotate([0, 0, 180]) translate([0, 0, grid_z]) grid_connector(extra_back=15);
      // Support structure for the input connector
      difference() {
        translate([0, 0, grid_z]) rotate([180, 0, 180]) grid_connector(extra_back=15);
        translate([0, 0, -grid_z/2]) cube([grid_xy*2, grid_xy, grid_z], center=true);
        // Cutout for clearing an adjacent track
        if (false) translate([-grid_xy/2-grid_conn_total_x, 0, grid_z])
          rotate([0, 70, 0])
            translate([0, -grid_xy/2, -grid_z])
              cube([grid_xy, grid_xy, grid_z]);
        // Cutout for clearing an adjancent full block. Alternative to the above.
        translate([-grid_xy*1.5+tol, -grid_xy/2, 0])
              cube([grid_xy, grid_xy, grid_z]);          
      }
//      translate([-grid_xy/2+tol, -grid_xy/2+tol, 0]) // Printing help block
//        cube([grid_xy/4.5, grid_xy/2, grid_z-tol]);
      // Input straight section
      translate([-grid_xy/2+tol, 0, grid_base_t+r+r_tol+grid_z]) rotate([0, 90, 0]) {
        dpipe(grid_xy/2-grid_z/2-r2r/2-tol+0.01);
        translate([0, r2r/2, 0])
          pipe(grid_xy/2-grid_z/2+r2r/2-tol+0.01); 
      }
      // Output straight section
      translate([0, -grid_xy/2+tol, grid_base_t+r+r_tol]) rotate([0, 90, 90]) {
        dpipe(grid_xy/2-grid_z/2-r2r/2-tol+0.01, top_cut=0.0); // 0.5);
        translate([0, -r2r/2, 0])
          pipe(grid_xy/2-grid_z/2+r2r/2-tol+0.01, top_cut=0.0); // 0.5); 
      }
      translate([-grid_z/2+r2r/2, r2r/2, grid_base_t+r+r_tol+grid_z])
        rotate([-90, 0, 0])
          pipe_curve(grid_z/2, 90.1);
      translate([r2r/2, r2r/2, grid_base_t+r+r_tol+grid_z/2])
        rotate([0, 90, 180])
          pipe_curve(grid_z/2, 90, top_cut=0.0); // -0.5);
      translate([-grid_z/2-r2r/2, -r2r/2, grid_base_t+r+r_tol+grid_z])
        rotate([-90, 0, 0])
          pipe_curve(grid_z/2, 90.1);
      translate([-r2r/2, -r2r/2, grid_base_t+r+r_tol+grid_z/2])
        rotate([0, 90, 180])
          pipe_curve(grid_z/2, 90, top_cut=0.0); //-0.5);
    }
    // Upper pipe section cutout
    translate([-grid_xy, -grid_xy, grid_z+grid_block_top_minimal_h])
       cube([grid_xy*2, grid_xy*2, grid_z]);
    grid_block_base(height=2, void=true);
    translate([-grid_xy/2-grid_conn_total_x, 0, 
               grid_base_t+r+r_tol+grid_z]) rotate([0, 90, 0]) {
      dpipe(grid_xy/2-grid_z/2-r2r/2+0.1+grid_conn_total_x, void=true);
      translate([0, r2r/2, 0])
        pipe(grid_xy/2-grid_z/2+r2r/2+0.1+grid_conn_total_x, void=true); 
    }
    translate([0, -grid_xy/2-grid_conn_total_x, grid_base_t+r+r_tol]) 
      rotate([0, 90, 90]) {
        dpipe(grid_xy/2-grid_z/2-r2r/2+0.1+grid_conn_total_x, void=true);
        translate([0, -r2r/2, 0])
          pipe(grid_xy/2-grid_z/2+r2r/2+0.1+grid_conn_total_x, void=true); 
    }
      translate([-grid_z/2+r2r/2, r2r/2, grid_base_t+r+r_tol+grid_z])
        rotate([-90, 0, 0])
          pipe_curve(grid_z/2, 90.1, void=true);
      translate([r2r/2, r2r/2, grid_base_t+r+r_tol+grid_z/2])
        rotate([0, 90, 180])
          pipe_curve(grid_z/2, 90, void=true);
      translate([-grid_z/2-r2r/2, -r2r/2, grid_base_t+r+r_tol+grid_z])
        rotate([-90, 0, 0])
          pipe_curve(grid_z/2, 90.1, void=true);
      translate([-r2r/2, -r2r/2, grid_base_t+r+r_tol+grid_z/2])
        rotate([0, 90, 180])
          pipe_curve(grid_z/2, 90, void=true);
  }    
}

/* Grid gate parameters */
gate_input_straight = 5;
gate_output_straight = 5;

/* The following three are critical to make the gate main pipe connected but
   these are currenty brute forced to fit, so these need adjusting if other
   parameters are changed */
gate_io_curve_r = 20;
gate_io_curve_angle = 14.46;
gate_middle_length = 91.1;

// Take the top off the gate
gate_top_cut = 0.5;

// Gate bottom flat section dimensions
gate_bottom_w = 18; // Width of the flat section
gate_bottom_t = 10.7; // Thickness of the flat section measured from the track
                    // vertical centerline

// Syncro part positioning, relative to the input end of the gate straight part.
// XXX Most of this is defined above near the moving sync parts

/* Switch section (part with no center divider) for the gate output channel */
gate_switch_start = 55;
gate_switch_end = 80;

/* Gate with grid connectors
   Size fixed to 3x2x2, origin on the lower level middle of the input edge */
module grid_gate(omit_sync=false, omit_switch=false, omit_connect=false,
                 slowdown=false) {
  difference() {
    union() {
      for (i = [-grid_xy/2, grid_xy/2]) {
        // Input connectors
        // translate([grid_xy/2, i, grid_z]) rotate([0, 0, 180]) grid_connector();
        // Input straight pipe section
        translate([tol, i, grid_z+grid_base_t+r+r_tol]) rotate([0, 90, 0]) 
          dpipe(gate_input_straight-tol, top_cut=gate_top_cut);
        // Input curved pipe section
        for (j = [-r2r/2, r2r/2])
          translate([gate_input_straight, i+j, grid_z+grid_base_t+r+r_tol]) 
            rotate([-90, 0, 0]) 
              pipe_curve(gate_io_curve_r, gate_io_curve_angle, top_cut=gate_top_cut);
        // Output straight pipe section
        translate([grid_xy*3-gate_output_straight, i, grid_base_t+r+r_tol]) 
          rotate([0, 90, 0]) 
            dpipe(gate_output_straight-tol, top_cut=gate_top_cut);
        // Output curved pipe section
        for (j = [-r2r/2, r2r/2])
          translate([grid_xy*3-gate_input_straight, i+j, +grid_base_t+r+r_tol]) 
            rotate([90, 0, 180]) 
              pipe_curve(gate_io_curve_r, gate_io_curve_angle, top_cut=-gate_top_cut);
        // Middle straight pipe section
        intersection() {
          union() {
            translate([gate_input_straight, 0, 
                       grid_z+grid_base_t+r+r_tol-gate_io_curve_r]) 
              rotate([0, gate_io_curve_angle])
                translate([0, i, gate_io_curve_r])
                  { 
                    grid_gate_middle(top_cut=gate_top_cut, slowdown=slowdown);
                    // Rectangular base
                    translate([-grid_xy, -gate_bottom_w/2, -gate_bottom_t])
                    cube([grid_xy*4, gate_bottom_w, gate_bottom_t]); 
                    // Joining the tracks together
                    if (!omit_connect && i < 0) {
                     translate([grid_xy/3, 0, -gate_bottom_t])
                        cube([grid_xy/4, grid_xy, gate_bottom_t]); 
                     translate([grid_xy*2, 0, -gate_bottom_t])
                        cube([grid_xy/4, grid_xy, gate_bottom_t]); 
                    }
                  }
            }
          /* Clip the baseplate to the bounding box of the whole gate */
          translate([tol, i-grid_xy/2, 0])
            cube([grid_xy*3-tol*2, grid_xy*2, grid_z*2]);
        }
        // Output side bottom support (also needs lattice)
        // translate([grid_xy*2.5, i, 0])
        //  grid_block_base(height=0, length=1, width=1);
      }
      // Sync static parts
      if (!omit_sync)
        sync_frame_parts();
    }
    // Void section
    for (i = [-grid_xy/2, grid_xy/2]) {
       // Input connectors
       translate([-grid_xy/2, i, grid_z]) grid_connector(void=true);
       // Input straight void
       translate([-grid_conn_total_x-1, i, grid_z+grid_base_t+r+r_tol]) 
         rotate([0, 90, 0]) 
           dpipe(gate_input_straight+grid_conn_total_x+1, void=true, openroof=true);
        // Input curved pipe void
        for (j = [-r2r/2, r2r/2])
          translate([gate_input_straight, i+j, grid_z+grid_base_t+r+r_tol]) 
            rotate([-90, 0, 0]) 
              pipe_curve(gate_io_curve_r, gate_io_curve_angle, void=true);
        // Output straight void
        translate([grid_xy*3-gate_output_straight, i, grid_base_t+r+r_tol]) 
          rotate([0, 90, 0]) 
            dpipe(gate_output_straight+grid_conn_total_x+1, void=true);
        // Output curved pipe void
        for (j = [-r2r/2, r2r/2])
          translate([grid_xy*3-gate_input_straight, i+j, +grid_base_t+r+r_tol]) 
            rotate([90, 0, 180]) 
              pipe_curve(gate_io_curve_r, gate_io_curve_angle, void=true);
        // Output connectors
        translate([grid_xy*3.5, i, 0]) rotate([0, 0, 180]) grid_connector(void=true);
        // Middle straight pipe section void
        translate([gate_input_straight, 0, 
                   grid_z+grid_base_t+r+r_tol-gate_io_curve_r]) 
          rotate([0, gate_io_curve_angle])
            translate([0, i, gate_io_curve_r]) 
              grid_gate_middle(void=true, switch=!omit_switch,
                               slowdown=slowdown);
        // Output side bottom support void
        translate([grid_xy*2.5, i, 0])
          grid_block_base(height=0, length=1, width=1, void=true);
    }
    if (!omit_sync)
      sync_void();
  }
  /*
  difference() {
    sync_frame_parts();
    sync_void();
  }*/
  // Sync moving parts, for demonstration and fit check purposes
  
  translate([gate_x, 0, wheel_offset_z])
    //rotate([0, 35, 0])
    double_wheels();
  translate([gate_x, 0, wheel_offset_z])
    rotate([0, follower_rest_angle, 0])
      rotate([180, 15, 0]) {
  //follower_arm(trigger_pos=1);
  //follower_arm(trigger_pos=2);
  //follower_arm(trigger_pos=3);
  //follower_arm(trigger_pos=4);
        follower_arm();
      }
  
  translate([ratchet_shaft_x, +grid_xy/2, ratchet_shaft_z_offset])
    rotate([0, 190, 0]) mirror([1, 0, 0]) ratchet_arm();
  translate([ratchet_shaft_x, -grid_xy/2, ratchet_shaft_z_offset])
    rotate([0, 170, 0]) mirror([1, 0, 0]) ratchet_arm();
  
}

/* The straight, slanted middle section of the gate. */
module grid_gate_middle(void=false, switch=false, top_cut=0.0, slowdown=false) {
  if (slowdown) {
    if (!void) {
      rotate([0, 90, 0]) 
        dpipe(gate_middle_length, void=void, top_cut=top_cut);
      translate([68, 0, 0]) rotate([0, 90, 0]) 
        dpipe(10, void=void, top_cut=0.0);
    } else {
    /* Original idea, 4 inverters in sequence, slowdown is ok but the tight
       curve in the end can make balls jump the sides after exiting. */
    /* n = 4;
    for (i = [1 : n]) {
      translate([gate_middle_length/n*(i-1), 0, 0]) rotate([0, 90, 0])
        dpipe(0.1, void=void);
      translate([gate_middle_length/n*(i-1), 0, 0]) rotate([0, 90, 0])
        switch_dpipe(gate_middle_length/n, void=void, inverter=true);
    } */
    /* n = 4; displace = 4;
    for (i = [1 : n]) translate([gate_middle_length/n*(i-1), 0, 0]) rotate([0, 90, 0]) {
      dpipe(0.1, void=void);
      translate([0, -r2r/2, 0]) rotate([0, -90, 105]) 
        pipe_displace(gate_middle_length/n, displace, half=true, void=true);
      translate([0, r2r/2, 0]) rotate([0, -90, 75]) 
        pipe_displace(gate_middle_length/n, displace, half=true, void=true);
    }  */  
    displace = 4; ramp_start = 30; ramp_len = 30; 
    translate([0, 0, 0]) rotate([0, 90, 0]) dpipe(ramp_start, void=void);
    translate([ramp_start, 0, 0]) rotate([0, 90, 0]) {
      dpipe(0.1, void=void);
      translate([0, -r2r/2, 0]) rotate([0, -90, 105]) 
        pipe_displace(ramp_len, displace, half=true, void=true);
      translate([0, r2r/2, 0]) rotate([0, -90, 75]) 
        pipe_displace(ramp_len, displace, half=true, void=true);
    }
    translate([ramp_start+ramp_len, 0, 0]) rotate([0, 90, 0]) 
      dpipe(gate_middle_length-ramp_start-ramp_len, void=void);
    }
  } else {
    rotate([0, 90, 0]) 
      dpipe(gate_middle_length, void=void, top_cut=top_cut);
    if (switch)
      rotate([0, 90, 0])
        translate([0, 0, gate_switch_start])
          switch_dpipe(gate_switch_end-gate_switch_start, void=true);
  }
}

module grid_assembly() {
  grid_block_signal();
  translate([grid_xy, 0, 0]) grid_block_base();
  translate([grid_xy/2, 0, -grid_conn_z]) grid_connector();
  translate([-grid_xy/2, 0, -grid_conn_z]) grid_connector();translate([-grid_xy/2, 0, -grid_conn_z+grid_z]) grid_connector();
  translate([grid_xy/2, 0, -grid_conn_z+grid_z]) grid_connector();
  translate([-grid_xy/2, 0, -grid_conn_z+grid_z]) grid_connector();

}

//rotate([0, -90, 0])
//grid_block_fabric();
//rotate([0, -gate_io_curve_angle, 0]) 
//  grid_gate();
//translate([-grid_xy*3, 0, grid_z]) grid_gate();
//difference() {
//  grid_gate(omit_sync=true, omit_switch=true, omit_connect=true, slowdown=true);
//  cube([200, 200, 200]);
//}
//translate([73, -grid_xy/2+r2r/2, 20]) sphere(r=r);
//translate([grid_xy/2, 0, 0]) rotate([0, 0, -90])
//translate([0, grid_xy, 0]) grid_block_signal(length=2);
//difference() {
//  grid_block_signal_end(length=1);
// grid_block_signal_end_neg(length=1);
//  translate([2, 0, 0]) linear_extrude(10) scale([2, 2, 1]) rotate([0, 0, -90]) text("X", font="USAAF_Stencil", halign="center", valign="center"); }
//difference() {
//  grid_block_signal_end(length=1);
//  linear_extrude(10) scale([2.5, 2.5, 1]) rotate([0, 0, 90]) text("C", font="USAAF_Stencil", halign="center", valign="center"); }
//translate([grid_xy*3.5, -grid_xy/2, 0]) grid_block_signal(length=1);
//translate([grid_xy*-.5, -grid_xy/2, grid_z]) grid_block_signal(length=1);
//translate([-grid_xy, 0, grid_z]) grid_block_signal(length=1);
//translate([0, -grid_xy, 0]) grid_block_signal(length=1, invert=true);
//translate([grid_xy, 0, 0]) 
//grid_block_signal(invert=true);
//grid_block_signal(length=2);
//translate([grid_xy, 0, 0]) rotate([0, 0, 180])grid_block_signal(length=2);
//translate([-grid_xy/2, 0, grid_z-grid_conn_z]) color("salmon") grid_connector();
//translate([grid_xy, 0, grid_z-grid_conn_z]) color("salmon") grid_connector_multi(length=1, width=1);
//difference() { union() {´
//grid_block_base(length=2, width=2, height=1);
//grid_spacer_zeroh(length=2, width=1);
//translate([-grid_xy/2, grid_xy/2, 0]) rotate([0, 0, 90])
//grid_spacer_gate_support(length=1, height=1);
//translate([-grid_xy/2*3, grid_xy/2, -grid_z])
//for (h = [1:8]) translate([h*grid_xy, 0, 0])
//grid_spacer(length=1, height=6, v_bars=false, c_bars=true);
//grid_spacer(length=1, height=1, v_bars=true, c_bars=false);
//grid_spacer_solid(length=1, height=3);
//translate([-grid_xy/2*5, grid_xy/2, -grid_z]) grid_spacer(length=1, height=3);
//translate([-grid_xy/2*7, grid_xy/2, -grid_z]) grid_spacer(length=1, height=4);
//} translate([0, 0, -50]) cube([100, 100, 100]); }
//translate([-grid_xy/2, 0, grid_z*2-grid_conn_z]) grid_connector();
//translate([0,0 , grid_z*2-grid_conn_z]) grid_connector_multi(length=3, width=1
//, omit_start_x=true, omit_end_x=tru, 
//, omit_start_y=true, omit_end_y=true
//); 
//rotate([0, 45, 0]) double_wheels();
//ratchet_arm();

// GATES
// AND: If triggering signal is 0, clears output signal
// OR: If triggering signal is 1, sets output signal
// XOR: If triggering signal is 1, inverts output signal
// (REPEATER is OR, but incoming output signal mst be 0)

// AND-L (left output)
//follower_arm(trigger_pos=4, kicker_ch=1, kicker_clears=true, kicker_sets=false);
// AND-R (right output)
//follower_arm(trigger_pos=2, kicker_ch=2, kicker_clears=true, kicker_sets=false);
// OR-L (left output)
//follower_arm(trigger_pos=3, kicker_ch=1, kicker_clears=false, kicker_sets=true);
// OR-R (right output)
//follower_arm(trigger_pos=1, kicker_ch=2, kicker_clears=false, kicker_sets=true);
// XOR-L (left output)
//follower_arm(trigger_pos=3, kicker_ch=1, kicker_clears=true, kicker_sets=true);
// XOR-R (right output)
//follower_arm(trigger_pos=1, kicker_ch=2, kicker_clears=true, kicker_sets=true);




//rotate([0, -90, 0])
//rotate([0, slope, 0])
//assembly();
//full_gate_ng();

//kick_dpipe(30, 7, void=true);
//kick_dpipe(30, 7);

//kick_and_sink_dpipe(35, 55, 7, void=true);

//difference() {
//  switch_dpipe(30, roofonly=true, openroof=true);
//  switch_dpipe(30, roofonly=true, openroof=true, void=true);
//}

//rotate([0, slope, 0])
//rotate([0, -90, 0])
//connector(level=2, input=true);

//rotate([0, slope, 0])
//translate([gate_l, 0, 0])
//connector(level=1, output=true);

//rotate([0, slope, 0])
//difference() {
//    full_gate_ng();
//    translate([62, w/2+2, 10]) cube([150, 150, 50]);
//    translate([-1, -50, 0]) cube([15+1, 150, 50]);
//  sync_frame(all_parts=true);
//}
//rotate([90, 0, 0]) 
//{
//wheel(part1=false);
//wheel(part2=false); 
//%wheel(void=true);
//}


//invert_frame();
