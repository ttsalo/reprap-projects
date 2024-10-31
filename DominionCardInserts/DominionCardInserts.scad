// Dominion base game box inserts

card_thickness = 0.6;
card_length = 98;

bottom_thickness = 3;
section_length = 287;
guide_width = 61;
section_width = (section_length - guide_width) / 2;
section_height = 25;

cutout_width = 78;
cutout_bottom = 10;
cutout_slant_height = 8;
cutout_slant_angle = 30;
cutout_rounding_r = 4.5;

module slot(cards) {
    translate([(section_width - card_length)/2, -card_thickness*cards/2, bottom_thickness])
      cube([card_length, card_thickness*cards, 100]);
    translate([(section_width - card_length)/2, 0, section_height])
      rotate([0, 90, 0])
        cylinder(r=cutout_rounding_r, h=card_length, $fn=16);
    translate([(section_width - card_length)/2, -card_thickness*cards/2, 
                section_height-cutout_slant_height])
      rotate([0, -cutout_slant_angle, 0])
        cube([card_length, card_thickness*cards, 100]);
    translate([(section_width - card_length)/2+card_length, -card_thickness*cards/2, 
                section_height-cutout_slant_height])
      rotate([0, cutout_slant_angle, 0])
        translate([-card_length, 0, 0])
          cube([card_length, card_thickness*cards, 100]);
}

first_slot = 10;
slot_pitch = 11.5;

section_data = [[first_slot, 10], 
                [first_slot+slot_pitch, 10],
                [first_slot+slot_pitch*2, 10],
                [first_slot+slot_pitch*3, 10],
                [first_slot+slot_pitch*4, 10],
                [first_slot+slot_pitch*5, 10],

                [first_slot+slot_pitch*8, 60], // Copper

                [first_slot+slot_pitch*11, 10],
                [first_slot+slot_pitch*12, 10],
                [first_slot+slot_pitch*13, 10],
                [first_slot+slot_pitch*14, 10],
                [first_slot+slot_pitch*15.5, 10],
                [first_slot+slot_pitch*16.5, 10],
                [first_slot+slot_pitch*17.5, 10],
                [first_slot+slot_pitch*18.5, 10],
                [first_slot+slot_pitch*19.5, 10],
                [first_slot+slot_pitch*20.5, 10],
                
                [first_slot+slot_pitch*22.5, 40], // Silver

               ];
               
section_data_2 = [[first_slot, 10],
                  [first_slot+slot_pitch, 10],
                  [first_slot+slot_pitch*2, 10],
                  [first_slot+slot_pitch*3, 10],
                  [first_slot+slot_pitch*4, 10],
                  [first_slot+slot_pitch*5, 10],
                  
                  [first_slot+slot_pitch*7.5, 30], // Curse

                  [first_slot+slot_pitch*10, 10],
                  [first_slot+slot_pitch*11, 10],
                  
                  [first_slot+slot_pitch*13, 32], // Bottom cards
                  
                  [first_slot+slot_pitch*14.7, 10], // Empty
                  [first_slot+slot_pitch*15.7, 10], // Empty
                  [first_slot+slot_pitch*17, 12], 
                  [first_slot+slot_pitch*18, 12],
                  [first_slot+slot_pitch*19.5, 12],
                  [first_slot+slot_pitch*21, 24],
                  
                  [first_slot+slot_pitch*22.8, 30], // Gold
               ];

module section(part) {
  difference() {
    cube([section_width, section_length, section_height]);
    translate([(section_width - cutout_width)/2, -1, cutout_bottom])
      cube([cutout_width, section_length+2, 100]);
    for (data = (part == 0) ? section_data : section_data_2) {
      translate([0, data[0], 0]) 
        slot(data[1]);
    }
  }
}

module middle() {
  difference() {
    cube([guide_width, section_length, section_height]);
    for (i = [-1, 1]) {
      for (j = [-2, -1, 0, 1, 2]) {
      translate([guide_width/2+(j*11.5), section_length/2-card_length/2+(i*65), 0])
      translate([0, -(section_width-card_length)/2, 0])
      rotate([0, 0, 90]) {
        slot(10);
        if (j == 0) 
          translate([(section_width - cutout_width)/2, -100, cutout_bottom])
            cube([cutout_width, section_length+2, 100]);
        }
      }
    }
  }
}

translate([section_width, 0, 0]) middle();
section(1);
translate([section_width + guide_width, 0, 0]) section(0);