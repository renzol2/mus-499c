s.boot;

b = Buffer.read(s, "/Users/eli/Documents/Illinois/Teaching/AY 2022-2023/Fall 2022/MUS 499C/Lecture Code/Week06_2022-09-29/audio/prayer_bowl.aiff");

Buffer.freeAll;

b.play;

b = Buffer.read(s, "audio/prayer_bowl.aiff".resolveRelative);

PathName.new(thisProcess.nowExecutingPath).parentPath ++ "audio/prayer_bowl.aiff";

(
~path = PathName.new(thisProcess.nowExecutingPath).parentPath ++ "audio/prayer_bowl.aiff";
b = Buffer.read(s, ~path);
)


(
SynthDef.new(\play, {
	var sig, env;

	sig = PlayBuf.ar(
		numChannels: 1,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		startPos: \spos.kr(0),
		loop: \loop.ir(0)
	);

	sig = LPF.ar(sig, \lpf.ir(20000).clip(20, 20000));
	sig = HPF.ar(sig, \hpf.ir(20).clip(20, 20000));

	env = EnvGen.kr(
		Env(
			levels: [0, 1, 0],
			times: [\atk.ir(0.02), \rel.ir(3)],
			curve: [-2, -4],
		),
		doneAction: 2
	);

	sig = Pan2.ar(sig, \pan.kr(0));
	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;
)

(
var scale = [0, 3, 5, 7, 10];
Array.fill(8, {scale.choose}).do({ |n|
	n = n + [11, 12, 0, -12, -24, -36].choose;
	Synth.new(
		\play,
		[
			buf: b.bufnum,
			rate: n.midiratio
			* rrand(-0.2, 0.2).midiratio
			* [1, -1].choose,
			pan: rrand(-0.8, 0.8),
			atk: exprand(0.002, 0.2),
			rel: exprand(3, 10),
			spos: s.sampleRate * rrand(2.0, 4.0),
			loop: 1,
			amp: 1,
			hpf: 20,
		]
	);
});
)


x = [10, 20, 30, 40, 50]
x[[1,2,3]]



(
var scale = [0, 3, 5, 7, 10];
var coll;
coll = scale.scramble;
coll = coll ++ scale.scramble[[0,1,2]];
coll.do({ |n|
	n = n + [11, 12, 0, -12, -24, -36].choose;
	Synth.new(
		\play,
		[
			buf: b.bufnum,
			rate: n.midiratio
			* rrand(-0.2, 0.2).midiratio
			* [1, -1].choose,
			pan: rrand(-0.8, 0.8),
			atk: exprand(0.002, 0.2),
			rel: exprand(3, 10),
			spos: s.sampleRate * rrand(2.0, 4.0),
			loop: 1,
			amp: 1,
		]
	);
});
)

(
r = Routine.new({

	[-3, 0, 2].do({ |n|
		Synth.new(
			\play,
			[
				buf: b.bufnum,
				rate: n.midiratio
				* rrand(-0.2, 0.2).midiratio,
				pan: rrand(-0.8, 0.8),
				atk: exprand(0.002, 0.2),
				rel: exprand(3, 10),
			]
		);

		yield(rrand(0.1, 0.7));

	});

});
)

r.play;

r.reset;
s.scope;


b = Buffer.read(s, "C:/Users/Renzo Ledesma/Documents/production/samples/headbop_rnb_chords_108_BPM_C_Maj_no_sidechain.wav");
b.play

(
{
	var sig, cf;
	sig = PlayBuf.ar(2, b, loop:1);
	cf = RLPF.ar(sig, MouseX.kr(50, 1500).poll, MouseY.kr(0.2, 20));
    cf = Limiter.ar(cf);
}.play
)

