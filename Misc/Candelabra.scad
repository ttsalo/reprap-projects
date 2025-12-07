// Candelabra by Tomi T. Salo 2025

candle_h = 18;
candle_d = 40;
holder_wt = 3;
holder_base_d = 12;
holder_base_h = ((candle_d + holder_wt) - holder_base_d) / 1.5;

base_t = 3;

mini_base_arm_1_w = 6;
mini_base_arm_1_l = 30;
mini_base_arm_2_w = 6;
mini_base_arm_2_l = 15;

base_arm_1_w = 10;
base_arm_1_l = 50;
base_arm_2_w = 6;
base_arm_2_l = 25;

module holder() {
  cylinder(d1=holder_base_d, d2=candle_d+holder_wt*2, h=holder_base_h, $fn=64);
  translate([0, 0, holder_base_h])
    difference() {
      cylinder(d=candle_d+holder_wt*2, h=candle_h, $fn=64);
      cylinder(d=candle_d, h=candle_h+1, $fn=64);
    
    }    
}

module mini_base_arm_2() {
    translate([-mini_base_arm_2_w/2, 0, 0])
      cube([mini_base_arm_2_w, mini_base_arm_2_l, base_t]);
    translate([0, mini_base_arm_2_l, 0])
      cylinder(d=mini_base_arm_2_w, h=base_t);
}

module mini_base_arm_1() {
    translate([-mini_base_arm_1_w/2, 0, 0])
      cube([mini_base_arm_1_w, mini_base_arm_1_l, base_t]);
    translate([0, mini_base_arm_1_l, 0])
      cylinder(d=mini_base_arm_1_w, h=base_t);
    for (i = [-60, 0, 60])
      translate([0, mini_base_arm_1_l, 0])
        rotate([0, 0, i])
          mini_base_arm_2();
}

module mini_base() {
  for (i = [0, 60, 120, 180, 240, 300])
    rotate([0, 0, i])
      mini_base_arm_1();
}

/* Base layout definition is a structure of nested lists that are drawn in order
   Key "s" defines a straight segment, with elements:
    1: length
    2: width at start
    3: width at end
    4: the rest of the layout after the segment (if any)
   Key "b4" defines a branch identical in four directions while continuing the 
   main arm.
    1: Branch arms
    2: Main arm continuation
   Key "b3" defines a branch identical in three directions
    1: Branch arms
   Key "b2" defines a branch identical in two directions while continuing the 
   main arm.
    1: Branch arms
    2: Main arm continuation

*/
base_layout = [
  "s", 25, 10, 5, 
  ["b4", 
    ["s", 10, 5, 0.1, ],
    ["s", 14, 5, 5, 
      ["b2", 
        ["s", 15, 5, 3,
          ["b3", 
            ["s", 10, 3, 0.1, ]]],
        ["s", 30, 5, 3, 
          ["b3", 
            ["s", 20, 3, 2, 
              ["b4", 
                ["s", 8, 3, 0.1, ],
                ["s", 8, 3, 0.1, ]
              ]
    ]]]]]
  ]
];

module base_arm(lout) {
  //echo(str(["Drawing: ", lout]));
  if (lout[0] == "s") {
    hull() {
      circle(d=lout[2], $fn=6);
      translate([lout[1], 0]) {
        circle(d=lout[3], $fn=6);
      }
    }
    translate([lout[1], 0])
      base_arm(lout[4]);
  }
  if (lout[0] == "b4") {
    for (i = [-120, -60, 60, 120]) {
      rotate(i) base_arm(lout[1]);
    }
    base_arm(lout[2]);
  } 
  if (lout[0] == "b3") {
    for (i = [-60, 0, 60]) {
      rotate(i) base_arm(lout[1]);
    }
  } 
  if (lout[0] == "b2") {
    for (i = [-60, 60]) {
      rotate(i) base_arm(lout[1]);
    }
    base_arm(lout[2]);
  } 
}

/* Snowflake base, six symmetrical arms defined by the base_layout structure. */
module base() {
  rotate([0, 0, 0])
    cylinder(d1=30, d2=0, h=30, $fn=6);
  linear_extrude(height=base_t) {
    for (i = [0, 60, 120, 180, 240, 300])
      rotate([0, 0, i])
        base_arm(base_layout);
  }
}

/* Layout definition is a structure of nested lists that are drawn in order
   Key "b" defines a branch point where the layout branches into sublists.
   Key "h" defines a candle holder (terminal point)
   Key "s" defines a straight segment, with elements:
    1: length
    2: the rest of the layout after the segment
   Key "d" defines a displacement, with elements:
    1: length
    2: displacement
    3: rotation
    4: the rest of the layout after the displacement
*/
midi_layout = [
  "b", [
    ["s", 20, 
      ["d", 40, 30, 0, ["h"]]],
    ["s", 10,
      ["d", 50, 30, 120, ["h"]]],
    ["d", 60, 30, 240, ["h"]],
  ]
];

maxi_layout = [
  "b", [
    ["d", 140, 60, 0, ["h"]],
    ["d", 150, 70, 120, ["h"]],
    ["d", 160, 70, 240, ["h"]],
    ["d", 75, 30, 60,
      ["d", 80, 30, 180,
        ["h"]]],
    ["d", 75, 40, -30,
      ["b", [
        ["d", 78, 70, 120, ["h"]],
        ["d", 65, 40, -80, ["h"]],
    ]]],
    ["d", 50, 30, 180,
      ["d", 50, 20, 180,
        ["d", 55, 45, 180, ["h"]]]],
  ]
];

module candelabra(layout) {
  if (layout[0] == "s") {
    cylinder(d=holder_base_d, h=layout[1], $fn=24);
    translate([0, 0, layout[1]])
      candelabra(layout[2]);
  }
  if (layout[0] == "d") {
    rotate([0, 0, layout[3]]) {
      pipe_displace(l=layout[1], d=layout[2], half=true);
      translate([layout[2], 0, layout[1]])
        candelabra(layout[4]);
    }
  }
  if (layout[0] == "h") {
    holder();
  }
  if (layout[0] == "b") {
    for (l = layout[1]) {
      candelabra(l);
    }
  }
}

module candelabra_mini() {
  mini_base();
  holder();
}

//candelabra_mini();

module candelabra_midi() {
  mini_base();
  candelabra(midi_layout);
}

//candelabra_midi();

module candelabra_maxi() {
  base();
  candelabra(maxi_layout);
}

candelabra_maxi();

// Some utility modules from a different project, these have some extra
// functionality not used here.

r = holder_base_d/2;
r_tol = 0;
r_t = 0;

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
  //echo(str(["Chord_a: ", chord_a]));
  //echo(str(["Chord: ", chord, " Angle: ", angle, " Curve_r: ", curve_r]));
  rotate([0, -90, -90])
  mirror([0, (d<0) ? 1 : 0, 0]) {
    pipe_double_curve(curve_r, angle, void=void);
    if (!half)      
         translate([l/2, abs(d), 0]) mirror([0, 1, 0]) pipe_double_curve(curve_r, angle, void=void);
  }
}
