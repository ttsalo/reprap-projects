/* Ball Bearing Logic by Tomi T. Salo <ttsalo@iki.fi> */

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
R2R = 26;      // Track separation
r_tol = 1;   // Ball track tolerance
r_t = 1.8;       // Ball track wall thickness
mid_h = r+r_tol+r_t; // Pipe vertical midpoint - as low as possible to make room on top
sync_frame_pos = 15; // Sync frame start

switch_ramp_l = r + 0.5; // Length of the ramp in the switch section
roof_cut = r*2; // Width of the cut in open-roof pipe sections

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

gate_x = 36; // Gate positioning (wheel shaft offset inside frame)

// Wheel positioning in y: edges of the main cylinder relative to track centerline.
wheel_min_y = -8;
wheel_max_y = 8;

wheel_r = 10;
wheel_shaft_r = 4/2;
wheel_shaft_holder_r = 12/2;
wheel_shaft_holder_gap = 3.5;
wheel_shaft_square = 4;

wheel_void_tol = 1; // Tolerance for forming the void for the wheel

// Wheel shaft positioning in y (from shaft end to shaft end for single channel)
wheel_shaft_min_y = -12;
wheel_shaft_max_y = 12;

wheel_shaft_rh_extra = 6; // Extra extension for the double wheel shaft on the right hand side

// Wheel ratchet parameters
wheel_ratchet_min_y = -13.5;
wheel_ratchet_max_y = -10;
wheel_ratchet_r = 16/2;
wheel_ratchet_tooth = 3;

// Wheel offset from track centerline vertically
wheel_offset_z = 12;

wheel_minor_r = 7;

// Ratchet arm parameters
ratchet_shaft_x = 11; // Shaft centerline x position
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

// Logic part parameters

follower_l = 30; // Total length of the follower arm from wheel shaft centerline
follower_shaft_holder_w = 8; // Width of the pivot attachment
follower_shaft_holder_opening = 120; // Degrees of opening for the pivot attachment
follower_shaft_holder_t = 3; // Thickness of the follower's holder around wheel shaft
follower_arm_w = 4; // Width of the main follower arm
follower_arm_t = 3; // Thickness of the main follower arm
follower_rest_angle = 10; // Rest position for the follower

// Trigger parameters
trigger_w = 3; // Trigger wedge thickness
trigger_l = 18; // Length of the trigger wedge
trigger_h = 8; // How far the trigger contact surface start extends from follower arm origin in z
trigger_angle = 20; // Angling of the contact surface of the trigger

// Kicker side parameters
kicker_outer_offset = 11; // Kicker part outer edge offset from double track centerline
kicker_t = 4; // Kicker thickness
kicker_l = 8; // Kicker length (in x)
kicker_h = 10; // How far kicker extend from follower arm origin in z

module follower_arm() {
  difference() {
    union() {
      // Shaft holder  
      translate([0, -follower_shaft_holder_w/2, 0])
        rotate([0, 90, 0])
          snap_in(wheel_shaft_r+tol*2, wheel_shaft_r+follower_shaft_holder_t, 
                  follower_shaft_holder_opening, follower_shaft_holder_w);
      // Secondary shaft holder  
      translate([0, R2R/2+wheel_shaft_max_y+wheel_void_tol, 0])
        rotate([0, 90, 0])
          snap_in(wheel_shaft_r+tol*2, wheel_shaft_r+follower_shaft_holder_t, 
                  follower_shaft_holder_opening, wheel_shaft_rh_extra - wheel_void_tol);
      // Main arm
      translate([0, -follower_arm_w/2, -wheel_shaft_r-follower_shaft_holder_t])
        cube([follower_l, follower_arm_w, follower_arm_t]);
      // Cross-arm
      translate([follower_l-follower_arm_w, -R2R/2 - kicker_outer_offset, 
                -wheel_shaft_r-follower_shaft_holder_t])
        cube([follower_arm_w, R2R + wheel_shaft_max_y + kicker_outer_offset + wheel_shaft_rh_extra,
              follower_arm_t]);
      // Secondary main arm
      translate([0, R2R/2-follower_arm_w+wheel_shaft_max_y+wheel_shaft_rh_extra, 
                 -wheel_shaft_r-follower_shaft_holder_t])
        cube([follower_l, follower_arm_w, follower_arm_t]);
      // Trigger
      translate([follower_l-trigger_l, R2R/2 + wheel_max_y - trigger_w, 
                -wheel_shaft_r-follower_shaft_holder_t])
        difference() {
          cube([trigger_l, trigger_w, trigger_h*2]);
          translate([0, -0.01, trigger_h])
            rotate([0, -trigger_angle, 0])
              cube([trigger_l*2, trigger_w+0.02, trigger_h]);  
        }
      // Outer kicker
      translate([follower_l-kicker_l, -R2R/2 - kicker_outer_offset, 
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
      translate([follower_l-kicker_l, -R2R/2 + kicker_outer_offset - kicker_t, 
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
    translate([0, R2R/2+wheel_shaft_max_y+wheel_void_tol, 0])
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
               cylinder(r=wheel_r+0.01, h=ratchet_arm_w+wheel_void_tol*2, $fn=24);
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
        translate([0, 0, -R2R/2+wheel_shaft_min_y-wheel_shaft_rh_extra])
          cylinder(r=wheel_shaft_r, 
                   h=wheel_shaft_max_y-wheel_shaft_min_y+R2R+wheel_shaft_rh_extra, $fn=24);
}

// Synchronization part void
module sync_void() {
  for (mirror = [true, false])
   mirror([0, mirror ? 1 : 0, 0]) {
       // Wheel cutout
       translate([gate_x, R2R/2, wheel_offset_z])
          rotate([0, -45, 0])
            wheel(void=true);
      // Ratchet shaft void
      translate([ratchet_shaft_x, R2R/2, ratchet_shaft_z_offset])
       rotate([90, 0, 0])
        rotate([0, 0, 45])
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
             translate([-ratchet_arm_l, -ratchet_shaft_holder_r-wheel_void_tol, 0])
               cube([ratchet_arm_l, (ratchet_shaft_holder_r+wheel_void_tol)*2,
                     ratchet_arm_w+wheel_void_tol*2]);
         }
      intersection() {
        if (mirror == true)
          translate([gate_x, R2R/2-wheel_max_y-wheel_void_tol, 0])
            cube([follower_l+wheel_void_tol*2, wheel_max_y-wheel_min_y+wheel_void_tol*2, h]);
        else
          translate([sync_frame_l, R2R/2-kicker_outer_offset-wheel_void_tol, 0])
            cube([follower_l-(sync_frame_l-gate_x)+wheel_void_tol*2, 
                  kicker_outer_offset*2+wheel_void_tol*2, h]);
        translate([gate_x, 0, wheel_offset_z])
          rotate([-90, 0, 0])
            cylinder(r=follower_l+wheel_void_tol*2, h=w/2, $fn=64);
      }
    }
    // Shaft middle extra cutout
   translate([gate_x, -follower_shaft_holder_w/2-wheel_void_tol, wheel_offset_z])
       rotate([-90, 0, 0])
         cylinder(r=wheel_shaft_r+follower_shaft_holder_t+wheel_void_tol, 
                 h=follower_shaft_holder_w+wheel_void_tol*2, $fn=24);
    // Shaft RH side extra cutout
   translate([gate_x, -R2R/2-wheel_shaft_max_y-wheel_shaft_rh_extra-wheel_void_tol, 
               wheel_offset_z])
       rotate([-90, 0, 0])
         cylinder(r=wheel_shaft_r+follower_shaft_holder_t+wheel_void_tol, 
                 h=wheel_shaft_rh_extra+wheel_void_tol, $fn=24);

}

// Synchronization part frame
module sync_frame_parts() {
    for (mirror = [true, false])
        mirror([0, mirror ? 1 : 0, 0]) {
            translate([gate_x, R2R/2, wheel_offset_z])
              rotate([90, 0, 0])
                translate([0, 0, wheel_shaft_min_y])
                  rotate([0, 0, -135])
                     // Dropped the inner shaft holders,
                     // was h=wheel_shaft_max_y-wheel_shaft_min_y
                    shaft_holder(r=wheel_shaft_holder_r,
                                 h=wheel_max_y-wheel_shaft_min_y, $fn=24);
           translate([ratchet_shaft_x, R2R/2, ratchet_shaft_z_offset])
             rotate([90, 0, 0])
               translate([0, 0, -ratchet_shaft_l/2])
                 rotate([0, 0, -135])
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
      translate([0, w/2+R2R/2, mid_h])
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
      translate([0, w/2-R2R/2, mid_h])
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
    translate([0, w/2+R2R/2, mid_h])
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
    translate([0, w/2-R2R/2, mid_h])
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
  translate([0, -w/2+R2R/2-ss_offset, 0])
      rotate([0, -90, 0]) {
        translate([5, 0, 0]) pipe_displace(50, (w/2-R2R/2+r2r/2+ss_offset), void=void);
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
          translate([0, 0, 5]) switch_dpipe(35, inverter=true);
          translate([0, 0, 40]) dpipe(5); 
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
            switch_dpipe(45, inverter=true, void=true);
          translate([0, 0, 40]) dpipe(5, void=true); 
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

// Grid elements

grid_xy = 36; // Grid horizontal pitch
grid_z = 24; // Grid vertical pitch (including connectors)
grid_base_t = 4; // Grid block base thickness

grid_conn_z = 3; // Connector thickness
grid_conn_pole_h = 3; // Connector pole height
grid_conn_pole_d = 4; // Connector pole diameter
grid_conn_pole_tol = 0.3; // Connector pole tolerance
grid_conn_slot_tol = 0.3; // Connector slot tolerance

module grid_block_base(height=1, void=false) {
  if (!void) {
    translate([-grid_xy/2+tol, -grid_xy/2+tol, 0])
      cube([grid_xy-tol*2, grid_xy-tol*2, grid_base_t]);
    translate([-grid_xy/2+tol, -grid_xy/4, 0])
      cube([grid_xy-tol*2, grid_xy/2, grid_z*height-grid_conn_z-tol]);
  } else {
    for (rot = [0, 90, 180, 270]) {
      rotate([0, 0, rot])
        for (y = [grid_xy/4, -grid_xy/4]) {
          translate([grid_xy/2-grid_conn_pole_d, y, -1])
            cylinder(d=grid_conn_pole_d+grid_conn_pole_tol*2, h=grid_conn_pole_h+1+tol, $fn=16);
        }
    }
  }
}

module grid_connector() {
  translate([-grid_xy/8, -grid_xy/4, 0])
    cube([grid_xy/4, grid_xy/2, grid_conn_z]);
  for (x = [grid_conn_pole_d, -grid_conn_pole_d]) {
    for (y = [grid_xy/4, -grid_xy/4]) {
      translate([x, y, 0])
        cylinder(d=grid_conn_pole_d, h=grid_conn_z + grid_conn_pole_h - tol, $fn=16);
    }
  }  
}

module grid_connector_slot() {
  translate([-grid_xy/8, -grid_xy/4, 0])
    cube([grid_xy/8-grid_conn_slot_tol, grid_xy/2, grid_conn_z]);
  translate([-grid_xy/8, -grid_xy/6, 0])
    cube([grid_xy/4, grid_xy/3, grid_conn_z]);
  for (y = [grid_xy/4, -grid_xy/4]) {
    translate([-grid_conn_pole_d, y, 0])
      cylinder(d=grid_conn_pole_d, h=grid_conn_z + grid_conn_pole_h - tol, $fn=16);
  }
}

module grid_block_signal(invert=false) {
  difference() {
    union() {
      grid_block_base();  
      translate([-grid_xy/2+tol, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
        if (invert) 
          switch_dpipe(grid_xy-tol*2, inverter=invert);
        else
          dpipe(grid_xy-tol*2);
    }
    grid_block_base(void=true);  
    translate([-grid_xy/2, 0, grid_base_t+r+r_tol]) rotate([0, 90, 0])
      if (invert)
        switch_dpipe(grid_xy, void=true, inverter=invert);
      else
        switch_dpipe(grid_xy, void=true, roofonly=true);
      translate([0, 0, r*3])
        sphere(r=grid_xy/3);
     translate([grid_xy/8, -grid_xy/8*3/sqrt(2), r*2])
      rotate([0, -45, 0])
        cube([grid_xy/4*3/sqrt(2), grid_xy/4*3/sqrt(2), grid_z-grid_conn_z-r*2]);
  }
}

/* Switch fabric element. Takes signal, drops it one level and turns it 
90 degrees to the side. */
module grid_block_fabric() {
  difference() {
    union() {
      grid_block_base(height=2);
      translate([-grid_xy/2+tol, -grid_xy/2+tol, 0]) // Printing help
        cube([grid_xy/4.5, grid_xy/2, grid_z-grid_conn_z-tol]);
      translate([-grid_xy/2+tol, 0, grid_base_t+r+r_tol+grid_z]) rotate([0, 90, 0]) {
        dpipe(grid_xy/2-grid_z/2-r2r/2-tol+0.01);
        translate([0, r2r/2, 0])
          pipe(grid_xy/2-grid_z/2+r2r/2-tol+0.01); 
      }
      translate([0, -grid_xy/2+tol, grid_base_t+r+r_tol]) rotate([0, 90, 90]) {
        dpipe(grid_xy/2-grid_z/2-r2r/2-tol+0.01);
        translate([0, -r2r/2, 0])
          pipe(grid_xy/2-grid_z/2+r2r/2-tol+0.01); 
      }
      translate([-grid_z/2+r2r/2, r2r/2, grid_base_t+r+r_tol+grid_z])
        rotate([-90, 0, 0])
          pipe_curve(grid_z/2, 90.1);
      translate([r2r/2, r2r/2, grid_base_t+r+r_tol+grid_z/2])
        rotate([0, 90, 180])
          pipe_curve(grid_z/2, 90);
      translate([-grid_z/2-r2r/2, -r2r/2, grid_base_t+r+r_tol+grid_z])
        rotate([-90, 0, 0])
          pipe_curve(grid_z/2, 90.1);
      translate([-r2r/2, -r2r/2, grid_base_t+r+r_tol+grid_z/2])
        rotate([0, 90, 180])
          pipe_curve(grid_z/2, 90);
    }
    grid_block_base(height=2, void=true);
    translate([-grid_xy/2, 0, grid_base_t+r+r_tol+grid_z]) rotate([0, 90, 0]) {
      dpipe(grid_xy/2-grid_z/2-r2r/2+0.1, void=true);
      translate([0, r2r/2, 0])
        pipe(grid_xy/2-grid_z/2+r2r/2+0.1, void=true); 
    }
    translate([0, -grid_xy/2, grid_base_t+r+r_tol]) rotate([0, 90, 90]) {
      dpipe(grid_xy/2-grid_z/2-r2r/2+0.1, void=true);
      translate([0, -r2r/2, 0])
        pipe(grid_xy/2-grid_z/2+r2r/2+0.1, void=true); 
 
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
      translate([-grid_xy/8-grid_xy/2, -grid_xy/6-grid_conn_slot_tol, 
                 -grid_conn_z+grid_z-grid_conn_slot_tol])
        cube([grid_xy/4+grid_conn_slot_tol, grid_xy/3+grid_conn_slot_tol*2, 
              grid_conn_z+grid_conn_slot_tol*2]);
  }    
}

module grid_gate() 
{
  difference() {
    union() {
      translate([0, grid_xy, mid_h])
        rotate([0, 90+slope, 0]) {
          translate([0, 0, sync_frame_pos-5]) dpipe(5);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l]) switch_dpipe(25);
          translate([0, 0, sync_frame_pos+sync_frame_l+25]) switch_dpipe(10, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l+35]) dpipe(5);
       }
      translate([0, 0, mid_h])
        rotate([0, 90+slope, 0]) {
          translate([0, 0, sync_frame_pos-5]) dpipe(5);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l]) switch_dpipe(35, roofonly=true);
          translate([0, 0, sync_frame_pos+sync_frame_l+35]) dpipe(5);
        }
      translate([sync_frame_pos, grid_xy/2, mid_h])
        rotate([0, slope, 0])
          sync_frame_parts();
      translate([grid_xy/2, 0, -grid_z])
        grid_block_base(height=2);
      translate([grid_xy*2.5, 0, -grid_z])
        grid_block_base();
    }
    translate([sync_frame_pos, w/2, mid_h])
      rotate([0, slope, 0])
        sync_void();
    translate([0, grid_xy, mid_h])
        rotate([0, 90+slope, 0]) {
          translate([0, 0, 0]) dpipe(5, void=true);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true, void=true);
          //translate([0, 0, 5+sync_frame_l]) dpipe(4, void=true); 
            
          // Crossover section
          translate([0, 0, 5+sync_frame_l]) switch_dpipe(25, inverter=true, void=true); 
          translate([0, 0, 5+sync_frame_l]) dpipe(25, void=true); 
            
          translate([0, 0, 5+sync_frame_l+25]) dpipe(15, void=true); 
          //translate([0, 0, 20+sync_frame_l]) switch_dpipe(35, void=true);
          //translate([0, 0, 20+sync_frame_l+35]) dpipe(5, void=true); 
          translate([0, 0, gate_l-20]) dpipe(20, void=true);
        }
    translate([0, 0, mid_h])
        rotate([0, 90+slope, 0]) {
          translate([0, 0, 0]) dpipe(5, void=true);
          translate([0, 0, sync_frame_pos]) switch_dpipe(sync_frame_l, roofonly=true, void=true); 
          translate([0, 0, 5+sync_frame_l]) switch_dpipe(35, roofonly=true, void=true);   
          translate([0, 0, 5+sync_frame_l+35]) dpipe(5, void=true);   
          //translate([0, 0, 20+sync_frame_l]) kick_and_sink_dpipe(35, 55, 7, void=true);
        }
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
grid_gate();
//translate([-grid_xy/2, 0, -grid_conn_z+grid_z]) grid_connector_slot();
//grid_block_signal();
//translate([grid_xy, 0, 0]) 
//grid_block_signal(invert=true);
//grid_connector();

//rotate([0, -90, 0])
//rotate([0, slope, 0])
//assembly();
//full_gate_ng();
//follower_arm();

//kick_dpipe(30, 7, void=true);
//kick_dpipe(30, 7);

//kick_and_sink_dpipe(35, 55, 7, void=true);

//difference() {
//  switch_dpipe(30, roofonly=true);
//  switch_dpipe(30, roofonly=true, void=true);
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
//double_wheels();
//ratchet_arm();
//invert_frame();
