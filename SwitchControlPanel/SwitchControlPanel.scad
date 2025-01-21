t = 3;
w = 360;
h = 150;

grid_x = 20;
grid_y = 20;

n_x = 16;
n_y = 5;

grid_w = (n_x - 1) * grid_x;
grid_h = (n_y - 1) * grid_y;

grid_orig_x = (w - grid_w) / 2;
grid_orig_y = 20; //(h - grid_h) / 2;

hole_d = 7;

n_bolts = 4;
bolt_d = 5.5;
bolt_grid = 100;
bolt_grid_w = (n_bolts - 1) * bolt_grid;
bolt_grid_orig_x = (w - bolt_grid_w) / 2;
bolt_grid_orig_y = 135;

module panel() {
  difference() {
    cube([w, h, t]);
    for (i = [0 : n_x - 1])
      for (j = [0 : n_y - 1])
        translate([grid_orig_x + i * grid_x, grid_orig_y + j * grid_y, -1])
          cylinder(h=t+2, d=hole_d, $fn=16);
    for (i = [0 : n_bolts - 1])
        translate([bolt_grid_orig_x + i * bolt_grid, bolt_grid_orig_y, -1])
          cylinder(h=t+2, d=bolt_d, $fn=16);    
  } 
}

//difference() {
//panel();
//translate([w/2, 0, 0])
//cube([w/2, h, t]);
//}

// Switch positions and types.
// Types:
// 0: normal turnout
// 1: decoupler
// 2: isolated section
// 3: end of track (no switch)
switches = [
  [6, 0, 0],
  [7, 1, 0],
  [8, 1, 0],
  [9, 1, 1],
  [10, 1, 1],
  [9, 2, 0],
  [10, 2, 1],
  [12, 2, 0],
  [10, 3, 0],
  [11, 3, 1],
  [12, 4, 2],
  [11, 0, 0],
  [13, 1, 1],
  [13, 2, 3],
  [13, 3, 3],
  [13, 4, 3],
  [15, 0, 0],
  [2, 2, 1],
  [2, 3, 1],
  [1, 2, 3],
  [1, 3, 3],
  [4, 3, 0],
  [5, 4, 0],
  [6, 4, 0],
  [8, 3, 1],
  [8, 4, 1],
  [9, 3, 3],
  [9, 4, 3]
];

// Horizontal straight track positions, third element is length
h_tracks = [
  [-0.5, 0, 16],
  [1, 1, 10],
  [9, 2, 4],
  [10, 3, 3],
  [11, 4, 2],
  [1, 4, 8],
  [1, 3, 3],
  [1, 2, 2],
  [7, 3, 2],
  [12, 1, 2],
];

// Diagonal track positions, third element indicates up or down
diag_tracks = [
  [6, 0, true],
  [8, 1, true],
  [9, 2, true],
  [10, 3, true],
  [11, 1, true],
  [11, 0, true],
  [14, 1, false],
  [3, 2, true],
  [4, 3, true],
  [6, 4, false]
];

// Semicircles, center position x and y, diameter, side
semicircles = [
  [1, 2.5, 3, 0]
];

diagram_t = 1.5;
switch_d = 12;
track_w = 5;
decoupler_w = 4; // decoupler symbol width
decoupler_l = 20; // decoupler symbol length
isolator_w = 4; // isolator symbol width
isolator_l = 18; // isolator symbol length
eot_w = 4; // end of track symbol width
eot_l = 12; // end of track symbol length

module diagram() {
  translate([grid_orig_x, grid_orig_y, t]) {
    difference() {
      union() {
        for (sw = switches)
          translate([sw[0]*grid_x, sw[1]*grid_y, 0])
            union() {
              if (sw[2] != 3)
                cylinder(h=diagram_t, d=switch_d, $fn=16);
              if (sw[2] == 1) {
                for (i = [-45, 45])
                  rotate([0, 0, i])
                    translate([-decoupler_l/2, -decoupler_w/2, 0])
                      cube([decoupler_l, decoupler_w, diagram_t]);  
              }
              if (sw[2] == 2) {
                translate([-isolator_w/2, -isolator_l/2, 0])
                  cube([isolator_w, isolator_l, diagram_t]);  
              }
              if (sw[2] == 3) {
                translate([-eot_w/2, -eot_l/2, 0])
                  cube([eot_w, eot_l, diagram_t]);  
              }
            }
        for (tr = h_tracks)
          translate([tr[0]*grid_x, tr[1]*grid_y, 0])
            union() {
              translate([0, -track_w/2, 0])
                cube([grid_x*tr[2], track_w, diagram_t]);
              cylinder(h=diagram_t, d=track_w, $fn=16);
            }
        for (tr = diag_tracks)
          translate([tr[0]*grid_x, tr[1]*grid_y, 0])
            union() {
              rotate([0, 0, tr[2] ? 45 : -45])
                translate([0, -track_w/2, 0])
                  cube([grid_x*sqrt(2), track_w, diagram_t]);
              cylinder(h=diagram_t, d=track_w, $fn=16);
            }
         for (sc = semicircles)
           translate([sc[0]*grid_x, sc[1]*grid_y, 0])
             difference() {
               cylinder(h=diagram_t, d=sc[2]*grid_x+track_w, $fn=64);
               translate([0, 0, -1])
                 cylinder(h=diagram_t+2, d=sc[2]*grid_x-track_w, $fn=64);
               translate([-(sc[2]*grid_x+track_w)*sc[3], -(sc[2]*grid_x+track_w)/2, -1])
               cube([sc[2]*grid_x+track_w, sc[2]*grid_x+track_w, diagram_t+2]);
             }
      }
      for (sw = switches)
        if (sw[2] != 3)
          translate([sw[0]*grid_x, sw[1]*grid_y, -1])
            cylinder(h=diagram_t+2, d=hole_d, $fn=16);
    }
  }
}

color("darkgray")
diagram();
