ServerOptions.outDevices
s.quit()
s.boot
Server.killAll

// Start everything
(
// Initialize server parameters
// s.options.outDevice = "ExtronScalerD";  // change in Z
s.options.outDevice = 'Audio Out';
ServerTree.removeAll;
s.options.numOutputBusChannels = 24;
s.options.numWireBufs = 256;
s.options.memSize = 2 ** 20;
~order = 3;
~nch = HoaOrder.new(~order).size;

s.newBusAllocators;
~bus = ();
~bus.monoIn = Bus.audio(s, 1);
~bus.stereoIn = Bus.audio(s, 2);
~bus.toZoom = Bus.audio(s, ~nch);
~bus.toDelay = Bus.audio(s, ~nch);
~bus.toRev = Bus.audio(s, ~nch);
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

~eightChDirections = [
	[-45,0],  // FL
	[45,0],   // FR
	[-90,0],  // SL
	[90,0],   // SR
	[-135,0], // BL
	[135,0],  // BR
	[0,0],    // FC
	[180,0],  // BC
].degrad;

// decoder for dodecahedron loudspeaker array
~decoder = HoaMatrixDecoder.newModeMatch(
	directions: ~directions,
	beamShape: \energy,
	match: \energy,
	order: ~order
);

// decoder for 8 channel ring
~eightChDecoder = HoaMatrixDecoder.newModeMatch(
	directions: ~eightChDirections,
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
	SynthDef.new(\play_rtt, {
		arg bufnum, amp, rate;
		var sig, env, rtt;

		sig = PlayBuf.ar(1, bufnum, rate: BufRateScale.ir(bufnum) * rate, doneAction: 2);

		sig = LPF.ar(sig, freq: 7000);  // rq should never go above 1.0

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

	// Define delay effect
	SynthDef(\delay, {
		var sig, wet, apf, cmbf;
		sig = In.ar(\in.ir(0), ~nch);
		wet = LocalIn.ar(~nch) + sig;

		apf = AllpassC.ar(
			in: sig,
			maxdelaytime: 2,
			delaytime: SinOsc.kr(\lfoAllpassFreq.kr(1/10)).range(\minDelayTime.kr(0.02), \maxDelayTime.kr(2)),
			decaytime: VarLag.kr(\decayTime.kr(2), \decayTimeLag.kr(2), \decayTimeCurve.kr(5), \decayTimeWarp.kr(\lin)),
			// lag, varlag on args
			// provide argument for lagtime
		);

		cmbf = CombC.ar(
			in: sig,
			maxdelaytime: 2,
			delaytime: SinOsc.kr(\lfoCombFreq.kr(1/10)).range(\minDelayTime.kr(0.02), \maxDelayTime.kr(2)),
			decaytime: \decayTime.kr(2)
		);

		wet = apf + cmbf;

		LocalOut.ar(wet * VarLag.kr(\fb.kr(0.8), \fbLag.kr(2), \fbCurve.kr(5), \fbWarp.kr(\lin)));
		sig = (sig * \dryMix.kr(1.0)) + (wet * \wetMix.kr(0.2));
		sig = Limiter.ar(sig, 0.9);
		Out.ar(\out.ir(0), sig);
	}).add;

	// SynthDef(\zoom, {
	// 	var sig;
	// 	sig = In.ar(\in.ir(0), ~nch);
	//
	// 	sig = HoaZoom.ar(
	// 		in: sig,
	// 		angle: VarLag.kr(\distortionAngle.kr(0), \distortionTime.kr(1)),
	// 		theta: \theta.kr(0),
	// 		phi: \phi.kr(0),
	// 		radius: 1.5 // FIXME: change this?
	// 	);
	//
	// 	Out.ar(\out.ir(0), sig);
	// }).add;

	SynthDef(\reverb, {
		var sig;
		sig = In.ar(\in.ir(0), ~nch);

		sig = FreeVerb.ar(sig, mix: 0.4, room: 0.8, damp: 0.3);

		Out.ar(\out.ir(0), sig);
	}).add;

	SynthDef(\dec, {
		var sig;
		sig = In.ar(\in.ir(0), ~nch);
		sig = HoaDecodeMatrix.ar(sig, ~eightChDecoder);

		Out.ar(\out.ir(0), sig);
	}).add;

	s.sync;

	~init = {
		~rev = Synth(\reverb, [in: ~bus.toRev, out: ~bus.toDec]);
		~delay = Synth(\delay, [in: ~bus.toDelay, out: ~bus.toRev]);
		// ~zoom = Synth(\zoom, [in: ~bus.toZoom, out: ~bus.toDelay]);
		// Change the output as necessary
		~dec = Synth(\dec, [in: ~bus.toDec, out: 0], s, \addToTail);
	};

	ServerTree.add(~init);
	ServerTree.run;
});
)

OSCdef.freeAll;

// Setup callback to listen to OscMessages from musx
(
~globalRtt = { rrand(pi.neg, pi) } ! 3;
~samplePlaybackRate = 1.0;
OSCdef.new(
	key: \kulintang,
	func: {
		|msg, time, from, port|
		var amp = msg[4] * exprand(0.05, 0.3);
		var gongIndex = msg[1] - 1;
		var rttShift = { exprand(pi/20, pi/10) * [1,-1].choose }.dup(3);
		var sus = exprand(0.1, 10);


		Synth.new(\play_rtt, [
			bufnum: b.kulintang[gongIndex],
			rate: ~samplePlaybackRate,
			amp: amp,
			atk: 0.001,
			rel: 1.0,
			rot0: ~globalRtt[0],
			rot1: ~globalRtt[0] + rttShift[0],
			til0: ~globalRtt[1],
			til1: ~globalRtt[1] + rttShift[1],
			tum0: ~globalRtt[2],
			tum1: ~globalRtt[2] + rttShift[2],
			rttdur: sus,
			az: rrand(pi.neg, pi),
			el: rrand(pi.neg, pi) / 2,
			out: ~bus.toDelay
		]);

		// shift
		~globalRtt[0] = ~globalRtt[0] + rttShift[0];
		~globalRtt[1] = ~globalRtt[1] + rttShift[1];
		~globalRtt[2] = ~globalRtt[2] + rttShift[2];
	},
	path: '/musx/kulintang',
	srcID: nil,
	recvPort: NetAddr.langPort
);

OSCdef.new(
	key: \dabakan,
	func: {
		|msg, time, from, port|
		var amp = msg[4] * exprand(0.2, 0.3) * 0.4;
		var rtt_shift = { exprand(pi/20, pi/10) * [1,-1].choose }.dup(3);
		var sus = exprand(0.05, 10);

		var dabakanIndex = b.kulintang.size + [0, 1, 2, 3].choose;

		Synth.new(\play_rtt, [
			index: dabakanIndex,
			amp: amp,
			atk: 0,
			rel: 0.1,
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
	},
	path: '/musx/dabakan',
	srcID: nil,
	recvPort: NetAddr.langPort
);

OSCdef.new(
	key: \babandir,
	func: {
		|msg, time, from, port|
		var amp = msg[4] * exprand(0.2, 0.3) * 0.4;
		var rtt_shift = { exprand(pi/20, 3pi/2) * [1,-1].choose }.dup(3);
		var sus = exprand(0.05, 10);

		var babandirIndex = b.kulintang.size + b.dabakan.size + [0, 1, 2, 3].choose;

		Synth.new(\play_rtt, [
			index: babandirIndex,
			amp: amp,
			atk: 0,
			rel: 0.1,
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
	},
	path: '/musx/babandir',
	srcID: nil,
	recvPort: NetAddr.langPort
);
)

OSCdef.freeAll

(
~maxLfoFreq = 2;
OSCdef(\ios_osc_pad, {
	|msg|
	var padX, padY;
	padX = msg[1];
	padY = msg[2];
	[padX, padY].postln;
	~delay.set(\lfoAllpassFreq, padX.linexp(0.0, 1.0, 0.0001, ~maxLfoFreq));
	~delay.set(\lfoCombFreq, padY.linexp(0.0, 1.0, 0.0001, ~maxLfoFreq));
}, '/syntien/basic/1/touchpad1/press');

OSCdef(\dry_wet, {
	|msg|
	var sliderValue = msg[1];
	~delay.set(
		\dryMix, 1.0 - sliderValue,
		\wetMix, sliderValue,
	);
}, '/syntien/diaspora/1/dry_wet_slider');

OSCdef(\lfo_freq, {
	|msg|
	var padX = msg[1];
	var padY = msg[2];
	~delay.set(
		\lfoAllpassFreq, padX.linexp(0.0, 1.0, 0.0001, ~maxLfoFreq),
		\lfoCombFreq, padY.linexp(0.0, 1.0, 0.0001, ~maxLfoFreq),
	);
}, '/syntien/diaspora/1/lfo_freq_pad');

OSCdef(\feedback_decay, {
	|msg|
	var padX = msg[1];
	var padY = msg[2];
	~delay.set(
		\fb, padX,
		\fbLag, 0.1,
		\fbWarp, \sin,
		\decayTime, padY.linlin(0.0, 1.0, 0.0, 2.0),
	);
}, '/syntien/diaspora/1/feedback_decay_pad');

OSCdef(\delay_time, {
	|msg|
	var lowBound = msg[1];
	var highBound = msg[2];
	~delay.set(
		\minDelayTime, lowBound.linexp(0.0, 1.0, 0.001, 2),
		\maxDelayTime, highBound.linexp(0.0, 1.0, 0.001, 2),
	);
}, '/syntien/diaspora/1/delay_time_range_slider');

OSCdef(\playback_rate, {
	|msg|
	~samplePlaybackRate = msg[1].linlin(0.0, 1.0, 0.05, 2.0);
	~samplePlaybackRate.postln;
}, '/syntien/diaspora/1/playback_rate_slider');
)

// Set single parameters
~delay.set(\wetMix, 0.7);
~delay.set(\wetMix, 0.0);
~delay.set(\dryMix, 0.7);
~delay.set(\dryMix, 0.0);
~delay.set(\fb, 0.1, \fbLag, 1, \fbCurve, 5, \fbWarp, \lin);
~delay.set(\decayTime, 0.01, \decayTimeLag, 2, \decayTimeCurve, 5, \decayTimeWarp, \lin);
~delay.set(\lfoAllpassFreq, 0.1);
~delay.set(\lfoCombFreq, 0.1);
~delay.set(\minDelayTime, 0.02);
~delay.set(\maxDelayTime, 1);

(
~delay.set(
	\lfoAllpassFreq, rrand(0.01, 0.2),
	\lfoCombFreq, rrand(0.01, 0.2),
	\minDelayTime, 0.001,
	\maxDelayTime, 2,
	\decayTime, 2,
);
)

(
~delay.set(
	\lfoAllPassFreq, rrand(0.001, 0.002),
	\lfoCombFreq, rrand(0.001, 0.002),
	\minDelayTime, 0.02,
	\maxDelayTime, 0.04,
	\decayTime, 0.02,
);
)

(
~delay.set(
	\lfoAllPassFreq, 0.1,
	\lfoCombFreq, 0.2,
	\minDelayTime, 0.001,
	\maxDelayTime, 0.1
);
)



// Show scope
s.scope;

// Stop server
s.quit();
