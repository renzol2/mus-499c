s.boot;

(
~fn = {
	arg gate = 1;
	var sig, env;
	sig = SinOsc.ar(ExpRand(200, 1000), mul: 0.2) ! 2;
	env = EnvGen.kr(
		Env(
			[0, 1, 0.3, 0],
			[0.02, 0.3, 1],
			[-2, -4, -4],
			2
		),
		gate,
		doneAction: 2
	);
	sig = sig * env;
};
)

x = ~fn.play;

x.set(\gate, 0);

(
SynthDef.new(\tone, {
    arg gate = 1, freq = 400, amp = 0.2, out = 0;
	var sig, env;
	sig = SinOsc.ar(ExpRand(200,1000)) ! 2;
	env = EnvGen.kr(
		Env(
			[0, 1, 0.3, 0],
			[0.02, 0.3, 1],
			[-2, -4, -4],
			2
		).poll(10),
		\gate.kr(1),
		doneAction: 2
    );
	sig = sig * env;
	sig = sig * \amp.kr(0.2);
	Out.ar(\out.kr(0), sig);
}).add;
)

x = Synth.new(\tone1, [gate: 1]);

x = Synth.new(\tone, [gate: 1, freq: 72.midicps, amp: -12.dbamp]);
x.set(\freq, 80.midicps);
x.set(\amp, -18.dbamp);
x.set(\gate, 0);

-24.dbamp;
0.5.ampdb;
400.cpsmidi;

s.meter;
{SinOsc.ar(400)}.plot(0.05);
s.scope;
s.volume.gui;
s.plotTree;
s.makeGui;

//////////////////////////////////////////////

b = Buffer.read(s, "/Users/eli/Documents/Illinois/Teaching/AY 2022-2023/Fall 2022/MUS 499C/Lecture Code/Week05_2022-09-22/audio/flower_pot.aiff");

b.play;

b.plot;

b.duration;
b.sampleRate;

s.sampleRate;

b.query;
b.numChannels;

b.free;

Buffer.freeAll;

(
SynthDef.new(\play, {
	var sig, env;

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		trigger:
		startPos: \spos.kr(0),
		loop: 0
	);

	env = EnvGen.kr(
		Env(
			[0, 1, 0],
			[0.02, 3],
			[-2, -4],
		),
		doneAction: 2
	);
	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;
)

(
Synth.new(
	\play,
	[
		buf: b.bufnum,
		rate: 0.midiratio,
		amp: 5,
		spos: b.sampleRate * 22
	]
);
)