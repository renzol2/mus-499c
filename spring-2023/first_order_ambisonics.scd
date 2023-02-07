QuarksGui.new;
(
("The ATK quark component % installed!").format(
    Quarks.isInstalled("atk-sc3").if({
        "is"
    }, {
        "isn't"
    })
).postln
)


AtkFoa.defaultOrder.postln;  // -> 1
AtkFoa.ordering.postln;  // -> fuma
AtkFoa.normalisation.postln;  // -> fuma
AtkFoa.refRadius.postln;  // -> inf

AtkHoa.defaultOrder.postln;  // -> 3
AtkHoa.ordering.postln;  // -> acn
AtkHoa.normalisation.postln;  // -> n3d
AtkHoa.refRadius.postln;  // -> 1.5

(
/*
Turn to page 2 & find

Figure 1: SKEW-TETRAHEDRAL LOUDSPEAKER LAYOUT
Figure 2: BASIC EXPERIMENTAL SET-UP
*/
"https://intothesoundfield.music.ox.ac.uk/sites/default/files/intothesoundfield/documents/media/tetrahedral_1.pdf".openOS
)

// Notes 1/26/2023

/**
Mid-side for one dimension
W = omnidirecitonal
X = bidirectional

[W X] * [ 1  1 ] = [L R]
          1 -1

Mid-side for two dimensions
Y = another bidirectional
[W, X, Y] * [ 1, 1, 1, 1 ] = [F, L, B, R]
              1, 0,-1, 1
              0, 1, 0,-1

(counter clockwise)
[W, X, Y] * [ 1, 1, 1, 1 ]                             = [FL, BL, BR, FR]
              cos(45), cos(135), cos(-135), cos(-45)
              sin(45), sin(135), sin(-135), sin(-45)

azimuth angle (horizontal angle), theta
elevation angle (vertical angle), phi

[W, X, Y, Z] * [ 1, 1, 1, 1, 1, 1 ] = [U, F, L, B, R, D]

B format -> 1st order Ambisonics
- Taking 4 signals and routing it to 3-dimensional space


**/

s.options.numOutputBusChannels = 8;
s.boot;

(
{
	var sig, encoder, decoder;
	sig = SinOsc.ar(200, mul: 0.2);
	encoder = FoaEncoderMatrix.newDirection(0, 0);  // right in front of us, on the horizon
	sig = FoaEncode.ar(sig, encoder);  // an actual UGen
	Out.ar(4, sig);
}.play;
)

(
{
	var sig, encoder, decoder;
	sig = SinOsc.ar(200, mul: 0.2);
	encoder = FoaEncoderMatrix.newDirection(45.degrad, 0);  // 45degrees to our left, on the horizon
	sig = FoaEncode.ar(sig, encoder);  // an actual UGen
	Out.ar(4, sig);
}.play;
)

(
{
	var sig, encoder, decoder;
	sig = SinOsc.ar(200, mul: 0.2);
	encoder = FoaEncoderMatrix.newDirection(135.degrad, 0);  // 135degrees to our left, on the horizon
	sig = FoaEncode.ar(sig, encoder);  // an actual UGen
	Out.ar(4, sig);
}.play;
)


