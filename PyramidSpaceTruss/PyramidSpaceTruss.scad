/* Pyramid Space Truss by Tomi T. Salo <ttsalo@iki.fi> 2012-2017 */

use <../includes/maths.scad>;

/* Pyramid space truss library.
   The finalized modules are:
   
   pyramid_box_truss(): rectangular truss with parametric dimensions and internal
     structure
     
   triangular_truss(): triangular truss with parametric dimensions and structure, with
     ability to make the dimensions smaller towards the far end
     
   With the above two modules you can replicate the structures familiar from most
     construction cranes, with box truss forming the mast and the triangular truss the
     boom. The rest of the modules apart from the three bolt pattern ones are
     mostly utilities used by the two above.
   
   box_bolt_pattern_side(), box_bolt_pattern_lower(), box_bolt_pattern_upper():
     auxiliary modules for adding bolt patterns to box trusses (or anything rectangular
     really)
*/

/* Regular rectangular truss composed of pyramid layers with
   alternating orientation.

   x_size, y_size, z_size: the total size of the structure

   x_segs, y_segs, z_segs: the number of segments in each dimension.
     z_segs should be divisible by two. If z_segs is 1, falls back to
     basic pyramid truss without the side lattices.

   slat_z_thickness: the vertical thickness of the rectangular bars

   slat_xy_thickness: the horizontal thickness of the rectangular bars

   slat_k_thickness: the horizontal thickness of the diagonal rectangular bars

   bar_diameter: the diameter of the vertical and slanted round bars
   
   vert_thickness: the horizontal thickness of the vertical segment corner bars

   crossbars1, crossbars2: each true or false depending on if crossbars are
     wanted at the sides
     
   bar_fn: used as the $fn parameter for the round bars
   */

/* Example box truss structure. */
if (false)
  pyramid_box_truss(40, 40, 120, // Overall dimensions
                      1, 1, 6,      // Segment counts
                      4, 4, 4, 4, 4, // Thicknesses
                      true, true, $16);
   
module 
pyramid_box_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                         slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                         bar_diameter, vert_thickness, crossbars1, crossbars2, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;
  z_pitch = (z_size - slat_z_thickness) / z_segs;
  
  for (z = [ 0 : z_segs - 1 ]) {
    translate([0, 0, z * z_pitch])
      pyramid_truss(x_size, y_size, z_pitch + slat_z_thickness, 
                    x_segs, y_segs,
                    slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                    bar_diameter, bar_fn, (z % 2));
  }

  if (z_segs > 1) {
    intersection () {
      cube([x_size, y_size, z_size]);
      for (z = [0 : z_segs / 2 - 1]) {
        translate([slat_xy_thickness/2, slat_xy_thickness/2, z * 2 * z_pitch])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs,
                             x_pitch, slat_xy_thickness, bar_diameter, vert_thickness,
			     bar_fn, true, false, crossbars1, crossbars2);
        translate([slat_xy_thickness/2, 
		   y_size - slat_xy_thickness/2, z * 2 * z_pitch])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, x_segs,
                             x_pitch, slat_xy_thickness, bar_diameter, vert_thickness,
			     bar_fn, true, true, crossbars1, crossbars2);
        translate([slat_xy_thickness/2, slat_xy_thickness/2, z * 2 * z_pitch])
          rotate([0, 0, 90])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs,
                             y_pitch, slat_xy_thickness, bar_diameter, vert_thickness,
			     bar_fn, false, true, crossbars1, crossbars2);
        translate([x_size - slat_xy_thickness/2, 
		   slat_xy_thickness/2, z * 2 * z_pitch])
          rotate([0, 0, 90])
          truss_side_lattice(z_pitch * 2 + slat_z_thickness, y_segs,
                             y_pitch, slat_xy_thickness, bar_diameter, vert_thickness,
			     bar_fn, false, false, crossbars1, crossbars2);
      }
    }
  }
}

/* Multi-layer pyramid truss. Same as pyramid_truss but has several
   sections stacked on each other, with sections becoming one segment
   smaller each step up. */
module multi_pyramid_truss(x_size, y_size, z_size, x_segs, y_segs, z_segs,
                           slat_z_thickness, slat_xy_thickness, 
                           slat_k_thickness, bar_diameter, bar_fn)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;
  z_pitch = (z_size - slat_z_thickness) / z_segs;
  
  for (z = [ 0 : z_segs - 1 ]) {
    translate([z * x_pitch * 0.5, z * y_pitch * 0.5, z * z_pitch])
      pyramid_truss(x_size - x_pitch * z, y_size - y_pitch * z, 
                    z_pitch + slat_z_thickness, 
                    x_segs - z, y_segs - z,
                    slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                    bar_diameter, bar_fn, 0);
  }
}

/* One layer pyramid truss. Made from x_segs*y_segs pyramid sections
   with a lattice on the top and the bottom (top lattice being one
   section smaller than the bottom one) */
module pyramid_truss(x_size, y_size, z_size, x_segs, y_segs,
                     slat_z_thickness, slat_xy_thickness, slat_k_thickness,
                     bar_diameter, bar_fn, flip)
{
  x_pitch = (x_size - slat_xy_thickness) / x_segs;
  y_pitch = (y_size - slat_xy_thickness) / y_segs;
  
  translate([0, 0, z_size * flip])
    mirror([0, 0, flip])
      intersection () {
        cube([x_size, y_size, z_size]);
        union () {
          truss_lattice(x_size, y_size, x_segs, y_segs, x_pitch, y_pitch,
                        slat_z_thickness, slat_xy_thickness, slat_k_thickness);
          translate([x_pitch/2, y_pitch/2, z_size - slat_z_thickness])
            truss_lattice(x_size - x_pitch, y_size - y_pitch, x_segs - 1, 
                          y_segs - 1, x_pitch, y_pitch,
                          slat_z_thickness, slat_xy_thickness, 
                          slat_k_thickness);
          translate([slat_xy_thickness/2, slat_xy_thickness/2, 
                     slat_z_thickness/2])
            for (x = [ 0 : x_segs - 1]) {
              for (y = [ 0 : y_segs - 1]) {
                translate([x * x_pitch, y * y_pitch, 0])
                  pyramid(x_pitch, y_pitch, z_size - slat_z_thickness, 
                          bar_diameter, bar_fn);
              }
            }
        }
  }
}

/* One truss lattice layer. Horizontal rectangular grid, with given Z
   and XY slat dimensions and optionally diagonal cross slats if the K
   thickness is more than 0. */
module truss_lattice(x_size, y_size, x_segs, y_segs, x_pitch, y_pitch,
                     slat_z_thickness, slat_xy_thickness, slat_k_thickness)
  difference() {
    cube([x_size, y_size, slat_z_thickness]);
    for (x = [ 0 : x_segs - 1]) {
      for (y = [ 0 : y_segs - 1]) {
        translate([x * x_pitch + slat_xy_thickness, 
                   y * y_pitch + slat_xy_thickness, 0])
          if (slat_k_thickness > 0) {
            difference() {
              cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, 
                    slat_z_thickness]);
              if (x % 2 == 0) {
                rotate([0, 0, -atan(x_pitch / y_pitch)])
                  translate([-slat_k_thickness/2, -slat_xy_thickness*0.7, 0])
                    cube([slat_k_thickness, sqrt(x_pitch * x_pitch + y_pitch *
                                                 y_pitch), slat_z_thickness]);
              } else {
                translate([0, y_pitch - slat_xy_thickness, 0])
                  rotate([0, 0, -180 + atan(x_pitch / y_pitch)])
                    translate([-slat_k_thickness/2, -slat_xy_thickness*0.7, 0])
                      cube([slat_k_thickness, sqrt(x_pitch * x_pitch + 
                                                   y_pitch * y_pitch), 
                            slat_z_thickness]);               
              }
            }
          } else {
            cube([x_pitch - slat_xy_thickness, y_pitch - slat_xy_thickness, 
                  slat_z_thickness]);
          }
    }
  }
}

/* Side lattice. Arranged with centerline along the X axis. Optionally
   can include of omit the corner bars (used when creating all four
   sides to avoid doubling the corner bars).  Also can optionally
   create one or two diagonal crossbars between each section. */
module truss_side_lattice(z_size, x_segs, x_pitch, slat_xy_thickness,
                          bar_diameter, vert_thickness, bar_fn, 
                          cornerbars, far_side, crossbars1=0, crossbars2=0)
{
  /* Cornerbars optional (and a special case). */
  if (cornerbars) {
    translate([-slat_xy_thickness/2, -slat_xy_thickness/2 - (far_side ? (vert_thickness - slat_xy_thickness) : 0)])
      cube([vert_thickness, vert_thickness, z_size]);
    translate([x_pitch * x_segs - slat_xy_thickness/2 - (vert_thickness - slat_xy_thickness), 
                    -slat_xy_thickness/2 - (far_side ? (vert_thickness - slat_xy_thickness) : 0)])
      cube([vert_thickness, vert_thickness, z_size]);
  }
  /* The rest of the vertical bars. */
  if (x_segs > 1) {
    for (x = [1 : x_segs - 1]) {
     translate([x * x_pitch - vert_thickness/2, 
                     -slat_xy_thickness/2  - (far_side ? (vert_thickness - slat_xy_thickness) : 0)])
       cube([vert_thickness, vert_thickness, z_size]); 
    }
  }
  /* Slanted crossbars */
  if (crossbars1)
    for (x = [0 : x_segs - 1]) {
      translate([x * x_pitch, 0, 0])
        rotate([0, atan2(x_pitch, z_size), 0])
          pyramid_cylinder(r=bar_diameter/2, h=sqrt(x_pitch * x_pitch + 
                                                    z_size * z_size), 
                           $fn=bar_fn);
    }  
  if (crossbars2)
    for (x = [1 : x_segs]) {
      translate([x * x_pitch, 0, 0])
        rotate([0, -atan2(x_pitch, z_size), 0])
        pyramid_cylinder(r=bar_diameter/2, h=sqrt(x_pitch * x_pitch + 
                                                  z_size * z_size), 
                         $fn=bar_fn);
    }
}

/* Triangular truss with variable dimensions.

   x_size: total length of the structure in x dimension

   x_segs: number of segments along the x dimension

   y1_size, z1_size: dimensions in y and z at x=0

   y2_size, z2_size: dimensions in y and z at x=x_size

   slat_xy1_thickness: thickness of the crosswise rectangular slats in y dimension
     in the first segment

   slat_z1_thickness: thickness of the crosswise rectangular slats in z dimension
     in the first segment

   bar1_diameter: thickness of the diagonal round bars in the first segment

   top_bar1_diameter: thickness of the top round bars in the first segment

   slat_xy2_thickness, slat_z2_thickness, bar2_diameter, top_bar2_diameter:
     same as the previous four except applied to the last segment. Segments in
     between are interpolated from the first and last.
 
   bar_fn: used as the $fn parameter for the round bars
   
   use_truss: replaces the truss with an equivalent solid structure. Can be used
     to make the model temporarily easier to render.
*/

if (true)
  triangular_truss(100, 5, 25, 40, 10, 20, // Dimensions
                   4, 2, 3.6, 4, 2.4, 2, 2.4, 2, // Thicknesses
                   8);

module triangular_truss(x_size, x_segs, y1_size, z1_size, y2_size, z2_size,
                         slat_xy1_thickness, slat_z1_thickness, bar1_diameter,       
                         top_bar1_diameter,
                         slat_xy2_thickness, slat_z2_thickness, bar2_diameter,
                         top_bar2_diameter,
                         bar_fn, use_truss=true)
{
  y_step = (y1_size-y2_size)/x_segs;
  z_step = (z1_size-z2_size)/x_segs;
  slat_xy_step = (slat_xy1_thickness-slat_xy2_thickness)/x_segs;
  slat_z_step = (slat_z1_thickness-slat_z2_thickness)/x_segs;
  bar_diameter_step = (bar1_diameter-bar2_diameter)/x_segs;
  top_bar_diameter_step = (top_bar1_diameter-top_bar2_diameter)/x_segs;

  p1 = [0, 0, 0];
  p2 = [0, y1_size, 0];
  p3 = [x_size, y1_size-(y1_size-y2_size)/2, 0];  
  p4 = [x_size, (y1_size-y2_size)/2, 0];
  p5 = [0, y1_size/2, z1_size];
  p6 = [x_size, y1_size/2, z2_size];

  translate([0, -y1_size/2, 0])
  if (!use_truss) {
     polyhedron(points = [p1, p2, p3, p4, p5, p6],
               triangles = [[0, 3, 2], [1, 2, 0], [1, 4, 0], [4, 5, 3], [4, 3, 0],
                        [3, 5, 2], [5, 4, 1], [5, 1, 2]], convexity=2);
  } else {
  difference() {
    for (i = [0 : x_segs-1]) {
      translate([(x_size/x_segs)*i, y_step*i/2, 0])
        triangular_truss_section(x_size/x_segs, y1_size-y_step*i, z1_size-z_step*i, 
                                 y1_size-y_step*(i+1), z1_size-z_step*(i+1), 
                                 slat_xy1_thickness-slat_xy_step*i,
                                 slat_z1_thickness-slat_z_step*i,
                                 bar1_diameter-bar_diameter_step*i,
                                 top_bar1_diameter-top_bar_diameter_step*i,
                                 i==0?1:0, (i<x_segs-1)?0:1, i%2, bar_fn);
    }
    translate([0, 0, -x_size*2])
      cube([x_size*4, x_size*4, x_size*4], center=true);
    rotate([0, 90, 0])
      translate([0, 0, -x_size*2])
        cube([x_size*4, x_size*4, x_size*4], center=true);
    translate([x_size, 0, 0])
      rotate([0, -90, 0])
        translate([0, 0, -x_size*2])
          cube([x_size*4, x_size*4, x_size*4], center=true);
  }
  }
}

module triangular_truss_section(x_size, y1_size, z1_size, y2_size, z2_size,
                                slat_xy_thickness, slat_z_thickness,
                                bar_diameter, top_bar_diameter, first, last, even, bar_fn)
{
  bar_r = bar_diameter/2;
  top_bar_r = top_bar_diameter/2;
  top_x = x_size/2;
  top_y = y1_size/2;
  top_z = (z1_size+z2_size)/2-top_bar_r*2;
  if (first) {
    cube([slat_xy_thickness, y1_size, slat_z_thickness]);
  }
  if (!last) {
    translate([x_size-slat_xy_thickness/2, (y1_size-y2_size)/2, 0])
      cube([slat_xy_thickness, y2_size, slat_z_thickness]); 
  } else {
    translate([x_size-slat_xy_thickness, (y1_size-y2_size)/2, 0])
      cube([slat_xy_thickness, y2_size, slat_z_thickness]);
  }
  placed_pyramid_cylinder(0, bar_r*1.4, bar_r, 
                          x_size, (y1_size-y2_size)/2+bar_r*1.4, bar_r, 
                          bar_r, fn=bar_fn);
  placed_pyramid_cylinder(0, y1_size-bar_r*1.4, bar_r, 
                          x_size, y1_size-(y1_size-y2_size)/2-bar_r*1.4, bar_r, 
                          bar_r, fn=bar_fn);
  if (even) {
    placed_pyramid_cylinder(0, bar_r, bar_r, 
                            x_size, y1_size-(y1_size-y2_size)/2-bar_r, bar_r, 
                            bar_r, fn=bar_fn);
  } else {
    placed_pyramid_cylinder(0, y1_size-bar_r, bar_r, 
                            x_size, (y1_size-y2_size)/2+bar_r, bar_r, 
                            bar_r, fn=bar_fn);
  }
  placed_pyramid_cylinder(0, bar_r*1.4, 0, top_x, top_y, top_z, bar_r, fn=bar_fn);
  placed_pyramid_cylinder(0, y1_size-bar_r*1.4, 0, top_x, top_y, top_z, bar_r, fn=bar_fn);
  if (first) {
    placed_pyramid_cylinder(bar_r, bar_r*1.4, 0, bar_r, top_y, top_z, bar_r, fn=bar_fn);
    placed_pyramid_cylinder(bar_r, y1_size-bar_r*1.4, 0, bar_r, top_y, top_z, bar_r, fn=bar_fn);
  }
  placed_pyramid_cylinder(x_size, (y1_size-y2_size)/2+bar_r*1.4, 0, top_x, top_y, top_z, bar_r, fn=bar_fn);
  placed_pyramid_cylinder(x_size, y1_size-(y1_size-y2_size)/2-bar_r*1.4, 0, 
                          top_x, top_y, top_z, bar_r, fn=bar_fn);
  if (!last) {
    placed_pyramid_cylinder(top_x, top_y, top_z, 
                            top_x + x_size, top_y, top_z-(z1_size-z2_size),
                            top_bar_r, fn=bar_fn);
  }
  if (last) {
    placed_pyramid_cylinder(top_x-1, top_y, top_z, 
                            top_x + x_size/2, top_y, top_z-(z1_size-z2_size)/2,
                            top_bar_r, fn=bar_fn);
  placed_pyramid_cylinder(x_size-bar_r, (y1_size-y2_size)/2+bar_r*1.4, 0, x_size-bar_r, top_y, top_z, bar_r, fn=bar_fn);
  placed_pyramid_cylinder(x_size-bar_r, y1_size-(y1_size-y2_size)/2-bar_r*1.4, 0, 
                          x_size-bar_r, top_y, top_z, bar_r, fn=bar_fn);

  }

  if (first) {
    placed_pyramid_cylinder(top_x+1, top_y, top_z, 
                            0, top_y, top_z, 
                            top_bar_r, fn=bar_fn);
  }
}

/* Adapter between triangular and box truss sections. */

if (false)
  triangular_truss_adapter(30, 30, 30, 20, 20, 4, 2, 3, 3, 16);

module triangular_truss_adapter(x_size, y1_size, z1_size, y2_size, z2_size,
                                slat_xy_thickness, slat_z_thickness,
                                bar_diameter, top_bar_diameter, bar_fn,
                                left_adjust=[0, 0, 0], right_adjust=[0, 0, 0],
                                top_adjust=[0, 0, 0], mid_adjust=[0, 0, 0])
{
  bar_r = bar_diameter/2;
  top_bar_r = top_bar_diameter/2;
  top_x = x_size/2 + top_adjust[0];
  top_y = y1_size/2 + top_adjust[1];
  top_z = (z1_size+z2_size)/2-top_bar_r*2 + top_adjust[2];

  left_end = [x_size+left_adjust[0], 
              (y1_size-y2_size)/2+bar_r*1.4+left_adjust[1], 
              bar_r+left_adjust[2]];
  right_end = [x_size+right_adjust[0], 
               y1_size-(y1_size-y2_size)/2-bar_r*1.4+right_adjust[1],  
               bar_r+right_adjust[2]];
  mid_end = [x_size+mid_adjust[0], y1_size/2+mid_adjust[1], bar_r+mid_adjust[2]];

  placed_pyramid_cylinder(0, bar_r*1.4, bar_r, 
                           left_end[0], left_end[1], left_end[2],
                           bar_r, fn=bar_fn);  
  placed_pyramid_cylinder(0, bar_r*1.4, bar_r, 
                           mid_end[0], mid_end[1], mid_end[2],
                           bar_r, fn=bar_fn);
  placed_pyramid_cylinder(0, y1_size-bar_r*1.4, bar_r, 
                           right_end[0], right_end[1], right_end[2],
                           bar_r, fn=bar_fn);
  placed_pyramid_cylinder(0, y1_size-bar_r*1.4, bar_r, 
                           mid_end[0], mid_end[1], mid_end[2],
                           bar_r, fn=bar_fn);

  // Crossbar
  /*  placed_pyramid_cylinder(0, y1_size-bar_r, bar_r, 
                            left_end[0], left_end[1], left_end[2],
                            bar_r, fn=bar_fn); */

  placed_pyramid_cylinder(0, bar_r*1.4, 0, top_x, top_y, top_z, bar_r, fn=bar_fn);
  placed_pyramid_cylinder(0, y1_size-bar_r*1.4, 0, top_x, top_y, top_z, bar_r, fn=bar_fn);

  placed_pyramid_cylinder(left_end[0], left_end[1], left_end[2]-bar_r,
                           top_x, top_y, top_z, bar_r, fn=bar_fn);
  placed_pyramid_cylinder(right_end[0], right_end[1], right_end[2]-bar_r, 
                          top_x, top_y, top_z, bar_r, fn=bar_fn);
  placed_pyramid_cylinder(mid_end[0], mid_end[1], mid_end[2], 
                          top_x, top_y, top_z, bar_r, fn=bar_fn);
}

/* One pyramid section. The xyz measurements are between the truss
   vertex centerpoints, so in use this should be translated to the
   desired vertex center. */
module pyramid(x_pitch, y_pitch, z_pitch, bar_diameter, bar_fn)
{
  /* The length of the projection of the slanted bar in XY-plane */
  bar_xy = sqrt(pow(x_pitch/2, 2) + pow(y_pitch/2, 2));

  /* The 3D length of the slanted bar */
  bar = sqrt(pow(bar_xy, 2) + pow(z_pitch, 2));
  
  z_rot = asin((y_pitch/2) / bar_xy);
  xy_rot = acos(z_pitch / bar);
  rotate([0, xy_rot, z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([x_pitch, 0, 0]) rotate([0, xy_rot, 180-z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([x_pitch, y_pitch, 0]) rotate([0, xy_rot, 180+z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
  translate([0, y_pitch, 0]) rotate([0, xy_rot, -z_rot])
    pyramid_cylinder(r=bar_diameter/2, h=bar, $fn=bar_fn);
}

module placed_pyramid_cylinder(x1, y1, z1, x2, y2, z2, r, fn=24) {
  l = sqrt(pow(x2-x1,2)+pow(y2-y1,2)+pow(z2-z1,2));
  dx = x2-x1;
  dy = y2-y1;
  dz = z2-z1;
  v = LineRotations([dx, dy, dz]);
  translate([x1, y1, z1])
    rotate(v)
      pyramid_cylinder(r=r, h=l, $fn=fn);
}

/* Variation of a basic cylinder with conical widening ends. */
module pyramid_cylinder(r=0, h=0, $fn=12)
{
  ch = r/h * 4; // Autocalculate the cone section length for the joints to work
  cylinder(r=r, h=h, $fn=$fn);
  cylinder(r1=r*2, r2=r, h=h*ch, $fn=$fn);
  translate([0, 0, h*(1-ch)])
    cylinder(r1=r, r2=r*2, h=h*ch, $fn=$fn);
}

/* box_bolt_pattern_side(), box_bolt_pattern_lower() and
   box_bolt_pattern_upper() can be used to add bolt mount points in
   the trusses for bolting many trusses together.

   x, y, z: Truss dimensions
   thickness: Thickness of the bolt mount plate
   truss_xy_thickness: The thickness of the truss elements, used when 
     adding some support structure inside the truss.
   hole_r: Radius of the bolt hole
   hex_r: Radius of the hex nut trap inside the support cone for the 
     upper bolt mounts 
   clearance_r: Radius of clearance around the bolt, determines the 
     size of the plate
   near: Determines whether the side bolt mounts are added near the 
     Y=0 or at the far end
*/

/* Example structures, truss box with bolts at one side, bottom, top */
//pyramid_box_truss(50, 50, 50, 1, 1, 2, 4, 4, 4, 4, 4, true, true, $16);
//box_bolt_pattern_side(50, 50, 50, 4, 4, 2.2, 6, true);
//box_bolt_pattern_lower(50, 50, 4, 4, 2.2, 6);
//box_bolt_pattern_upper(50, 50, 50, 4, 4, 2.2, 4, 6, 0.3);

module box_bolt_pattern_side(x, y, z, thickness, truss_xy_thickness, 
                             hole_r, clearance_r, near, upper=true, lower=true) {
  intersection() {
    translate([0, near ? thickness : y, 0])
      rotate([90, 0, 0]) {
        box_one_side_bolts(x, z, thickness, hole_r, 0, clearance_r, 
                           false, true, upper=upper, lower=lower);
        translate([x, 0, 0])
          mirror([1, 0, 0])
            box_one_side_bolts(x, z, thickness, hole_r, 0, clearance_r, 
                               false, true, upper=upper, lower=lower);
        cube([truss_xy_thickness, z, thickness]);
        translate([x-truss_xy_thickness, 0, 0])
          cube([truss_xy_thickness, z, thickness]);
    }
    /* Cut out the teardrop bits from negative Z values */
    translate([-clearance_r*2, 0, 0])
      cube([x+clearance_r*4, y, z]);
  }
}

module box_bolt_pattern_lower(x, y, thickness, truss_xy_thickness, 
                              hole_r, clearance_r) {
  box_one_side_bolts(x, y, thickness, hole_r, 0, clearance_r, false, false);
  translate([x, 0, 0])
    mirror([1, 0, 0])
      box_one_side_bolts(x, y, thickness, hole_r, 0, clearance_r, 
                         false, false);
  cube([truss_xy_thickness, y, thickness]);
  translate([x-truss_xy_thickness, 0, 0])
    cube([truss_xy_thickness, y, thickness]);
}

module box_bolt_pattern_upper(x, y, z, thickness, truss_xy_thickness,
                              hole_r, hex_r, clearance_r, layer_height, bolt_fn=6) {
  translate([0, 0, z - thickness]) {
    box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, 
                       true, false, layer_height, bolt_fn=bolt_fn);
    translate([x, 0, 0])
      mirror([1, 0, 0])
        box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, 
                           true, false, layer_height, bolt_fn=bolt_fn);
  }
  translate([0, 0, z-clearance_r*2-thickness-truss_xy_thickness])
    intersection() {
      cube([truss_xy_thickness, y, 
            clearance_r*2+thickness+truss_xy_thickness]);
      translate([truss_xy_thickness/2, 0, 0])
        rotate([0, -45, 0])
          cube([clearance_r*3, y, clearance_r*3]);
    }
  translate([x, 0, 0])
    mirror([1, 0, 0])
      translate([0, 0, z-clearance_r*2-thickness-truss_xy_thickness])
        intersection() {
          cube([truss_xy_thickness, y, 
                clearance_r*2+thickness+truss_xy_thickness]);
          translate([truss_xy_thickness/2, 0, 0])
            rotate([0, -45, 0])
              cube([clearance_r*3, y, clearance_r*3]);
        }
}

module box_one_side_bolts(x, y, thickness, hole_r, hex_r, clearance_r, 
                          supported, teardrop, upper=true, lower=true, 
                          layer_height=0, bolt_fn=6) {
  for (offset = [0 , y - 2*clearance_r]) {
    if (offset == 0 ? lower : upper)
    intersection () {
      union () {
        translate([-clearance_r, clearance_r+offset, 0])
          difference() {
            union () {
              
                translate([0, 0, -clearance_r*3]) {
                  cylinder(r=clearance_r, h=thickness+clearance_r*3);
                }
              if (teardrop) {
                intersection() {
                  rotate([0, 0, -45]) translate([0, -clearance_r, 0])
                    cube([clearance_r*3, clearance_r*2, thickness]);
                  translate([-clearance_r, -clearance_r*4, 0])
                    cube([clearance_r*2+.01, clearance_r*4, thickness]);
                }
              }
              translate([0, -clearance_r, -clearance_r*3])
                cube([clearance_r, clearance_r*2, thickness+clearance_r*3]);
            }
            cylinder(r=hole_r, h=thickness);
          }        
      }
      union () {
        if (supported) {
          difference() {
            translate([0, clearance_r+offset, -clearance_r*2])
              cylinder(r1=0, r2=clearance_r*3, h=clearance_r*3);
            translate([-clearance_r, clearance_r+offset, -clearance_r*2-layer_height])
              cylinder(r=hex_r, h=clearance_r*2, $fn=bolt_fn);
          }
        }
        translate([0, clearance_r+offset, 0])
          cylinder(r=clearance_r*3, h=clearance_r*3);
      }
    }
  }
}
