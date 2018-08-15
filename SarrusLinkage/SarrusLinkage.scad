/* Parametric Sarrus Linkage by Tomi T. Salo <ttsalo@iki.fi> */

/* 
  Design ideas:
  - Parametric (of course)
  - Parallelogram structure
  - Hinge
   - Let's at least try snap-on hinges in the same style that the rigid chain connectors use.

*/

// Parameters
t = 3; // Main material thickness, applied to many components
tol = 0.2; // Main tolerance to provide tight fit
h = 16; // Main constraint spacing
l = 50; // Element length
w = 40; // Element width
snap_opening = 120;
snap_tol = 0.4;
hinge_end_tol = 0.2;

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

/* Hinge element with two bars */
module hinge() {
    translate([0, -t/2, 0])
      rotate([-90, 0, 0])
        cylinder(r=t-snap_tol, h=w+t, $fn=24);
    translate([-h, -t/2, h])
      rotate([-90, 0, 0])
        cylinder(r=t-snap_tol, h=w+t, $fn=24);
    translate([-h-t, -t, -t*2])
      cube([h+t*2, t-hinge_end_tol, h+t*4]);
    translate([-h-t, w+hinge_end_tol, -t*2])
      cube([h+t*2, t-hinge_end_tol, h+t*4]);
}

/* Connecting element */
module element() {
    cube([l, w, t]);
    translate([0, 0, t*2])
      rotate([0, 90, 0])
        snap_in(t, t*2, snap_opening, w);
    translate([l, 0, t*2])
      rotate([0, 90, 0])
        snap_in(t, t*2, snap_opening, w);
}

module assembly() {
    translate([0, 0, -t*2])
      element();
    translate([-h, 0, -t*2+h])
      element();
    hinge();
     
}

assembly();

