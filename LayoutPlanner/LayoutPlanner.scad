/* Layout builder */

h=2.5;
w=11.5;

/* Layout keywords have variable number of parameters and the last element
   is the rest of the layout (usually).
   
   "s", l: straight section, length l
   "c", r, d: curved section, radius l, degrees of curvature d
   "t", b1, b2: turnout, b1 and b2 are the two continuations of the track
   "f": flip around, continues the rest of the layout backwards. Used for
        trailing-point turnouts.

*/
industry =
  ["f", // Branch to industry, begins with a part of the curved turnout
  ["c", 195, 30,
  ["c", 145, 30,
  ["c", 145, 30,
  ["c", 145, 30,
  ["c", 145, 30,
  ["c", 145, 30,
]]]]]]];

yard = 
  ["t", // First turnout of the yard
    ["s", 110,
      ["c", 490, -13, 
      ["s", 55,
      ["s", 110,
      ["s", 110,
    ]]]]],
    ["c", 490, -13, 
      ["t", // Second turnout of the yard
        ["s", 110,
          ["s", 55,
          ["s", 110,
          ["s", 110, 
        ]]]],
        ["c", 490, -13, 
          ["t", // Third turnout of the yard
            ["s", 110,
              ["c", 490, 13, 
              ["s", 55,
              ["s", 110, ]]]],
            ["c", 490, 13, 
              ["s", 55, 
              ["s", 110, ]]
        ]],
      ]],
    ]
  ];
      
layout =
  ["s", 110,
  ["c", 490, 13,
  ["s", 110,
  ["s", 110,
  ["c", 195, 30,
  ["c", 195, 30,
  ["c", 195, 30,
  ["s", 25,
  ["t", // Curved turnout on the mainline
    ["f", 
    ["c", 195, -30,
    ["c", 195, -30,
    ["c", 195, -30,
    ["s", 25,
    ["t", // Curved turnout on the yard side
      industry,
      yard,
    ],
  ]]]]],
  ["c", 220, 45,
  ["c", 220, 45,
  ["s", 110,
  ["c", 490, -13, 
  ["s", 110*3.5,  
  ["c", 195, 45,
  ["c", 195, 45,
  ["s", 55,
  ["c", 195, 45,
  ["c", 195, 45,
  ["t",  ["c", 490, 13], ["s", 110,
  ]
  ]]]]]]]]]]]]]]]]]]]];


l2 =  ["c", 145, -45,
        ["s", 110, ["c", 145, 45, ]]];

function straight(pos, l) = [pos[0], pos[1]+l, pos[2]];

module draw_layout(lout) {
  translate([-w/2, -0.1, 0]) color("lightblue") cube([w, 0.2, h*2]);
  if (lout[0] == "s") {
    translate([-w/2, 0, 0])
      cube([w, lout[1], 2.5]);
    translate([0, lout[1], 0])
      draw_layout(lout[2]);
  }
  if (lout[0] == "c") {
    mirror([(lout[2] < 0 ? 1 : 0), 0, 0])
    translate([lout[1], 0, 0])
      difference() {
        intersection() {
          cylinder(h=h, r=lout[1]+w/2, $fn=64);
          rotate([0, 0, 90])
            cube([lout[1]+w/2, lout[1]+w/2, h+2]);
        }
        translate([0, 0, -1]) {          
          cylinder(h=h+2, r=lout[1]-w/2, $fn=64);
          rotate([0, 0, 90-abs(lout[2])])
            cube([lout[1]+w/2, lout[1]+w/2, h+2]);
        }
      }
    translate([(lout[2] < 0 ? -lout[1] : lout[1]), 0, 0])
      rotate([0, 0, -lout[2]])
        translate([(lout[2] < 0 ? lout[1] : -lout[1]), 0, 0])
          draw_layout(lout[3]);
  }
  if (lout[0] == "t") {
    draw_layout(lout[1]);
    draw_layout(lout[2]);
  }
  if (lout[0] == "f") {
    rotate([0, 0, 180])
      draw_layout(lout[1]);
  }
}

color("lightgray") translate([-80, -550, -1]) cube([608, 1212, 0.5]);
//draw_layout(l2);
draw_layout(layout);
