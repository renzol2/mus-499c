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
	Limiter.ar(f.(x, y), 0.2)
}.play
)

x.release

// bunch of functions
z = { |x, y| (x - y) * (x - 1) * (x + 1) * (y - 1) * (y + 1) }
z = { |x, y| sin(1 - x ** 2) * sin(1 - y ** 2) * (1 - y ** 2) * x }
z = { |x, y| sin(x) * sin(y) * (x - y) * (x - y) * (x - 1) * (x + 1) * (y - 1) * (y + 1) }

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
	amp: 0.1,
]);
)

(
Pbind(
	\instrument, \tera,
	\freq, Prand([-3, 0, 2, 4, 7, 11].collect({|x| (x + 50).midicps }), inf),
	\dur, Prand([1/4, 1/8, 1/16] / 2, inf),
	\amp, Prand([0.05, 0.1, 0.24, 0.4], inf),
	\attackTime, 0.15,
	\releaseTime, 0.3,
).play;
)