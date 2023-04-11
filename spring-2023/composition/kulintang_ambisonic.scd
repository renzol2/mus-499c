Server.killAll;  // kill server to free memory?
ServerOptions.outDevices;
s.options.outDevice = 'Audio Out';

(
ServerTree.removeAll;
s.options.numOutputBusChannels = 24;
s.options.numWireBufs = 256;
s.options.memSize = 8192 * 4;
~order = 3;
~nch = HoaOrder.new(~order).size; // always 16 if working in 3rd order

// for 3D spatialization of filtered pink noise
~td = TDesign.new(32);
~td_encoder = HoaMatrixEncoder.newModeMatch(
	directions: ~td.directions,
	beamShape: \energy,
	match: \energy,
	order: ~order
);

s.newBusAllocators;
~bus = ();
~bus.monoIn = Bus.audio(s, 1);
~bus.stereoIn = Bus.audio(s, 2);
~bus.toRev = Bus.audio(s, ~nch);
~bus.toDelay = Bus.audio(s, ~nch);
~bus.toDec = Bus.audio(s, ~nch);

~directions = [
	// 1 - 5
	[36, 75], [108, 75], [180, 75], [-108, 75], [-36, 75],

	// 6 - 10
	[36, 20], [108, 20], [180, 20], [-108, 20], [-36, 20],

	// 11 - 15
	[0, -20], [72, -20], [144, -20], [-144, -20], [-72, -20],

	// 16 - 20
	[0, -75], [72, -75], [144, -75], [-144, -75], [-72, -75],
].degrad;

// decoder for dodecahedron loudspeaker array
~decoder = HoaMatrixDecoder.newModeMatch(
	directions: ~directions,
	beamShape: \energy,
	match: \energy,
	order: ~order
);

s.waitForBoot({

	b = ();
	b.kulintang = PathName("kulintang".resolveRelative).entries.collect({
		arg file;
		Buffer.readChannel(s, file.fullPath, channels:[0]);
	});
	b.percussion = PathName("percussion".resolveRelative).entries.collect({
		arg file;
		Buffer.readChannel(s, file.fullPath, channels:[1]);
	});

	// encode a mono point source in 3rd order ambisonic format
	// and apply random rotate-tilt-tumble to the soundfield
	SynthDef(\mono_rtt, {
		var sig, env, rtt;
		sig = PlayBuf.ar(
			numChannels: 1,
			bufnum: \buf.ir(0),
			rate: \rate.ir(1) * BufRateScale.ir(\buf.ir(0)),
			startPos: \spos.ir(0),
			loop: \loop.ir(1)
		);
		sig = RLPF.ar(sig, ExpRand(200, 18000), Rand(0.5, 0.8));
		env = Env.asr(
			\atk.ir(0.01), \slev.ir(1), \rel.ir(0.2), [1, 0, -1]
		).kr(2, \gate.kr(1));
		sig = sig * env * \amp.kr(0.5);

		// each axial rotation controlled by an envelope,
		// randomly determined when a Synth is created
		rtt = [
			Env([\rot0.ir(0), \rot1.ir(0)], [\rttdur.ir(1)], [\rotcrv.ir(0)]).kr,
			Env([\til0.ir(0), \til1.ir(0)], [\rttdur.ir(1)], [\tilcrv.ir(0)]).kr,
			Env([\tum0.ir(0), \tum1.ir(0)], [\rttdur.ir(1)], [\tumcrv.ir(0)]).kr
		];

		sig = HoaEncodeDirection.ar(sig, \az.ir(0), \el.ir(0), AtkHoa.refRadius, ~order);
		sig = HoaRTT.ar(sig, rtt[0], rtt[1], rtt[2], ~order);

		Out.ar(\out.ir(0), sig);
	}).add;

	// an experiment! reverb uniquely (but similarly) applied
	// to each channel of the B-format signal...is this technically
	// an "ambisonic" reverb effect? who knows?! I don't *dislike* how it sounds...
	// SynthDef(\reverb, {
	// 	var sig, wet;
	// 	sig = In.ar(\in.ir(0), ~nch);
	// 	wet = LocalIn.ar(~nch) + sig;
	// 	wet = DelayL.ar(wet, 0.03, 0.03);
	// 	5.do({ |n|
	// 		var del, coef, dec;
	// 		del = { Rand(0.1 / (n + 2), 0.1 / (n + 1)) } ! ~nch;
	// 		coef = Rand(0.6, 0.75);
	// 		dec = del / (log10(coef) / 3.neg);
	// 		wet = AllpassL.ar(wet, 0.1, del, dec);
	// 	});
	// 	LocalOut.ar(wet * \fb.kr(0.8));
	// 	sig = sig + (wet * \mix.kr(0.2));
	// 	Out.ar(\out.ir(0), sig);
	// }).add;

	SynthDef(\delay, {
		var sig, wet, apf, cmbf;
		sig = In.ar(\in.ir(0), ~nch);
		wet = LocalIn.ar(~nch) + sig;

		apf = AllpassL.ar(
			in: sig,
			maxdelaytime: \maxDelayTime.kr(2),
			delaytime: SinOsc.kr(\lfoAllpassFreq.kr(1/10)).range(\minDelayTime.kr(0.02), 3),
			decaytime: \decayTime.kr(2)
		);

		cmbf = CombL.ar(
			in: sig,
			maxdelaytime: \maxDelayTime.kr(2),
			delaytime: SinOsc.kr(\lfoCombFreq.kr(1/10)).range(\minDelayTime.kr(0.02), 3),
			decaytime: \decayTime.kr(2)
		);

		wet = apf + cmbf;

		LocalOut.ar(wet * \fb.kr(0.8));
		sig = sig + (wet * \mix.kr(0.2));
		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\dec, {
		var sig;
		sig = In.ar(\in.ir(0), ~nch);
		sig = HoaDecodeMatrix.ar(sig, ~decoder);
		Out.ar(\out.ir(0), sig);
	}).add;

	s.sync;

	~init = {
		// ~reverb = Synth(\reverb, [in: ~bus.toRev, fb: 0.99, mix: 0.3, out: ~bus.toDec]);
		~delay = Synth(\delay, [in: ~bus.toDelay, out: ~bus.toDec]);
		~dec = Synth(\dec, [in: ~bus.toDec, out: 0], s, \addToTail);
	};

	ServerTree.add(~init);
	ServerTree.run;
});
)

(
~global_rtt = { rrand(pi.neg, pi) } ! 3;
// play kulintang sounds
Tdef(\kulintang, {
	loop{
		var buf = b.kulintang.choose;
		var rtt = { rrand(pi.neg, pi) } ! 3;
		var rtt_shift = { exprand(pi/20, 3pi/2) * [1,-1].choose }.dup(3);
		var sus = exprand(0.05, 10);

		(
			instrument: \mono_rtt,
			// amp: exprand(0.01, 0.1),
			amp: 0.07,
			sustain: sus,
			buf: buf,
			// rate: [rrand(-7, 7.0), rrand(-20.0, -16)].wchoose([0.94, 0.06]).midiratio,
			// rate: rrand(-1.5, 1.5),
			// rate: [1, -1].wchoose([0.7, 0.3]),
			rate: 1,
			// startPos: rrand(0, buf.numFrames - 1),
			startPos: 0,
			atk: 0.001,
			rel: exprand(0.1, 1.0),
			rot0: ~global_rtt[0],
			rot1: ~global_rtt[0] + rtt_shift[0],
			til0: ~global_rtt[1],
			til1: ~global_rtt[1] + rtt_shift[1],
			tum0: ~global_rtt[2],
			tum1: ~global_rtt[2] + rtt_shift[2],
			rttdur: sus,
			az: rrand(pi.neg, pi),
			el: rrand(pi.neg, pi) / 2,
			out: ~bus.toDelay
		).play;

		wait(([0.5, 1]).wchoose([0.25, 0.5]));
	};
});
)
(
// play percussion sounds
Tdef(\percussion, {
	loop{
		var buf = b.percussion.choose;
		var rtt = { rrand(pi.neg, pi) } ! 3;
		var rtt_shift = { exprand(pi/10, 3pi/2) * [1,-1].choose }.dup(3);
		var sus = exprand(0.05, 10);

		(
			instrument: \mono_rtt,
			amp: exprand(0.01, 0.1),
			sustain: sus,
			buf: buf,
			// rate: [rrand(-7, 7.0), rrand(-20.0, -16)].wchoose([0.94, 0.06]).midiratio,
			rate: rrand(-1.5, 1.5),
			// rate: [1, -1].wchoose([0.7, 0.2, 0.1]),
			// startPos: rrand(0, buf.numFrames - 1),
			startPos: 0,
			atk: 0.001,
			rel: exprand(0.1, 4.0),
			rot0: rtt[0],
			rot1: rtt[0] + rtt_shift[0],
			til0: rtt[1],
			til1: rtt[1] + rtt_shift[1],
			tum0: rtt[2],
			tum1: rtt[2] + rtt_shift[2],
			rttdur: sus,
			az: rrand(pi.neg, pi),
			el: rrand(pi.neg, pi) / 2,
			out: ~bus.toDelay
		).play;

		wait(exprand(0.01, 1));
	};
});

Tdef(\kulintang).play;
Tdef(\percussion).play;
)

Tdef(\kulintang).stop;
Tdef(\percussion).stop;



~delay.set(\mix, 0.4);
~delay.set(\mix, 0.2);
~delay.set(\fb, 0.8);
(
~delay.set(
	\lfoAllpassFreq, rrand(0.1, 0.51),
	\lfoCombFreq, rrand(0.1, 0.5),
	// \lfoAllpassFreq, 0.8,
	// \lfoCombFreq, 0.81,
	\minDelaytime, 0.001,
	\maxDelayTime, 0.2,
	\decayTime, 2,
);
)
