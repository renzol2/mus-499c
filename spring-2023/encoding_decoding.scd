// use HOA toolkit since it's more recent

// workflow:
// - have some sound
// - encode the sound into an ambisonic signal
// - transform the signal using operations, with changes its position in virtual space
// - decode from spherical format to discrete channel outputs
// - playback/monitoring

// let's encode a single signal into third order ambisonics

(
s.options.numOutputBusChannels = 24;
s.options.numWireBufs = 256;
s.boot;
)

// theta -> horizontal angle
// phi -> vertical angle
// use radians, use .degrad for conversion
// beamShape can be \basic, \energy, \controlled
// order -> x-order ambisonic
~encoder = HoaMatrixEncoder.newDirection(90.degrad, 20.degrad, \energy, 3);

// directions is an array of arrays. provide the azimuth and elevation for each direction
// HOMEWORK: make the directions array LOL
// 20 loudspeakers total
(
~decoder = HoaMatrixDecoder.newModeMatch([
	[36, 54],
	[72, 54],
	[0, 0],
	[0, 0]
].degrad, \energy, \energy, 3);
)

(
SynthDef.new(\dir, {
	var sig;
	sig = PinkNoise.ar(0.5);
	// The below line does the same as the encoder above, but in "UGen-land"
	// /*sig = HoaEncodeDirection.ar(sig, \theta.ir(0), \phi.ir(0), AtkHoa.refRadius, 3);*/

	sig = HoaEncodeMatrix.ar(sig, ~encoder);
	// Use this for transforming stuff
	// sig = HoaMatrixXformer.newRTT();
	sig = HoaDecodeMatrix.ar(sig, ~decoder);
}).add;
)

Synth(\dir, [theta: 55.degrad, phi: -20.degrad]);