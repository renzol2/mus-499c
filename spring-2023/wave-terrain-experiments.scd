(
s.boot;
s.scope;
s.freqscope;
)

// function for wave terrain example

f = { |x, y| sin(x) - (sin(y) * log(x * x + 1)) / 10 };

// check the surface produced by the function with GeoGebra

// copy and paste this syntax into GeoGebra Input, it needs ln for the natural logarithm
// (sin(x) - (sin(y) * ln(x * x + 1))) / 10


// circular path through the terrain, mouse control for distance from origin

(
x = {
	var r = MouseX.kr(0, 25);
	// stereo expansion
	var phi = LFSaw.ar([50, 50.1], -1).range(0, 2pi).poll;
	var x = r * cos(phi);
	var y = r * sin(phi);
	var sig = f.(x, y);

	sig = sig * 0.2;
	Limiter.ar(sig, 0.2)
}.play
)

x.release

// bunch of functions
z = { |x, y| (x - y) * (x - 1) * (x + 1) * (y - 1) * (y + 1) }
z = { |x, y| sin(1 - x ** 2) * sin(1 - y ** 2) * (1 - y ** 2) * x }
z = { |x, y| sin(x) * sin(y) * (x - y) * (x - y) * (x - 1) * (x + 1) * (y - 1) * (y + 1) }
z = { |x, y| 0 }

// with mouse control
(
SynthDef.new(\tera, {
	var lfo1 = SinOsc.kr(1) * 4;
	var lfo2 = SinOsc.kr(2.3) * 3;
	var rx = MouseX.kr(0, 5 + lfo1);
	var ry = MouseY.kr(0, 5 + lfo2);
	var cx = MouseX.kr(-5, 5 + lfo1);
	var cy = MouseY.kr(-5, 5 + lfo2);
	var phi = LFSaw.ar([\freq.kr(50), \freq.kr(50) + 0.1]).range(0, 2pi);
	var x = rx * cos(phi + pi / 4);
	var y = ry * sin(phi);

	var env = EnvGen.kr(
        envelope: Env.perc(
            attackTime: \attackTime.kr(0.1),
            releaseTime: \releaseTime.kr(0.1),
        ),
        doneAction: 2,
    );

	var sig = Limiter.ar(z.(x, y), 0.5);
	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add
)

// no mouse control
(
SynthDef.new(\tera2, {
	var lfo1 = SinOsc.kr(1 / 3.2) * 0.2;
	var lfo2 = SinOsc.kr(1 / 2) * 1;
	var rx = SinOsc.kr(1 / 10).range(0, 5 + lfo1);
	var ry = SinOsc.kr(1.1 / 3).range(0, 5 + lfo2);
	var cx = SinOsc.kr(1.2 / 4).range(-5, 5 + lfo1);
	var cy = SinOsc.kr(1.3 / 5).range(-5, 5 + lfo2);
	var phi = LFSaw.ar([\freq.kr(50), \freq.kr(50) + 0.1]).range(0, 2pi);
	var x = cx + (rx * cos(phi + pi / 4));
	var y = cy + (ry * sin(phi));

	var env = EnvGen.kr(
        envelope: Env.perc(
            attackTime: \attackTime.kr(0.1),
            releaseTime: \releaseTime.kr(0.1),
        ),
        doneAction: 2,
    );

	var sig = Limiter.ar(z.(x, y), 0.5);
	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add
)

(
Synth.new(\tera, [
	amp: 0.2,
]);
)

(
Pbind(
	\instrument, \teraAmb,
	\freq, Prand([41, 410, 512.5], inf),
	\dur, Prand([1, 1/4, 1/8, 1/16, 1/32], inf),
	\amp, Prand([0.05], inf),
	\attackTime, Prand([1], inf),
	\releaseTime, Prand([3], inf),
).play;
)

(
~directions = [
		[36,54],[108,54],[180,54],[-108,54],[-36,54], // ceiling ring, ch 0-4
		[36,18],[108,18],[180,18],[-108,18],[-36,18], // ring above horizon, ch 5-9
		[0,-18],[72,-18],[144,-18],[-144,-18],[-72,-18], // ring below horizon, ch 10-14
		[0,-54],[72,-54],[144,-54],[-144,-54],[-72,-54] // floor ring, ch 15-19
];
~encoder = HoaMatrixEncoder.newDirection(0.degrad, 0.degrad, \energy, 1);
~foaToHoa = HoaMatrixEncoder.newFormat(AtkFoa.format, AtkFoa.defaultOrder);
~decoder = HoaMatrixDecoder.newModeMatch(
	directions: ~directions.degrad,
	beamShape: \energy,
	match: \energy,
	order: 1
);

)

// no mouse control, ambisonics
(
SynthDef.new(\teraAmb, {
	var lfo1 = (SinOsc.kr(1 / 3.2) + BrownNoise.kr(0.3)) * 0.2;
	var lfo2 = SinOsc.kr(1 / 2) * 1;
	var rx = SinOsc.kr(1 / 10).range(0, 5 + lfo1);
	var ry = SinOsc.kr(1.1 / 3).range(0, 5 + lfo2);
	var cx = SinOsc.kr(1.2 / 4).range(-5, 5 + lfo1);
	var cy = SinOsc.kr(1.3 / 5).range(-5, 5 + lfo2);
	var phi = LFSaw.ar([\freq.kr(50), \freq.kr(50) + 0.1]).range(0, 2pi);
	var x = cx + (rx * cos(phi + pi / 4));
	var y = cy + (ry * sin(phi));

	var env = EnvGen.kr(
        envelope: Env.perc(
            attackTime: \attackTime.kr(0.1),
            releaseTime: \releaseTime.kr(0.1),
        ),
        doneAction: 2,
    );

	var sig = Limiter.ar(z.(x, y), 0.5);
	sig = sig * env;
	sig = sig * \amp.kr(1);

	// Encode
	sig = HoaEncodeMatrix.ar(
		in: sig[0],
		hoaMatrix: HoaMatrixEncoder.newDirection(-180.degrad, 0.degrad, \energy, 1)
	);


	// Transform with modulated Zoom transformer
	// sig = HoaZoom.ar(
	// 	in: sig,
	// 	angle: SinOsc.kr(SinOsc.kr(1/20).range(-0.2, 0.2)).range(-89, 89).degrad,
	// 	theta: SinOsc.kr(1/21, pi / 2).range(-45, 45).degrad,
	// 	phi: SinOsc.kr(1/10).range(-45, 90).degrad,
	// 	// angle: 0,
	// 	// theta: 0,
	// 	// phi: 0,
	// 	order: 1
	// );

	// Tilt and tumble with the mouse, for fun!
	// Best when the magnitude of the distortion angle of HoaZoom goes high
	sig = HoaTilt.ar(sig,
		angle: MouseX.kr(-90, 90).poll.degrad,
		order: 1
	);
	sig = HoaTumble.ar(sig,
		angle: MouseY.kr(-90, 90).poll.degrad,
		order: 1
	);
	sig = HoaDecodeMatrix.ar(sig, ~decoder);
	Out.ar(\out.kr(0), sig);
}).add
)