// Vortex Separator by Tomi T. Salo <ttsalo@iki.fi> 2016-2017

/* First iteration feedback:
   * Some fluid droplets scatter on the gas exit pipe walls and get driven up and out by
     the gas flow. Otherwise works OK.
   Changes to do:
   * Change the geometry. Longer conical section, exit pipe inlet further up from the
     fluid exit.
   * Put a screw thread in the exit pipe. This should both impede the fluid flowing up the
     pipe walls and allow screwing in an additional baffle section if needed.

*/

use <../includes/Thread_Library.scad>;

module roundedCylinder(r, h, rr, $fn) {
  cylinder(r=r-rr, h=h, $fn=$fn);
  translate([0, 0, rr]) cylinder(r=r, h=h-2*rr, $fn=$fn);
  translate([0, 0, rr])
    rotate_extrude(convexity=10, $fn=$fn)
      translate([r-rr, 0, 0]) 
        circle(r=rr, $fn=16);
  translate([0, 0, h-rr])
    rotate_extrude(convexity=10, $fn=$fn)
      translate([r-rr, 0, 0]) 
        circle(r=rr, $fn=16);
}

module container(r, h, bt, wt, tl, p, rr, fn) {
  echo(str("Container volume: ", (r-wt)*(r-wt)*3.14*(h-bt), " mm^3"));
  echo(str("Container volume: ", (r-wt)*(r-wt)*3.14*(h-bt)/100000, " dl"));
  difference() {
    union() {
      roundedCylinder(r=r, h=h, rr=rr, $fn=fn);
  translate([0, 0, h-tl])  
  trapezoidThread(
	length=tl,				// axial length of the threaded rod
	pitch=p,				// axial distance from crest to crest
	pitchRadius=r+p/2,			// radial distance from center to mid-profile
	threadHeightToPitch=0.5,	// ratio between the height of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	profileRatio=0.5,			// ratio between the lengths of the raised part of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	threadAngle=29,			// angle between the two faces of the thread
						// std value for Acme is 29 or for metric lead screw is 30
	RH=true,				// true/false the thread winds clockwise looking along shaft, i.e.follows the Right Hand Rule
	clearance=0.0,		// radial clearance, normalized to thread height
	backlash=0.0,			// axial clearance, normalized to pitch
	stepsPerTurn=fn			// number of slices to create per turn
  );
    }
    translate([0, 0, bt])
      roundedCylinder(r=r-wt, h=h-bt+1, rr=rr, $fn=fn);
  }
}


/* r = radius (outer)
   h = height (outer)
   wt = wall thickness
   bt = bottom thickness
   tl = thread length
   p = thread pitch
   rr = rounding radius */

module lid(r, bt, wt, tl, p, rr) {
  translate([0, 0, tl]) cylinder(r=r+p+wt-rr, h=bt, $fn=90);
  difference() {
    roundedCylinder(r=r+p+wt, h=bt+tl, rr=rr, $fn=90);
    trapezoidThreadNegativeSpace(
	length=tl,				// axial length of the threaded rod
	pitch=p,				// axial distance from crest to crest
	pitchRadius=r+p/2,			// radial distance from center to mid-profile
	threadHeightToPitch=0.5,	// ratio between the height of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	profileRatio=0.5,			// ratio between the lengths of the raised part of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	threadAngle=29,			// angle between the two faces of the thread
						// std value for Acme is 29 or for metric lead screw is 30
	RH=true,				// true/false the thread winds clockwise looking along shaft, i.e.follows the Right Hand Rule
	clearance=0.0,			// radial clearance, normalized to thread height
	backlash=0.0,			// axial clearance, normalized to pitch
	stepsPerTurn=60			// number of slices to create per turn
  );
  }
}


module input_thread() {
    trapezoidThreadNegativeSpace(
	length=input_tl,				// axial length of the threaded rod
	pitch=1.337,				// axial distance from crest to crest
	pitchRadius=(13.157+11.445)/4,			// radial distance from center to mid-profile
	threadHeightToPitch=(13.157-11.445)/2/1.337,	// ratio between the height of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	profileRatio=0.5,			// ratio between the lengths of the raised part of the profile and the pitch
						// std value for Acme or metric lead screw is 0.5
	threadAngle=29,			// angle between the two faces of the thread
						// std value for Acme is 29 or for metric lead screw is 30
	RH=true,				// true/false the thread winds clockwise looking along shaft, i.e.follows the Right Hand Rule
	clearance=0.15,			// radial clearance, normalized to thread height
	backlash=0.1,			// axial clearance, normalized to pitch
	stepsPerTurn=60			// number of slices to create per turn
  );
}

tol = 0.25;
cone_offset = 10;
cone_r1 = 10;
cone_r2 = 30;
cone_h = 25;
wt = 5;
cyl_h = 60;
inner_cyl_r = 10;
input_r = 12/2;
input_l = 35;
input_tl = 15;

module vesitys() {
  difference() {
    union () {
      lid(r=(25.07/2)-0.4, bt=7, wt=4, tl=10, p=3.18, rr=1);
      translate([0, 0, cone_offset])
        cylinder(r1=cone_r1+wt, r2=cone_r2+wt, h=cone_h, $fn=60);
      translate([0, 0, cone_offset+cone_h])
        cylinder(r=cone_r2+wt, h=cyl_h, $fn=60);
      translate([0, cone_r2-input_r, cone_offset+cone_h+cyl_h-input_r-wt])
        rotate([0, -90, 0])
          translate([-input_r-wt, -input_r-wt, 0])
            cube([input_r*2+wt*2, input_r*2+wt*2, input_l]);
    }
    cylinder(r=cone_r1, h=cone_offset+cone_h+cyl_h+1);
    translate([0, 0, cone_offset])
      cylinder(r1=cone_r1, r2=cone_r2, h=cone_h, $fn=60);
    translate([0, 0, cone_offset+cone_h])
      cylinder(r=cone_r2, h=cyl_h-wt, $fn=60);
    translate([0, cone_r2-input_r, cone_offset+cone_h+cyl_h-input_r-wt])
      rotate([0, -90, 0])
         union() {
           cylinder(r=input_r, h=input_l);
           translate([0, 0, input_l-input_tl])
             input_thread();
         }
  }
  // Inner cylinder
  difference() {
    union() {
      translate([0, 0, cone_offset+cone_h])
        cylinder(r=inner_cyl_r+wt, h=cyl_h, $fn=60);
    }
    translate([0, 0, cone_offset+cone_h])
      cylinder(r=inner_cyl_r, h=cyl_h, $fn=60);
  }
}

//input_thread();
intersection() {
  rotate([0, 180, 0])
    vesitys();
//  translate([0, 0, -100])
//  cube([50, 50, 30]);
}
//cylinder(r=25.07/2, h=5);
