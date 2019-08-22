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
bogey_bar_t = 10; // Bogey bar thickness
bogey_pivot_d = 8; // Bogey pivot shaft diameter
bogey_pivot_D = 12; // Bogey pivot shaft holder diameter
bogey_pivot_l = 10; // Bogey pivot shaft length
bogey_zero_x = track_w/2 - wheel_w/2 - wheel_flange_c - bogey_pivot_l;
bogey_bar1_l = sqrt(pow(bogey_h, 2) + pow(wheel1-bogey_pivot, 2));
bogey_bar2_l = sqrt(pow(bogey_h, 2) + pow(wheel2-bogey_pivot, 2));

rocker_bar_w = 12; // Bogey bar width
rocker_bar_t = 10; // Bogey bar thickness
rocker_pivot_d = 8; // Rocker pivot shaft diameter
rocker_pivot_D = 12; // Rocker pivot shaft holder diameter
rocker_pivot_l = 20; // Rocker pivot shaft length
rocker_zero_x = track_w/2 - wheel_w/2 - wheel_flange_c - rocker_pivot_l;
rocker_bar1_l = sqrt(pow(bogey_h-rocker_h, 2) + pow(bogey_pivot, 2));
rocker_bar2_l = sqrt(pow(rocker_h, 2) + pow(wheel3, 2));
rocker_pivot_tooth_h = 3; // Rocker pivot connection tooth height
rocker_pivot_tooth_n = 5; // Rocker pivot connection number of teeth

$fn=32;

module toothed_cylinder(d, h, n, t_h, tol) {
  tol_angle = 360 / ((PI*d) / tol);
  echo("Tol:", tol);
  echo("Tol angle:", tol_angle);
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
          cube([rocker_bar_w, rocker_bar1_l, rocker_bar_t]);
      translate([rocker_h-bogey_h, bogey_pivot, 0])
        cylinder(d=bogey_pivot_D, h=rocker_bar_t);
      translate([rocker_h-bogey_h, bogey_pivot, rocker_pivot_l-bogey_pivot_l])
        cylinder(d=bogey_pivot_d, h=bogey_pivot_l);
      }
      translate([0, 0, -0.05]) cylinder(d=rocker_pivot_d+fit*2, h=rocker_pivot_l+0.1);
      translate([0, 0, rocker_pivot_l/2-rocker_pivot_tooth_h/2])
        toothed_cylinder(d=rocker_pivot_D+tol, h=rocker_pivot_tooth_h,
                          n=rocker_pivot_tooth_n, t_h=rocker_pivot_tooth_h, tol=tol); 
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
          cube([rocker_bar_w, rocker_bar2_l+wheel_flange_d/4, rocker_bar_t]);
      }
      translate([0, 0, -0.05]) cylinder(d=rocker_pivot_d+fit*2, h=rocker_pivot_l+0.1);
      translate([0, 0, rocker_pivot_l/2-rocker_pivot_tooth_h/2])
        rotate([0, 0, 360/rocker_pivot_tooth_n/2])
          toothed_cylinder(d=rocker_pivot_D+tol, h=rocker_pivot_tooth_h,
                            n=rocker_pivot_tooth_n, t_h=rocker_pivot_tooth_h, tol=tol);
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
          cube([bogey_bar_w, bogey_bar1_l+wheel_flange_d/4, bogey_bar_t]);
      rotate([0, 0, atan2(-bogey_h, wheel2-bogey_pivot)])
        translate([-bogey_bar_w/2, 0, 0])
          cube([bogey_bar_w, bogey_bar2_l+wheel_flange_d/4, bogey_bar_t]);
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

module wheel() {
  color("lightgrey")
  rotate([0, 90, 0])
    translate([0, 0, -wheel_w/2])
      cylinder(d=wheel_d, h=wheel_w);
}

module assembly() {
  translate([-track_w/2, wheel1, 0]) wheel();
  translate([-track_w/2, wheel2, 0]) wheel();
  translate([-track_w/2, wheel3, 0]) wheel();
  translate([track_w/2, wheel1, 0]) wheel();
  translate([track_w/2, wheel2, 0]) wheel();
  translate([track_w/2, wheel3, 0]) wheel();
  translate([bogey_zero_x, bogey_pivot, bogey_h]) bogey();
  translate([rocker_zero_x, 0, rocker_h]) rocker();
}

assembly();
//rocker_arm1();