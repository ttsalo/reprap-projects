tol = 0.4;

d1_1 = 21;
d1_2 = 22;
d2_1 = 19;
d2_2 = 18;
h1 = 31;
h2 = 55;
d_sp = 22;

module finger(fd1_1, fd1_2, fd2_1, fd2_2, fh1, fh2, fd_sp, void=false) {
  _t = void ? 0 : t;
  cylinder(d1=fd2_2 + _t, d2=fd2_1 + _t, h=fh2, $fn=24);
  translate([0, 0, fh2])
    sphere(d=fd_sp + _t, $fn=24);
  translate([0, 0, fh2])
    rotate([-90, 0, 0])
      cylinder(d1=fd1_1 + _t, d2=fd1_2 + _t, h=fh1, $fn=24);
}

module block(offset=0, tol=0) {
  intersection() {
    difference() {
      union() {
        translate([9, 12-offset-tol, 0]) // pikku
          cube([26, 23, 68]);
        translate([-14-tol, 0-offset-tol, 0]) // nimetön
          cube([26+tol*2, 23, 68]);
        translate([-36-tol, -7-offset-tol, 0]) // keski
          cube([26+tol*2, 23, 68]);
        translate([-59, 0-offset-tol, 0]) // etu
          cube([26, 23, 68]);
//      translate([-59, 12, 42])
//        cube([94, 23, 26]);
      }
      //voids();
    }
  //translate([0, -50, 0]) cube([100, 100, 100]);
  }
}

difference() {
//  block(offset=23);
//  block(offset=0, tol=tol);
}

//block(offset=0);

module fingers(void=false) {
  for (f=[0 : 3]) {
    p = fingers_pos[f];
    d = fingers_data[f];
    translate([p[0], p[1], 0]) {
      finger(d[0], d[1], d[2], d[3], d[4], d[5], d[6], void=void);
    }
  }
  translate([-45-(void ? 0 : t) , 23-(void ? 0 : t), 43-(void ? 0 : t)])
    cube([68+(void ? 0 : t*2), 10+(void ? 0 : t), 20+(void ? 0 : t*2)]);
}

t = 3;

fingers_pos = [[22, 14], [0, 0], [-23, -11], [-46, 0]];
fingers_data = [[20, 21, 18, 17, 19, 53, 23],
                [21, 22, 19, 18, 33, 53, 22],
                [23.5, 24.5, 21.5, 18.5, 44, 53, 25],
                [22.5, 23.5, 19.5, 16.5, 33, 53, 22]];

module fingers_set() {
  difference() {
    fingers();
    fingers(void=true);
  }
}

module pillory_lower() {
  intersection() {
    fingers_set();
    block(offset=23);
  }
}

module pillory_upper() {
  difference() {
    fingers_set();
    block(offset=23);
  }
}

pillory_upper();