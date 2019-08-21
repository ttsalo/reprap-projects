/* Rover by Tomi T. Salo <ttsalo@iki.fi> 2019. */

/* Rocker-bogey Mars-style rover.
   
   Coordinate system:
   X: widthwise of the rover, zero is centerline
   Y: lengthwise of the rover, zero is rocker pivot axis
   Z: heightwise of the rover, zero is wheel axis level
   
   Final vehicle approx specs:
   Wheel dia 80mm
   Track width 240mm
   Total wheelbase 320mm
   Max speed 100mm/s -> Wheel RPM 23.4
   Motor ZGY370 30 RPM 2.7 kg.cm -> 6.6 N/wheel -> 39.4 N tot
   
   Project plan:
   1. Develop unpowered scale model to verify the geometry, joints etc.
   2. Develop final model drivetrain with interchangeable chassis
   3. Develop chassis for all the electronics
   
*/

use <PyramidSpaceTruss.scad>;

lh = 0.3;   // layer height
tol = 0.2;  // tight tolerance
fit = 0.4;  // loose fit tolerance

bogey_pivot = 50; // Bogey pivot offset from rocker pivot
wheel1 = 80; // Front wheel offset from rocker pivot
wheel2 = 30; // Middle wheel offset from rocker pivot
wheel3 = -20; // Back wheel offset from rocker pivot
