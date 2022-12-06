s.boot;

(
~sampleFileName = "joel_synth_and_dane_guitar.wav";
~scdFileName = "Ledesma_HW5.scd";
~sampleLoopBuffer = Buffer.read(s, ~sampleFileName.resolveRelative);
)

(
SynthDef.new(\playbuf, {
	arg buf = 0, rate = 1, amp = 0.3, gate = 1, out = 0, outp = -1;
	var sig, env;
	env = EnvGen.kr(Env.asr(0,1,2,-1), gate, doneAction:2);
	sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, loop:1);
	sig = sig * env * amp;
	Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in = 0, mix = 0.3, out = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], mix: mix, room: 0.99);
	sig = LPF.ar(sig, 1400);
	Out.ar(out, sig);
}).add;

SynthDef.new(\wobble, {
    arg in = 0, windowSize = 0.2, rate = 0.2, magnitude = 1.01, out = 0;
    var sig;
    sig = In.ar(in, 2);
    sig = PitchShift.ar(sig, windowSize, pitchRatio: SinOsc.kr(rate).range(1/magnitude, magnitude));
    Out.ar(out, sig);
}).add;
)

(
// Setup groups
~sourceGroup = Group.new();
~fxGroup = Group.new(~sourceGroup, \addAfter);

// Create busses
s.newBusAllocators;
~reverbBus = Bus.audio(s, 2);
~wobbleBus = Bus.audio(s, 2);
)

(
// Setup signal flow
// Synth(\reverb, [ in: ~reverbBus, out: 0 ], ~fxGroup);
Synth(\wobble, [ in: ~wobbleBus, windowSize: 1, magnitude: 1.02, out: 0 ], ~fxGroup);
Synth(\playbuf, [ buf: ~sampleLoopBuffer, rate: 0.9, out: ~wobbleBus], ~sourceGroup);
)

(
// Cleanup
~sourceGroup.freeAll;
~fxGroup.freeAll;
)
