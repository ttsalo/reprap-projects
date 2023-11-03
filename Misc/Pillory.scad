tol = 0.4;

d1_1 = 21;
d1_2 = 22;
d2_1 = 19;
d2_2 = 18;
h1 = 31;
h2 = 55;
d_sp = 22;

module finger_void(fd1_1, fd1_2, fd2_1, fd2_2, fh1, fh2, fd_sp) {
  cylinder(d1=fd2_2, d2=fd2_1, h=fh2, $fn=24);
  translate([0, 0, fh2])
    sphere(d=fd_sp, $fn=24);
  translate([0, 0, fh2])
    rotate([-90, 0, 0])
      cylinder(d1=fd1_1, d2=fd1_2, h=fh1, $fn=24);
}

module voids() {
   translate([22, 14, 2])
     finger_void(20, 21, 18, 17, 31, 53, 23);
   translate([0, 0, 2])
     finger_void(21, 22, 19, 18, 35, 53, 22);
   translate([-23, -11, 2])
     finger_void(23.5, 24.5, 21.5, 18.5, 35, 53, 25);
   translate([-46, 0, 2])  
     finger_void(22.5, 23.5, 19.5, 16.5, 31, 53, 22);
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
      voids();
    }
  //translate([0, -50, 0]) cube([100, 100, 100]);
  }
}

difference() {
//  block(offset=23);
  block(offset=0, tol=tol);
}

block(offset=0);