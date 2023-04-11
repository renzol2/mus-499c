Server.killAll
ServerOptions.outDevices

// Start everything
(
// Initialize server parameters
s.options.outDevice = 'Audio Out';
ServerTree.removeAll;
s.options.numOutputBusChannels = 24;
s.options.numWireBufs = 256;
s.options.memSize = 8192 * 4;
~order = 3;
~nch = HoaOrder.new(~order).size;

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

// Boot the server
s.waitForBoot({
	// Load the samples into buffers
	b = ();
	b.kulintang = PathName("samples/kulintang".resolveRelative).entries.collect({
	arg file;
	Buffer.readChannel(s, file.fullPath, channels:[0]);
});
	b.dabakan = PathName("samples/dabakan".resolveRelative).entries.collect({
		arg file;
		Buffer.readChannel(s, file.fullPath, channels:[0]);
	});
	b.babandir = PathName("samples/babandir".resolveRelative).entries.collect({
		arg file;
		Buffer.readChannel(s, file.fullPath, channels:[0]);
	});

	// Define playback SynthDefs
	SynthDef.new(\kulintang, {
		arg gongIndex, amp;

		var sig = Select.ar(gongIndex, [
			PlayBuf.ar(1, b.kulintang[0], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[1], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[2], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[3], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[4], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[5], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[6], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[7], doneAction: 2),
		]);

		sig = BPF.ar(sig, 1000, 3.0);

		sig = sig * amp;
		Out.ar(0, sig);
	}).add;

	// Define playback SynthDefs
	SynthDef.new(\kulintang_rtt, {
		arg gongIndex, amp;
		var sig, env, rtt;

		sig = Select.ar(gongIndex, [
			PlayBuf.ar(1, b.kulintang[0], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[1], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[2], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[3], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[4], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[5], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[6], doneAction: 2),
			PlayBuf.ar(1, b.kulintang[7], doneAction: 2),
		]);

		sig = BPF.ar(sig, 1000, 3.0);

		sig = sig * amp;

		// Define rotate-tilt-tumble envelope
		rtt = [
			Env([\rot0.ir(0), \rot1.ir(0)], [\rttdur.ir(1)], [\rotcrv.ir(0)]).kr,
			Env([\til0.ir(0), \til1.ir(0)], [\rttdur.ir(1)], [\tilcrv.ir(0)]).kr,
			Env([\tum0.ir(0), \tum1.ir(0)], [\rttdur.ir(1)], [\tumcrv.ir(0)]).kr
		];

		// Encode and apply transformation
		sig = HoaEncodeDirection.ar(sig, \az.ir(0), \el.ir(0), AtkHoa.refRadius, ~order);
		sig = HoaRTT.ar(sig, rtt[0], rtt[1], rtt[2], ~order);

		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef.new(\dabakan, {
		arg index, amp;

		var sig = Select.ar(index, [
			PlayBuf.ar(1, b.dabakan[0], doneAction: 2),
			PlayBuf.ar(1, b.dabakan[1], doneAction: 2),
			PlayBuf.ar(1, b.dabakan[2], doneAction: 2),
			PlayBuf.ar(1, b.dabakan[3], doneAction: 2),
		]);

		sig = sig * amp;
		Out.ar(1, sig);
	}).add;

	SynthDef.new(\babandir, {
		arg index, amp;

		var sig = Select.ar(index, [
			PlayBuf.ar(1, b.babandir[0], doneAction: 2),
			PlayBuf.ar(1, b.babandir[1], doneAction: 2),
			PlayBuf.ar(1, b.babandir[2], doneAction: 2),
			PlayBuf.ar(1, b.babandir[3], doneAction: 2),
		]);

		sig = sig * amp;
		Out.ar(1, sig);
	}).add;

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

	// Define delay effect
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
		// sig = sig + (wet * \mix.kr(0.2));
		// TODO: add a dry mix
		sig = (wet * \mix.kr(0.2));
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
		~dec = Synth(\dec, [in: ~bus.toDec, out: 3], s, \addToTail);
	};

	ServerTree.add(~init);
	ServerTree.run;
});
)


// Setup callback to listen to OscMessages from musx
(
~global_rtt = { rrand(pi.neg, pi) } ! 3;
~prevGongIndex = -1;
~prevSynth = nil;
OSCdef.new(
	key: \kulintang,
	func: {
		|msg, time, from, port|
		var amp = msg[4] * exprand(0.2, 0.3) * 0.4;
		var gongIndex = msg[1] - 1;
		var rtt = { rrand(pi.neg, pi) } ! 3;
		var rtt_shift = { exprand(pi/20, 3pi/2) * [1,-1].choose }.dup(3);
		var sus = exprand(0.05, 10);

		// if (~prevGongIndex == gongIndex, {
		// 	~prevSynth.free;
		// });

		~prevSynth = Synth.new(\kulintang_rtt, [
			gongIndex: gongIndex,
			amp: amp,
			atk: 0.001,
			// rel: exprand(0.1, 1.0),
			rel: 1.0,
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
		]);
		// ~prevGongIndex = gongIndex;
	},
	path: '/musx/kulintang',
	srcID: nil,
	recvPort: NetAddr.langPort
);

OSCdef.new(
	key: \dabakan,
	func: {
		|msg, time, from, port|
		var amp = msg[4] * exprand(0.2, 0.3);
		var index = msg[1] - 1;
		Synth.new(\dabakan, [
			\index: index,
			\amp: amp,
		]);
	},
	path: '/musx/dabakan',
	srcID: nil,
	recvPort: NetAddr.langPort
);

~prevBabandirIndex = -1;
~prevBabandirSynth = nil;
OSCdef.new(
	key: \babandir,
	func: {
		|msg, time, from, port|
		var amp = msg[4] * exprand(0.2, 0.3);
		var index = msg[1] - 1;
		if (~prevBabandirIndex == index, {
			~prevBabandirSynth.free;
		});
		~prevBabandirSynth = Synth.new(\babandir, [
			\index: index,
			\amp: amp,
		]);
		~prevBabandirIndex = index;
	},
	path: '/musx/babandir',
	srcID: nil,
	recvPort: NetAddr.langPort
);
)

~delay.set(\mix, 1.0);
~delay.set(\mix, 0.2);
~delay.set(\fb, 0.8);
(
~delay.set(
	\lfoAllpassFreq, rrand(0.1, 0.2),
	\lfoCombFreq, rrand(0.1, 0.19),
	// \lfoAllpassFreq, 0.8,
	// \lfoCombFreq, 0.81,
	\minDelayTime, 0.1,
	\maxDelayTime, 0.2,
	\decayTime, 2,
);
)



// Show scope
s.scope;

// Stop server
s.quit();
