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
bogey_bar_t = 8; // Bogey bar thickness
bogey_pivot_d = 6; // Bogey pivot shaft diameter
bogey_pivot_D = 10; // Bogey pivot shaft holder diameter
bogey_pivot_l = 8; // Bogey pivot shaft length
bogey_zero_x = track_w/2 - wheel_w/2 - wheel_flange_c - bogey_pivot_l;
bogey_bar1_l = sqrt(pow(bogey_h, 2) + pow(wheel1-bogey_pivot, 2));
bogey_bar2_l = sqrt(pow(bogey_h, 2) + pow(wheel2-bogey_pivot, 2));

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
          cube([bogey_bar_w, bogey_bar1_l, bogey_bar_t]);
      rotate([0, 0, atan2(-bogey_h, wheel2-bogey_pivot)])
        translate([-bogey_bar_w/2, 0, 0])
          cube([bogey_bar_w, bogey_bar2_l, bogey_bar_t]);
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
}

assembly();