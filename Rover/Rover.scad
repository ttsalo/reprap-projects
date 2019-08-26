/* Rocker-bogey Rover by Tomi T. Salo <ttsalo@iki.fi> 2019. */

/* Rocker-bogey Mars-style rover.
   
   Coordinate system:
   X: widthwise of the rover, zero is centerline
   Y: lengthwise of the rover, zero is rocker pivot axis
   Z: heightwise of the rover, zero is wheel axis level
   
   Final vehicle approx specs:
   Wheel dia 80mm
   Track width 240mm
   Total wheelbase 320mm
   Max speed 100mm/s -> Wheel RPM 23.4
   Motor ZGY370 30 RPM 2.7 kg.cm -> 6.6 N/wheel -> 39.4 N tot
   Motor GA37RG 30 RPM 3.5 kg.cm -> 8.5 N/wheel -> 51 N tot
   Motor JGY37-520
   Tank steering
   
   Project plan:
   1. Develop unpowered half scale model to verify the geometry, joints etc.
   2. Develop final model drivetrain with interchangeable chassis
   3. Develop chassis for all the electronics
   
   Design features:
   - Maximal amount of printed parts
    - Aim for just M3 fasteners and electronics. Maybe bearings.
   - Use truss structures where applicable
   - Drivetrain is minimal and offers a cradle with a bolt pattern for the payload.
   - Drivetrain does not have to be rigid enough to run independently,
     it can rely on the rigidity of the payload once assembled.
   - Snap-on diff rod connections
   
*/

use <../PyramidSpaceTruss/PyramidSpaceTruss.scad>;

lh = 0.3;   // layer height
tol = 0.2;  // tight tolerance
fit = 0.4;  // loose fit tolerance

/* Half-scale parameters */

track_w = 120;
bogey_pivot = 50; // Bogey pivot offset from rocker pivot
rocker_h = 40; // Rocker pivot height from wheel axis
bogey_h = 30; // Bogey pivot height from wheel axis

wheel1 = 80; // Front wheel offset from rocker pivot
wheel2 = 25; // Middle wheel offset from rocker pivot
wheel3 = -40; // Back wheel offset from rocker pivot

wheel_d = 40; // Wheel outer diameter
wheel_w = 20; // Wheel width
wheel_flange_t = 2; // Wheel mounting flange thickness
wheel_flange_c = 2; // Wheel mounting flange clearance
wheel_flange_d = 20; // Wheel mounting flange diameter

bogey_bar_w = 10; // Bogey bar width
bogey_bar_t = 8; // Bogey bar thickness
bogey_pivot_d = 8; // Bogey pivot shaft diameter
bogey_pivot_D = 12; // Bogey pivot shaft holder diameter
bogey_pivot_l = bogey_bar_t; // Bogey pivot shaft length
bogey_zero_x = track_w/2 - wheel_w/2 - wheel_flange_c - bogey_pivot_l;
bogey_bar1_l = sqrt(pow(bogey_h, 2) + pow(wheel1-bogey_pivot, 2));
bogey_bar2_l = sqrt(pow(bogey_h, 2) + pow(wheel2-bogey_pivot, 2));
bogey_pivot_bolt_d = 3;
bogey_pivot_bolt_l = 14;
bogey_truss_t = 2;

rocker_bar_w = 12; // Bogey bar width
rocker_bar_t = 8; // Bogey bar thickness
rocker_pivot_d = 8; // Rocker pivot shaft diameter
rocker_pivot_D = 12; // Rocker pivot shaft holder diameter
rocker_pivot_l = rocker_bar_t*2; // Rocker pivot shaft length
rocker_zero_x = track_w/2 - wheel_w/2 - wheel_flange_c - rocker_pivot_l;
rocker_bar1_l = sqrt(pow(bogey_h-rocker_h, 2) + pow(bogey_pivot, 2));
rocker_bar2_l = sqrt(pow(rocker_h, 2) + pow(wheel3, 2));
rocker_pivot_tooth_h = 3; // Rocker pivot connection tooth height
rocker_pivot_tooth_n = 5; // Rocker pivot connection number of teeth
rocker_pivot_bolt_d = 3;
rocker_pivot_bolt_l = 14;
rocker_truss_t = 2;

frame_rocker_c = 2; // Frame-rocker clearance
/* Frame width is derived from track width and drivetrain parameters */
frame_w = track_w - wheel_w - 2*wheel_flange_c - 2*rocker_pivot_l - 2*frame_rocker_c;
frame_bolt_pattern_d = 25; // Frame bolt pattern diameter
frame_bolt_plate_d = 30; // Frame bolt plate diameter
frame_bolt_n = 3; // Number of frame bolts per side
frame_bolt_d = 3; // Diameter of frame bolts
frame_h = 20; // Height of frame bottom (from wheel axis level)
frame_t = 2; // Frame wall thickness

diff_offset = 50; // Diff bar pivot to rocker pivot distance
diff_bar_t = 2; // Diff bar thickness
diff_bar_w = 8; // Diff bar width
diff_bar_c = 2; // Diff bar clearance from frame
diff_bar_bolt_d = 3; // Diff bar bolt diameter
diff_bar_end_d = 4; // Diff bar end connection bar diameter


diff_lever_w = 8; // Diff lever width
diff_lever_t = 3; // Diff lever thickness

diff_rod_t = 4; // Diff rod thickness

/* Calculated parameters */
diff_lever_l = 20; // Diff lever (attached to rocker arm, driving the diff rod) length
diff_bar_l = 50; // Diff bar length

echo("Frame width: ", frame_w);

use_truss = false;

$fn=32;

module rocker_washer() {
  difference() {
    union() {
      translate([frame_w/2+frame_rocker_c+rocker_pivot_l, 0, rocker_h-frame_h]) rotate([0, 90, 0])
        cylinder(d=rocker_pivot_D, h=frame_t);
    }
    translate([frame_w/2+frame_rocker_c+rocker_pivot_l-rocker_pivot_bolt_l, 
               0, rocker_h-frame_h]) rotate([0, 90, 0])
      cylinder(d=rocker_pivot_bolt_d+fit*2, h=rocker_pivot_bolt_l+frame_t+1);
  }  
}

module bogey_washer() {
  difference() {
    union() {
      translate([frame_w/2+frame_rocker_c+rocker_pivot_l, 
                 bogey_pivot, bogey_h-frame_h]) rotate([0, 90, 0])
        cylinder(d=bogey_pivot_D, h=frame_t);
    }
    translate([frame_w/2+frame_rocker_c+rocker_pivot_l-bogey_pivot_bolt_l, 
               bogey_pivot, bogey_h-frame_h]) rotate([0, 90, 0])
      cylinder(d=bogey_pivot_bolt_d+fit*2, h=bogey_pivot_bolt_l+frame_t+1);
  }  
}

/* Mounting plate for the rocker arm. Same coordinates as the frame. */
module frame_plate() {
  difference() {
    union() {
      translate([frame_w/2-frame_t, 0, rocker_h-frame_h]) rotate([0, 90, 0])
        cylinder(d=frame_bolt_plate_d, h=frame_t+frame_rocker_c);
      translate([frame_w/2, 0, rocker_h-frame_h]) rotate([0, 90, 0])
        cylinder(d=rocker_pivot_d, h=frame_rocker_c+rocker_pivot_l);
    }
    translate([frame_w/2+frame_rocker_c+rocker_pivot_l-rocker_pivot_bolt_l, 
               0, rocker_h-frame_h]) rotate([0, 90, 0])
      cylinder(d=rocker_pivot_bolt_d, h=rocker_pivot_bolt_l+1);
  }
}

/* Frame module for connecting the drivetrain and the payload.
   X, Y zero are the global origin, Z zero is the bottom of the frame. */
module frame() {
  difference() {
    union() {
      translate([-frame_w/2, -frame_bolt_plate_d/2, 0])
        cube([frame_w, frame_bolt_plate_d, rocker_h-frame_h]);
      frame_plate();
      mirror([1, 0, 0]) frame_plate();
      translate([-diff_bar_w/2, -diff_offset, 0])
        cube([diff_bar_w, diff_offset, frame_t]);
      translate([0, -diff_offset, 0])
        cylinder(d=diff_bar_w, h=frame_t);      
    }
    translate([-frame_w/2+frame_t, -frame_bolt_plate_d/2-1, frame_t])
      cube([frame_w-frame_t*2, frame_bolt_plate_d+2, rocker_h-frame_h-frame_t+1]);
    translate([0, -diff_offset, -1])
      cylinder(d=diff_bar_bolt_d, h=frame_t+2);
  }
}

/* Rocker module. Zero point is the rocker pivot, base of the shaft.
   Rocker has the shaft holder, the frame the pivot shaft. */
module rocker() {
  rocker_arm1();
  rocker_arm2();    
}

/* Rocker bogey arm */
module rocker_arm1() {
  rotate([0, 90, 0]) {
    difference() {
      union() {
        cylinder(d=rocker_pivot_D, h=rocker_pivot_l/2+rocker_pivot_tooth_h/2);
      rotate([0, 0, atan2(bogey_h-rocker_h, bogey_pivot)])
        translate([-rocker_bar_w/2, 0, 0])
          if (use_truss) {
            pyramid_box_truss(rocker_bar_w, rocker_bar1_l, rocker_bar_t,
                      1, 3, 2,
                      rocker_truss_t, rocker_truss_t, rocker_truss_t, 
                      rocker_truss_t, rocker_truss_t,
                      true, true, $16);
          } else {
            cube([rocker_bar_w, rocker_bar1_l, rocker_bar_t]);
          }
      translate([rocker_h-bogey_h, bogey_pivot, 0])
        cylinder(d=bogey_pivot_D, h=rocker_bar_t);
      translate([rocker_h-bogey_h, bogey_pivot, rocker_pivot_l-bogey_pivot_l])
        cylinder(d=bogey_pivot_d, h=bogey_pivot_l);
      }
      translate([0, 0, -0.05]) cylinder(d=rocker_pivot_d+fit*2, h=rocker_pivot_l+0.1);
      translate([0, 0, rocker_pivot_l/2-rocker_pivot_tooth_h/2])
        toothed_cylinder(d=rocker_pivot_D+tol, h=rocker_pivot_tooth_h,
                          n=rocker_pivot_tooth_n, t_h=rocker_pivot_tooth_h, tol=tol); 
      translate([rocker_h-bogey_h, bogey_pivot, rocker_pivot_l-bogey_pivot_bolt_l])
        cylinder(d=bogey_pivot_bolt_d, h=bogey_pivot_bolt_l+1);
    }
  }
}

/* Rocker single wheel arm */
module rocker_arm2() {
  rotate([0, 90, 0]) {
    difference() {
      union() {
        translate([0, 0, rocker_pivot_l/2-rocker_pivot_tooth_h/2])
          cylinder(d=rocker_pivot_D, h=rocker_pivot_l/2+rocker_pivot_tooth_h/2);
        translate([rocker_h, wheel3, rocker_pivot_l - wheel_flange_t])
          wheel_flange();
       rotate([0, 0, atan2(-rocker_h, wheel3)])
        translate([-rocker_bar_w/2, 0, rocker_pivot_l-rocker_bar_t])
          if (use_truss) {
            pyramid_box_truss(rocker_bar_w, rocker_bar2_l+wheel_flange_d/4, rocker_bar_t,
                      1, 3, 2,
                      rocker_truss_t, rocker_truss_t, rocker_truss_t, 
                      rocker_truss_t, rocker_truss_t,
                      true, true, $16);
          } else {
            cube([rocker_bar_w, rocker_bar2_l+wheel_flange_d/4, rocker_bar_t]);
          }
      }
      translate([0, 0, -0.05]) cylinder(d=rocker_pivot_d+fit*2, h=rocker_pivot_l+0.1);
      translate([0, 0, rocker_pivot_l/2-rocker_pivot_tooth_h/2])
        rotate([0, 0, 360/rocker_pivot_tooth_n/2])
          toothed_cylinder(d=rocker_pivot_D+tol, h=rocker_pivot_tooth_h,
                            n=rocker_pivot_tooth_n, t_h=rocker_pivot_tooth_h, tol=tol);
    }
  }
}

/* Diff bar. Zero point is the pivot axis, lowest Z position */
module diff_bar() {
  difference() {
    union() {
      translate([-diff_bar_l/2, -diff_bar_w/2, 0])
        cube([diff_bar_l, diff_bar_w, diff_bar_t]);
      cylinder(d=diff_bar_w, h=diff_bar_t+diff_bar_c);
      translate([diff_bar_l/2, 0, 0])
        cylinder(d=diff_bar_w, h=diff_bar_t);
      translate([-diff_bar_l/2, 0, 0])
        cylinder(d=diff_bar_w, h=diff_bar_t);
    }
    translate([0, 0, -1])
      cylinder(d=diff_bar_bolt_d, h=diff_bar_t+diff_bar_c+2);
    translate([diff_bar_l/2, 0, -1])
      cylinder(d=diff_bar_end_d+fit*2, h=diff_bar_t+2);
    translate([-diff_bar_l/2, 0, -1])
      cylinder(d=diff_bar_end_d+fit*2, h=diff_bar_t+2);
    translate([diff_bar_l/2, -(diff_bar_end_d-fit*2)/2, -1])
      cube([diff_bar_w, diff_bar_end_d-fit*2, diff_bar_t+2]);
  }
}

/* Diff rod (connects diff bar to rocker arm). Origin is the center of pivot in the diff bar. */
module diff_rod() {
  difference() {
    union() {
  
    }
  } 
}

/* Bogey module. Zero point is the bogey pivot, base of the shaft.
   Bogey has the shaft holder, the rocker the pivot shaft. */
module bogey() {
  rotate([0, 90, 0]) {
    difference() {
      union() {
        cylinder(d=bogey_pivot_D, h=bogey_pivot_l);
        translate([bogey_h, wheel1-bogey_pivot, bogey_pivot_l - wheel_flange_t])
          wheel_flange();
        translate([bogey_h, wheel2-bogey_pivot, bogey_pivot_l - wheel_flange_t])
          wheel_flange();
      rotate([0, 0, atan2(-bogey_h, wheel1-bogey_pivot)])
        translate([-bogey_bar_w/2, 0, 0])
          if (use_truss) {
            pyramid_box_truss(bogey_bar_w, bogey_bar1_l+wheel_flange_d/4, bogey_bar_t,
                      1, 3, 2,
                      bogey_truss_t, bogey_truss_t, bogey_truss_t, 
                      bogey_truss_t, bogey_truss_t,
                      true, true, $16);
          } else {
            cube([bogey_bar_w, bogey_bar1_l+wheel_flange_d/4, bogey_bar_t]);
          }
      rotate([0, 0, atan2(-bogey_h, wheel2-bogey_pivot)])
        translate([-bogey_bar_w/2, 0, 0])
         if (use_truss) {
            pyramid_box_truss(bogey_bar_w, bogey_bar2_l+wheel_flange_d/4, bogey_bar_t,
                      1, 3, 2,
                      bogey_truss_t, bogey_truss_t, bogey_truss_t, 
                      bogey_truss_t, bogey_truss_t,
                      true, true, $16);
         } else {
           cube([bogey_bar_w, bogey_bar2_l+wheel_flange_d/4, bogey_bar_t]);
         }
      }
      translate([0, 0, -0.05]) cylinder(d=bogey_pivot_d+fit*2, h=bogey_pivot_l+0.1);
    }
  }
}

/* Wheel flange. Zero point is the wheel axis, base of flange (near vehicle) */
module wheel_flange() {
  difference() {
    cylinder(d=wheel_flange_d, h=wheel_flange_t);
  }    
}

module wheel(mockup=true) {
  if (mockup) {
    color("lightgrey")
    rotate([0, 90, 0])
      translate([0, 0, -wheel_w/2])
        cylinder(d=wheel_d, h=wheel_w);
  } else {
    rotate([0, 90, 0])
      translate([0, 0, -wheel_w/2])
        cylinder(d=wheel_d, h=wheel_w);  
  }
}

module toothed_cylinder(d, h, n, t_h, tol) {
  tol_angle = 360 / ((PI*d) / tol);
//  echo("Tol angle:", tol_angle);
  difference() {
    cylinder(d=d, h=h);
    translate([0, 0, h-t_h])
      for (i = [0:n]) {
        rotate([0, 0, 360/n*i])
        difference() {
          cube([d, d, t_h+1]);
          rotate([0, 0, 360/n/2-tol_angle*2])
            cube([d, d, t_h+2]);
        }
      }
  }  
}

//toothed_cylinder(20, 20, 4, 20, 0.5);

module assembly() {
  translate([-track_w/2, wheel1, 0]) wheel();
  translate([-track_w/2, wheel2, 0]) wheel();
  translate([-track_w/2, wheel3, 0]) wheel();
  translate([track_w/2, wheel1, 0]) wheel();
  translate([track_w/2, wheel2, 0]) wheel();
  translate([track_w/2, wheel3, 0]) wheel(mockup=false);
  translate([bogey_zero_x, bogey_pivot, bogey_h]) bogey();
  translate([rocker_zero_x, 0, rocker_h]) rocker();
  translate([0, 0, frame_h]) frame();
  translate([0, 0, frame_h]) rocker_washer();
  translate([0, 0, frame_h]) bogey_washer();
  translate([0, -diff_offset, frame_h-diff_bar_c-diff_bar_t]) diff_bar();
  translate([diff_bar_l/2, -diff_offset, frame_h-diff_bar_c-diff_bar_t]) diff_rod();
}

assembly();
//rotate([0, -90, 0]) rocker_arm1();
//rotate([0, 90, 0]) rocker_arm2();
//rotate([0, 90, 0]) bogey();
//rotate([0, 90, 0]) bogey_washer();