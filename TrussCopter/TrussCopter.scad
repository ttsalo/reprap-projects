/* Truss Quad by Tomi T. Salo <ttsalo@iki.fi> 2014. */

/* 
   Quadcopter (or other multicopter) with larger truss frame than what the
   superlight design has.
*/

/* Testing 19.6.2015:
   A hard landing caused the following damage:
   - Some broken truss bars at the motor end of one arm 
   - The hinge counterparts in the frame side disintegrated for three arms
   - The hinge counterpart came off the bottom slat

   The arm truss bars are expected to break, not the frame parts, so this will need
   some reinforcement. The hinge cylinders split along layer boundaries through the screw
   hole, so this needs to be beefed up. 

   Ideas:
   - 
   */

use <PyramidSpaceTruss.scad>;

lh = 0.3;
tol = 0.2;  // tight tolerance
fit = 0.4;  // loose fit tolerance

batt_w = 45.5+fit;
batt_h = 17.7+fit;
batt_extend = 60;
batt_bulkhead_t = 0;// 1.0;

board_mount_t = 10;
board_mount_hole_d = 2.5;
board_mount_support_d = board_mount_hole_d + 4;
board_mount_l = 45;

/* *************************************************** */
/* ************* 9 inch quad ************************* */
/* *************************************************** */

/*
motor_center_l = 200;
prop_d = 9*25.4;
arms = 4;

slat_z_thickness = 3.6;
slat_xy_thickness = 3.6;
slat_k_thickness = 3.6;
bar_diameter = 3.6;
vert_thickness = 3.6;

frame_h = 35;
frame_w = 48;
frame_front = 103;
frame_back = 25;
frame_mid = frame_front - (frame_front + frame_back)/2;
gps_offset = 0;

length_sections = 3;
width_sections = 1;

arm_cp_slat_xy = 4;
arm_cp_slat_z = 2;
arm_cp_bar_d = 4.8;
arm_cp_top_bar_d = 5.6;

arm_slat_xy_1 = 4;
arm_slat_z_1 = 2;
arm_bar_d_1 = 3.6;
arm_top_bar_d_1 = 4.8;

arm_slat_xy_2 = 2.4;
arm_slat_z_2 = 2;
arm_bar_d_2 = 2.4;
arm_top_bar_d_2 = 3.6;

//Arm definitions:
//  [ length, offset, rotation ]
arm_table = [
  [ 127, [ 45, 85, frame_h], [ 180, 0, 30], 5 ],
  [ 159, [ 40, -40, frame_h], [ 180, 0, -45 ], 6 ]
];

arm_cp_x_offset = 3;
arm_cp_h_less = 2;

arm_motor_setback = 15;
frame_hinge_lock_d = 12;
frame_hinge_lock_hole_d = 3;
frame_hinge_lock_t = 4;
frame_hinge_lock_l = 40;
arm_hinge_lock_d = 12;
arm_hinge_lock_hole_d = 3;
arm_hinge_lock_t = 8;

n_motor_mount_hole = 4;
motor_mount_hole_d = 3;
motor_mount_hole_dist = 16;
motor_mount_hole_supp_t = 11;
motor_mount_hole_supp_d = motor_mount_hole_d + 2*2.1;

arm_hinge_d = 10;
arm_hinge_hole_d = 3;
arm_hinge_l = 22;
arm_start_w = 20;
arm_end_w = 30;
arm_end_h = 18;

frame_hinge_d = 10;
frame_hinge_l = 46;

arm_cp_table = [
  [ 42, frame_hinge_l, [-25, -5, 0], [-8, -7, 0], [-10, 0, 0], [-15, 0, 0]  ],
  [ 40, frame_hinge_l, [0, 5, 0], [0, 0, 0], [-10, 0, 0], [-15, 0, 0]  ]
];

batt_w = 45.5;
batt_h = 18;
batt_l = 156;
batt_offset = -80;
batt_holder_w = 10;
batt_holder_t = 4;
batt_holder_h = 9;
batt_side_beam_start = -40;
batt_side_beam_l = 119;
batt_catch_spar_h = 2;
batt_catch_h = 6;
*/

/* *************************************************** */
/* ************* 12 inch hex ************************* */
/* *************************************************** */

motor_center_l = 315;
prop_d = 12*25.4;
arms = 6;

slat_z_thickness = 4.8;
slat_xy_thickness = 4.8;
slat_k_thickness = 4.8;
bar_diameter = 4.8;
vert_thickness = 4.8;

frame_h = 40;
frame_w = 50;
frame_front = 110;
frame_back = 50;
frame_mid = frame_front - (frame_front + frame_back)/2;
gps_offset = 70;

length_sections = 4;
width_sections = 1;

arm_cp_slat_xy = 4;
arm_cp_slat_z = 2;
arm_cp_bar_d = 5.6;
arm_cp_top_bar_d = 5.6;

arm_slat_xy_1 = 4.8;
arm_slat_z_1 = 3;
arm_bar_d_1 = 4.8;
arm_top_bar_d_1 = 4.8;

arm_slat_xy_2 = 3.6;
arm_slat_z_2 = 3;
arm_bar_d_2 = 3.6;
arm_top_bar_d_2 = 3.6;

arm_table = [
  [ 210, [ 45, 100, frame_h], [ 180, 0, 57], 8 ],
  [ 240, [ 78, 0, frame_h], [ 180, 0, 0 ], 9 ],
  [ 240, [ 40, -66, frame_h], [ 180, 0, -60.5 ], 9 ]
];

arm_cp_x_offset = 3;
arm_cp_h_less = 0;

arm_motor_setback = 3.5;
frame_hinge_lock_d = 12;
frame_hinge_lock_hole_d = 3;
frame_hinge_lock_t = 4;
frame_hinge_lock_l = 70;
arm_hinge_lock_d = 12;
arm_hinge_lock_hole_d = 3;
arm_hinge_lock_t = 8;

n_motor_mount_hole = 4;
motor_mount_hole_d = 4;
motor_mount_hole_dist = [8.5, 9.5, 8.5, 9.5];
motor_mount_hole_supp_t = 4;
motor_mount_hole_supp_d = motor_mount_hole_d + 6;
motor_mount_base_d = 24; // motor_mount_hole_dist * 2;
motor_mount_base_t = 4;
motor_mount_base_indent_d = 8;
motor_mount_base_indent_t = 2.5;

arm_hinge_d = 10;
arm_hinge_hole_d = 3;
arm_hinge_l = 32;
arm_start_w = 30;
arm_end_w = 26; //18;
arm_end_h = 30; //18;

frame_hinge_d = 10;
frame_hinge_l = 58;

// Arm counterpart definitions:
//   [ length, width, left_adjust, right_adjust, top_adjust, mid_adjust ]
arm_cp_table = [
  [ 45, frame_hinge_l, [-10, -10, 0], [25, -10, 0], [-10, 0, 0], [-10, -3, 0] ],
  [ 57, frame_hinge_l, [0, -6, 0], [0, 0, 0], [-10, 0, 0], [0, 0, 0]  ],
  [ 45, frame_hinge_l, [0, 20, 0], [-10, 0, 0], [-10, 0, 0], [-18, 5, 0] ]
];

batt_w = 69;
batt_h = 26;
batt_l = 168;
batt_offset = -80;
batt_holder_w = 12;
batt_holder_t = 5;
batt_holder_h = 12;
batt_side_beam_start = -65;
batt_side_beam_l = 158;
batt_catch_spar_h = 2;
batt_catch_h = 10;


use_truss = true;
rotor_disks = false;


module arm(num) {
  motor_offset = (arm_table[num][0]) - arm_motor_setback;
  difference() {
  union() {
    triangular_truss(arm_table[num][0], arm_table[num][3], arm_start_w, 
                     frame_h-frame_hinge_lock_t, arm_end_w, 
                     arm_end_h,
                     arm_slat_xy_1, arm_slat_z_1, arm_bar_d_1, arm_top_bar_d_1,
                     arm_slat_xy_2, arm_slat_z_2, arm_bar_d_2, arm_top_bar_d_2,
                     8, use_truss=use_truss, bar_fn=16);
    if (!use_truss && rotor_disks) {
      translate([motor_offset, 0, -10])
        color("darkred") cylinder(r=prop_d/2, h=2);
    }
    arm_hinge(fit=0);
    translate([motor_offset, 0, 0]) {
      for (i = [0 : n_motor_mount_hole-1]) {
        rotate([0, 0, (i+.5)*(360/n_motor_mount_hole)])
          translate([motor_mount_hole_dist[i], 0, 0 ])
            cylinder(r=motor_mount_hole_supp_d/2, 
                     h=motor_mount_hole_supp_t);
      }
      cylinder(r=motor_mount_base_d/2, h=motor_mount_base_t, $fn=24);
    }
  }
  translate([motor_offset, 0, 0]) {
    for (i = [0 : n_motor_mount_hole-1]) {
      rotate([0, 0, (i+.5)*(360/n_motor_mount_hole)]) {
        translate([motor_mount_hole_dist[i], 0, 0])
          cylinder(r=motor_mount_hole_d/2, 
                   h=motor_mount_hole_supp_t+1, $fn=12);
      }
        cylinder(r=motor_mount_base_indent_d/2, h=motor_mount_base_indent_t, $fn=24);
      }
    }
  translate([frame_hinge_lock_d/2, 0, 
             frame_h-frame_hinge_lock_t-arm_hinge_lock_t])
    cylinder(r=arm_hinge_lock_hole_d/2, h=arm_hinge_lock_t*2, $fn=24);
  }
}

module arm_counterpart(num) {
  mirror([-1, 0, 0])
    translate([arm_cp_x_offset, -(frame_hinge_l-2)/2, arm_cp_h_less])
    intersection() {
      triangular_truss_adapter(arm_cp_table[num][0] - arm_cp_x_offset, 
                               frame_hinge_l-2, frame_h-arm_cp_h_less, 
                               arm_cp_table[num][1], 
                               frame_h,
                               arm_cp_slat_xy, arm_cp_slat_z, arm_cp_bar_d, arm_cp_top_bar_d,
                               8, left_adjust=arm_cp_table[num][2],
                               right_adjust=arm_cp_table[num][3],
                               top_adjust=arm_cp_table[num][4],
                               mid_adjust=arm_cp_table[num][5]);
      translate([0, -frame_hinge_l*2, 0])
        cube([arm_cp_table[num][0]*4, frame_hinge_l*4, frame_h-arm_cp_h_less]);
   }
}

module print_help_cylinder(r, h, $fn=16, help_translate=[0, 0, 0], 
                           help_rotate=[0, 0, 0]) {
  cylinder(r=r, h=h, $fn=$fn);
  intersection() {
    translate(help_translate)
      translate([0, h/2+r, h/2])
        rotate([90, 0, 0])
          rotate(help_rotate)
            cylinder(r1=0, r2=h*2, h=h*2, $fn=$fn);
    //        cylinder(r1=0, r2=h/2+r, h=h/2+r, $fn=$fn);
    union() {
    translate([-r*2, 0, 0])
      cube([r*3, h*2, h]);
    translate([-r*2, r*2, help_rotate[0]<0 ? -h : 0])
      cube([r*3, h*2, h*2]);
   }
  }
}

//print_help_cylinder(r=10, h=80, $fn=16);

module arm_hinge(fit=0) {
  h_l = arm_hinge_l + fit*2;
  translate([-arm_hinge_hole_d, h_l/2, arm_hinge_d/2])
    rotate([90, 0, 0])
      difference() {
        union () {
          cylinder(r=arm_hinge_d/2+fit, h=h_l, $fn=16);
          translate([0, -arm_hinge_d/2, 0])
            cube([arm_hinge_d/2, arm_hinge_d, h_l]);
          // If fit > 0, we're producing the negative space
          if (fit > 0) {
            translate([0, -arm_hinge_d/2, 0])
              cylinder(r=arm_hinge_d/2+fit, h=h_l, $fn=16);
            translate([0, 0, -frame_hinge_l])
              cylinder(r=arm_hinge_hole_d/2, h=frame_hinge_l*2, $fn=16);
            translate([0, 0, -arm_hinge_d-((frame_hinge_l-arm_hinge_l)/2)])
              cylinder(r=arm_hinge_d/2+fit, h=arm_hinge_d+fit, $fn=16);
            translate([0, 0, arm_hinge_l+(frame_hinge_l-arm_hinge_l)/2+fit])
              cylinder(r=arm_hinge_d/2+fit, h=arm_hinge_d+fit, $fn=16);
          }
        }
        if (fit==0) {
          cylinder(r=arm_hinge_hole_d/2, h=h_l, $fn=16);
        }        
  }
  translate([frame_hinge_lock_d/2, 0, 
             frame_h-frame_hinge_lock_t-arm_hinge_lock_t])
    difference() {
      union () {
        cylinder(r1=4, r2=arm_hinge_lock_d/2, h=arm_hinge_lock_t, $fn=24);
        //translate([0, -arm_hinge_lock_d/2, 0])
        //  cube([arm_hinge_lock_d, arm_hinge_lock_d, arm_hinge_lock_t]);
      }
      //cylinder(r=arm_hinge_lock_hole_d/2, h=arm_hinge_lock_t, $fn=24);
  }
}

module frame_hinge(fit=0, omit_hinge=false) {
  if (!omit_hinge) {
   translate([-arm_hinge_hole_d, frame_hinge_l/2, arm_hinge_d/2])
    rotate([90, 0, 0])
      difference() {
        union() {
          print_help_cylinder(r=frame_hinge_d/2, 
                              h=(frame_hinge_l-arm_hinge_l)/2-fit, $fn=16,
                              help_rotate=[25, 0, 0], 
                              help_translate=[-8, 3, 10]);
          translate([0, 0, frame_hinge_l-((frame_hinge_l-arm_hinge_l)/2-fit)])
            print_help_cylinder(r=frame_hinge_d/2, 
                                h=(frame_hinge_l-arm_hinge_l)/2-fit, $fn=16,
                                help_rotate=[-25, -0, 0], 
                                help_translate=[-8, 3, -10]);
          translate([-frame_hinge_d, -frame_hinge_d/2, 0])
            cube([frame_hinge_d, frame_hinge_d, frame_hinge_l]);
        }
        cylinder(r=arm_hinge_hole_d/2, h=frame_hinge_l, $fn=16);
        translate([0, 0, (frame_hinge_l-arm_hinge_l)/2-fit])
          cylinder(r=frame_hinge_d/2+tol, h=arm_hinge_l, $fn=16);
        translate([-frame_hinge_d/2, -frame_hinge_d, (frame_hinge_l-arm_hinge_l)/2-fit])
          cube([frame_hinge_d, frame_hinge_d, arm_hinge_l]);
  }
  }
  translate([frame_hinge_lock_d/2, 0, frame_h-frame_hinge_lock_t])
    difference() {
      union () {
        cylinder(r=frame_hinge_lock_d/2, h=frame_hinge_lock_t, $fn=24);
        translate([-frame_hinge_lock_l, -frame_hinge_lock_d/2, 0])
          cube([frame_hinge_lock_l, frame_hinge_lock_d, 
                frame_hinge_lock_t]);
      }
      cylinder(r=frame_hinge_lock_hole_d/2, h=frame_hinge_lock_t, $fn=24);
  }
}

mobius_mount_t = 20;

module mobius_mount() {
  difference() {
    for (i = [0 : 3]) {
      rotate([0, 0, i*90])
        translate([board_mount_l/2, board_mount_l/2, 0])
        cylinder(r=board_mount_support_d/2, h=mobius_mount_t, $fn=12);
    }
    for (i = [0 : 3]) {
      rotate([0, 0, i*90])
        translate([board_mount_l/2, board_mount_l/2, -1])
          cylinder(r=board_mount_hole_d/2, h=mobius_mount_t+2, $fn=12);
    }
  }
}

module 50_50_mount() {
      difference() {
        for (i = [0 : 3]) {
          rotate([0, 0, i*90])
            translate([board_mount_l/2, board_mount_l/2, 
                       frame_h-slat_z_thickness])
            cylinder(r=board_mount_support_d/2, h=board_mount_t+slat_z_thickness, $fn=12);
        }
        for (i = [0 : 3]) {
          rotate([0, 0, i*90])
            translate([board_mount_l/2, board_mount_l/2, frame_h])
              cylinder(r=board_mount_hole_d/2, h=board_mount_t+1, $fn=12);
        }
      }
}

module batt_holder() {
%  translate([-batt_w/2, batt_offset, batt_holder_t])
    cube([batt_w, batt_l, batt_h]);
  // Frame attachment points
  if (arms == 6)
  difference() {
        for (i = [ 0 , 2, 3, 5]) {
          mirror(i >= arms/2 ? [-1, 0, 0] : [0, 0, 0])
            translate(arm_table[i % (arms/2)][1])
              rotate(arm_table[i % (arms/2)][2])
                {
                  frame_hinge(fit=0, omit_hinge=true);
                }
        }
    translate([-batt_w/2-batt_holder_t/2, batt_offset+batt_l/4, -1])
      cube([batt_w+batt_holder_t, batt_l/2, batt_holder_t+2]);
  }
  if (arms == 4)
  difference() {
        for (i = [ 0 : arms - 1]) {
          mirror(i >= arms/2 ? [-1, 0, 0] : [0, 0, 0])
            translate(arm_table[i % (arms/2)][1])
              rotate(arm_table[i % (arms/2)][2])
                {
                  frame_hinge(fit=0, omit_hinge=true);
                }
        }
    translate([-batt_w/2-batt_holder_t/2, batt_offset+batt_l/4, -1])
      cube([batt_w+batt_holder_t, batt_l/2, batt_holder_t+2]);
  }
  // Side beams
  difference() {
    union() {
      translate([-batt_w/2-batt_holder_t, batt_side_beam_start, 0])
        cube([batt_holder_t, batt_side_beam_l, batt_holder_h]);
      translate([batt_w/2, batt_side_beam_start, 0])
        cube([batt_holder_t, batt_side_beam_l, batt_holder_h]);
    }
    // Cable channels
    for (i = [-1 : 1]) {
      translate([-batt_w, i*batt_holder_t*3, 0])
        rotate([0, 90, 0])
          cylinder(r=batt_holder_t, h=batt_w*2, $fn=24);
    }
  }
  // Front endstop
  translate([-batt_w/2-batt_holder_t/2, batt_offset+batt_l, 0])
    cube([batt_w + batt_holder_t, batt_holder_t, batt_holder_h]);
  translate([-batt_w/2-batt_holder_t/2, batt_offset+batt_l, 0])
    cube([batt_holder_t, batt_holder_t, batt_catch_h]);
  // Back catch
  translate([-batt_holder_w/2, batt_offset-batt_holder_t, 0])
    cube([batt_holder_w, batt_l/4+batt_holder_w/2, batt_catch_spar_h]);
  translate([-batt_holder_w/2, batt_offset-batt_holder_t, 0])
    cube([batt_holder_w, batt_holder_t, batt_holder_t+batt_catch_h]);
  // Holders
  for (off = [ batt_offset + batt_l/4, batt_offset + batt_l/4*3]) {
  translate([0, off, 0])
  difference() {
    union() {
      translate([-batt_w/2-batt_holder_t, -batt_holder_w/2, 0])
        cube([batt_w+batt_holder_t*2, batt_holder_w, batt_h+batt_holder_t*2]);
      translate([-batt_w/2-batt_holder_t, 0, 0])
        cylinder(r=batt_holder_w/2, h=batt_h+batt_holder_t*2, $fn=24);
      translate([batt_w/2+batt_holder_t, 0, 0])
        cylinder(r=batt_holder_w/2, h=batt_h+batt_holder_t*2, $fn=24);
      }
    translate([-batt_w/2, -batt_holder_w/2, batt_holder_t])
      cube([batt_w, batt_holder_w, batt_h]);
     }
  }
}

module frame() {
  difference() {
    union() {
      translate([-frame_w/2, -frame_back + batt_extend, 0])
        cube([frame_w, batt_bulkhead_t, frame_h]);
      translate([-frame_w/2, -frame_back, 0])
        if (use_truss) {
          pyramid_box_truss(frame_w, frame_back + frame_front, frame_h, 
                            width_sections, length_sections, 2,
                            slat_z_thickness, slat_xy_thickness, 
                            slat_k_thickness,
                            bar_diameter, vert_thickness, 1, 0, 16);
        } else {
          cube([frame_w, frame_back + frame_front, frame_h]);
        }
	  50_50_mount();
      if (gps_offset) {
		translate([0, gps_offset, 0]) 50_50_mount();
      }
      difference() {
        for (i = [ 0 : arms - 1]) {
          mirror(i >= arms/2 ? [-1, 0, 0] : [0, 0, 0])
            translate(arm_table[i % (arms/2)][1])
              rotate(arm_table[i % (arms/2)][2])
                {
                  frame_hinge(fit=0);
                }
        }
        translate([-frame_w/2+1, -frame_back+1, -1])
          cube([frame_w-2, frame_back + frame_front-2, frame_h+2]);        
      }      
      for (i = [ 0 : arms - 1]) {
        mirror(i >= arms/2 ? [-1, 0, 0] : [0, 0, 0])
          translate(arm_table[i % (arms/2)][1])
            rotate(arm_table[i % (arms/2)][2])
              {
                arm_counterpart(i % (arms/2));
              }
      }
    }
      for (i = [ 0 : arms - 1]) {
        mirror(i >= arms/2 ? [-1, 0, 0] : [0, 0, 0])
          translate(arm_table[i % (arms/2)][1])
            rotate(arm_table[i % (arms/2)][2])
              arm_hinge(fit=fit);
    }
  }
//  translate([-12, -67, frame_h-4])  // -42
//    cube([24, 4, 15]);
}

module assembly() {
  frame();
//  translate([-frame_w/2, -frame_back, 0])
//    cube([frame_w, frame_back + frame_front, frame_h]);
  for (i = [ 0 : arms - 1 ]) {
    mirror(i >= arms/2 ? [-1, 0, 0] : [0, 0, 0])
      translate(arm_table[i % (arms/2)][1])
        rotate(arm_table[i % (arms/2)][2])
          arm(i % (arms/2));
  }
}

//mobius_mount();
//assembly();
//intersection() {
  frame();
//batt_holder();
//  translate([-100, -82, 0]) cube([200, 200, 100]);
//}
//arm(0);
//frame_hinge();
//arm_counterpart(1);
//arm_hinge();
//translate([0, -80, 0]) cube([10, 200, 100]);

if (rotor_disks) {
translate([0, 0, 0])
for (i = [0 : arms]) { 
  rotate([0, 0, 0+(360/arms)*i]) {
    translate([motor_center_l, 0, 20]) color("darkblue") cylinder(r=prop_d/2, h=2);
    //translate([motor_center_l, 0, -boom_d*((i+1)%2)]) motor_mount();
  }
}
}