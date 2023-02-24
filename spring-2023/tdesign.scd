// you only have to do one of these
~encoder = HoaMatrixEncoder.newDirection
HoaEncodeDirection.ar

~encoder = HoaMatrixEncoder.newDirections()

// tools for populating a sphere with equidistant points
SphericalDesign
TDesign

~td = TDesign.new(20);

~td.points;
~td.directions;

~td.visualize;

Klank // bank of resonators
Ringz // just one resonator

/**

Make a separate synthdef for:
- actual sound
- encoder
- transformer
-

*/