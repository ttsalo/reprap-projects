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
sync_frame_pos = 20; // Sync frame start

switch_ramp_l = r + 0.5; // Length of the ramp in the switch section
roof_cut = r*2; // Width of the cut in open-roof pipe sections

pin_r = 3;
pin_h = 3;

frame_t = 3;
corner_t = 12;

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
    }
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
   5-20 mm switch section
   20-70 mm sync section
   70-105 mm kick section
   105-110 mm straight intermediate section
   110-125 mm switch section
   125-130 mm straight section in output
*/
module full_gate_ng(invert_a=false, invert_b=false, invert_c=false) {
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
          //translate([0, 0, 20+sync_frame_l]) kick_and_sink_dpipe(35, 55, 7);
        }
      translate([sync_frame_pos, w/2, mid_h])
          sync_frame_parts();
      translate([0, -ss_offset, mid_h])
        rotate([0, 90, 0])
          pipe(gate_l);
    }
    translate([sync_frame_pos, w/2, mid_h])
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

module assembly() {
    full_gate_ng();
    translate([sync_frame_pos + gate_x, w/2, mid_h + wheel_offset_z])
      double_wheels();
}

assembly();

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

//rotate([0, -90, 0])
//rotate([0, slope, 0])
//difference() {
//    full_gate();
//    translate([62, w/2+2, 10]) cube([150, 150, 50]);
//    translate([-1, -50, 0]) cube([15+1, 150, 50]);
//full_repeater();
//sync_frame(all_parts=true);
//}
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
