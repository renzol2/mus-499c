s.boot;

// ocean waves
(
~fn = {
	arg amp = 0.2;
	var sig, mod;
	mod = SinOsc.kr(freq: 1/4, mul: 0.5, add: 0.5);
	sig = PinkNoise.ar(amp ! 2);
	sig = sig * mod;
	sig = Limiter.ar(sig);  // apply limiter
};
)

x = ~fn.play;

(
~fn = {
	var sig0, sig1;
	sig0 = SinOsc.kr(freq: 1/4, mul: 0.5, add: 0.5);
	sig1 = PinkNoise.ar(amp ! 2);
	sig0 + sig1;  // last expression is always the output signal
};
)

{SinOsc.ar(freq: 400)}.plot;

(
~fn = {
	arg amp = 0.2;
	var sig, mod;
	mod = SinOsc.kr(freq: 1/4, mul: 0.5, add: 0.5);
	sig = PinkNoise.ar(amp ! 2);
	sig = sig * mod;
	sig = Limiter.ar(sig);  // apply limiter
};
)

x = ~fn.play;

// ocean waves but with range
(
~fn = {
	arg amp = 0.2;
	var sig, mod;
	mod = SinOsc.kr(freq: 1/4, phase: 3pi/2).range(0, 1);  // also see: unipolar, bipolar, exprange
	sig = PinkNoise.ar(amp ! 2);
	sig = sig * mod;
	sig = Limiter.ar(sig);  // apply limiter
};
)

x = ~fn.play;

{ SinOsc.ar(400).exprange(1, 2) }.plot;  // any exponential behavior should avoid 0's

// siren
(
~fn = {
	arg modwidth = 200;
	var sig, mod;
	mod = SinOsc.kr(freq: 5).bipolar(modwidth);
	sig = SinOsc.ar(freq: 300 + mod, mul: 0.1);
};
)

// Envelopes
// ---

// Envelopes are fully customizable shapes.
// Typically used to control amplitude (amp env), but can also be used to control frequency, density, or any parameter

Line, XLine, EnvGen

// For doneAction see:
Done

{XLine.kr(1, 0.001, 0.2)}.plot(0.2);

(
~fn = {
	var sig, env;
	sig = SinOsc.ar(2000, mul: 0.3) ! 2;
	env = XLine.kr(1, 0.001, 0.2, doneAction: 2);  // 2 - free the enclosing synth
	sig = sig * env;
};
)

x = ~fn.play;

// How do we create more complicated envelopes?
EnvGen, Env

(
e = Env(
	levels: [0, 1, 0.4, 0.6, 0],
	times: [0.5, 0.1, 2, 0.5],
	curve: [1],
);

e.plot;
)

(
~fn = {
	var sig, env;
	sig = SinOsc.ar(ExpRand(200, 1000), mul: 0.3);
	env = EnvGen.kr(
		envelope: Env(
			levels: [0, 1, 0.4, 0.6, 0],
			times: [0.5, 0.1, 2, 0.5],
			curve: [1],
		),
		doneAction: 2
	);
	sig = sig * env;
}
)

x = ~fn.play;

(
~fn = {
	arg gate = 1;
	var sig, env;
	sig = SinOsc.ar(ExpRand(200, 1000), mul: 0.3) ! 2;
	env = EnvGen.kr(
		envelope: Env(
			levels: [0, 1, 0.3, 0],
			times: [0.05, 0.6, 2],
			curve: [-3, -1, -1],
			releaseNode: 2
		),
		gate: gate,
		doneAction: 0
	);
	sig = sig * env;
};
)

x = ~fn.play;
x.set(\gate, 0);
x.set(\gate, 1);
x.free;

// annoying to switch gate values - how to do it in one go?
TrigControl
// arg needs a `t_` before it

(
~fn = {
	arg t_gate = 1;
	var sig, env;
	sig = SinOsc.ar(ExpRand(200, 1000), mul: 0.3) ! 2;
	env = EnvGen.kr(
		envelope: Env(
			levels: [0, 1, 0.3, 0],
			times: [0.05, 0.6, 2],
			curve: [-3, -1, -1],
			releaseNode: 2
		),
		gate: t_gate,
		doneAction: 2
	);
	sig = sig * env;
};
)

x = ~fn.play;
x.set(\t_gate, 1);


// Multichannel expansion
// s.options.numOutputBusChannels = 24;
// s.reboot;
// s.meter;

// { PinkNoise.ar([ 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07 ])}.play;

// See the difference:
{ PinkNoise.ar(0.1 ! 2) }.play;
{ PinkNoise.ar(0.1) ! 2 }.play;
