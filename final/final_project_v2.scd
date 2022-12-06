s.boot;

(
// Load buffer
~sampleFileName = "piano.wav";
~sampleLoopBuffer = Buffer.read(s, ~sampleFileName.resolveRelative);
)

(
// Load SynthDefs
SynthDef.new(\playbuf, {
	arg buf = 0, wobbleControl = 1, wowRate = 1, wowMagnitude = 1, flutterRate = 1, flutterMagnitude = 0, amp = 0.3, gate = 1, out = 0;
    var env, sig, wow, flutter, wobble;
    env = EnvGen.kr(Env.asr(0,1,2,-1), gate, doneAction:2);

    // Setup wobble
    wow = SinOsc.kr(wowRate).range(1/wowMagnitude, wowMagnitude);
    flutter = SinOsc.kr(flutterRate).range(-1 * flutterMagnitude, flutterMagnitude);
    wobble = wow + flutter;

    // Create signal
    sig = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * (wobble / ((wobbleControl*wobble) + (1-wobbleControl))), loop:1);
	sig = sig * env * amp;
    Out.ar(out, sig);
}).add;

SynthDef.new(\reverb, {
	arg in = 0, mix = 0.3, out = 0;
	var sig;
	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], mix: mix, room: 0.1);
	Out.ar(out, sig);
}).add;

SynthDef.new(\vinylNoise, {
    arg in = 0, noiseAmp = 0.3, out = 0;
    // Fieldsteel's vinyl pops and crackles code: https://sccode.org/1-H
    var	sig, sig1, sig2, lpf, popHz, lagtime, noise, popHzMul,
		pan1, pan2, panmod1, panmod2;
	popHzMul = Decay.kr(Dust.kr(0.15), 3, 10, 0.8);
	popHz = 	LFNoise1.kr(20).exprange(0.1,10) * popHzMul;
	sig = Dust2.ar(popHz);
	lpf = LFNoise1.kr(10).exprange(1000,20000);
	lagtime = LFNoise1.kr(20).range(0.008,0.0001);
	sig = LPF.ar(sig, lpf);
	sig = Lag.ar(sig, lagtime);
	sig = sig + FreeVerb.ar(sig, 0.8, 1, mul:0.11);
	panmod1 = LFNoise1.kr(5).range(0.2,0.7);
	panmod2 = LFNoise1.kr(5).range(0.2,0.7);
	pan1 = SinOsc.kr(panmod1).range(-0.2,0.2);
	pan2 = SinOsc.kr(panmod2).range(-0.2,0.2);
	sig1 = Pan2.ar(sig, pan1, 0.5);
	sig2 = Pan2.ar(sig, pan2, 0.5);
	sig = sig1 + sig2;
	sig = sig + BPF.ar(BrownNoise.ar([0.0025,0.0025]), 7200, 0.4);
	sig = sig + HPF.ar(Crackle.ar([1.999,1.999], 0.0025),2000);

    sig = In.ar(in, 2) + (sig * noiseAmp);
    Out.ar(out, sig);
}).add;

SynthDef.new(\noise, {
    arg in = 0, noiseVolume = 0.2, noiseHpfCutoff = 500, dustVolume = 0.1, dustDensity = 15, lpfCutoff = 5000, outGain = 1.0, out = 0;
    var sig, noise;
	noise = HPF.ar(BrownNoise.ar(noiseVolume), noiseHpfCutoff);  // apply noise
	noise = noise + Dust2.ar(dustDensity ! 2, dustVolume ! 2);  // apply "crackle"
	noise = noise + LPF.ar(noise, lpfCutoff);
    sig = In.ar(in, 2);
    sig = sig + (outGain * noise);
    Out.ar(out, sig);
}).add;

SynthDef.new(\distort, {
    arg in = 0, amount = 0.1, amp = 0.8, out = 0;
    var sig, k;
    sig = In.ar(in, 2);
	k = 2 * amount / (1 - amount);
	sig = (1 + k) * sig / (1 + (k * sig.abs));  // apply distortion
	sig = sig * amp;
	// process signal
    Out.ar(out, sig);
}).add;

SynthDef.new(\digital, {
    arg in = 0, amp = 0.8, bitPower = 7, lpfCutoff = 2000, out = 0;
    var sig;
    sig = In.ar(in, 2);
	// process signal
	sig = sig.round(2**(-1 * bitPower));  // bitcrush
	sig = LPF.ar(sig, lpfCutoff, amp);  // lpf and amplitude
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
~noiseBus = Bus.audio(s, 2);
~vinylNoiseBus = Bus.audio(s, 2);
~distortBus = Bus.audio(s, 2);
~digitalBus = Bus.audio(s, 2);
)

(
// Play with no effects
Synth(\playbuf, [
	buf: ~sampleLoopBuffer,
	amp: 0.4,
	out: 0
], ~sourceGroup);
)


(
// Setup signal flow
~reverbFx = Synth(\reverb, [
	in: ~reverbBus,
	mix: 0,
	out: 0
], ~fxGroup).register;

~digitalFx = Synth(\digital, [
	in: ~digitalBus,
	bitPower: 10,
	lpfCutoff: 16000,
	amp: 1.0,
	out: ~reverbBus,
], ~fxGroup).register;

~distortFx = Synth(\distort, [
	in: ~distortBus,
	amount: 0.8,  // (-1, 1) but closer to 1 is better
	amp: 0.8,
	out: ~digitalBus,
], ~fxGroup).register;

~vinylFx = Synth(\vinylNoise, [
	in: ~vinylNoiseBus,
	noiseAmp: 0.5,
	out: ~distortBus
], ~fxGroup).register;

~noiseFx = Synth(\noise, [
	in: ~noiseBus,
	noiseVolume: 0.0,  // [0, 1]. make it < 0.1
	dustVolume: 0.0,
	dustDensity: 5,
    lpfCutoff: 6000,
    outGain: 0.0,
	out: ~vinylNoise
], ~fxGroup).register;

~playbufFx = Synth(\playbuf, [
	buf: ~sampleLoopBuffer,
	wowRate: 0.1,
	wowMagnitude: 1.01,
	flutterRate: 0.5,
	flutterMagnitude: 0.01,
    wowControl: 0.0,
	out: ~digitalBus
], ~sourceGroup).register;
)

(
// Cleanup
~sourceGroup.freeAll;
~fxGroup.freeAll;
)


// Setup UI
(
Window.closeAll;
w = Window.new("MUS 499C Final Project", Rect.new(100, 100, 800, 500))
.front
.alwaysOnTop_(true);

w.onClose = {
    ~playbufFx.set(\wobbleControl, 0);
};

w.addFlowLayout(10@50, 5@5);

// 'Wow' magnitude controls
~wowMagnitudeControlSpec = ControlSpec(1.0, 1.5, \exp, units: "ratio");
~wowMagnitudeSlider = EZSlider.new(w, 60@250, "Wow magnitude", ~wowMagnitudeControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\wowMagnitude, view.value);
    })
});

// 'Wow' rate controls
~wowRateControlSpec = ControlSpec(0.01, 2, \exp, units: "Hz");
~wowRateSlider = EZSlider.new(w, 60@250, "Wow rate", ~wowRateControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\wowRate, view.value);

    })
});

// 'Flutter' magnitude controls
~flutterMagnitudeControlSpec = ControlSpec(0.001, 0.2, \exp, units: "deviation");
~flutterMagnitudeSlider = EZSlider.new(w, 60@250, "Flutter magnitude", ~flutterMagnitudeControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\flutterMagnitude, view.value);
    })
});

// 'Flutter' rate controls
~flutterRateControlSpec = ControlSpec(1, 10, \exp, units: "Hz");
~flutterRateSlider = EZSlider.new(w, 60@250, "Flutter rate", ~flutterRateControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\flutterRate, view.value);
    })
});

// Wobble toggle button
~wobbleButton = Button.new(w, Rect(60, 20, 100, 30))
.states_([
    ["enable wobble", Color.black, Color.white],
    ["disable wobble", Color.black, Color.new255(183, 216, 252)]
])
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        if (view.value == 1, {
            ~playbufFx.set(\wobbleControl, 0);
        }, {
            ~playbufFx.set(\wobbleControl, 1);

        })
    })
});

// Noise gain slider
~noiseGainSpec = ControlSpec(0.001, 0.3, \exp, units: "gain");
~noiseGainSlider = EZSlider.new(w, 60@250, "Noise gain", ~noiseGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\noiseVolume, view.value);
    })
});

// Dust gain slider
~dustGainSpec = ControlSpec(0.001, 0.3, \exp, units: "gain");
~dustGainSlider = EZSlider.new(w, 60@250, "Dust gain", ~dustGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\dustVolume, view.value);
    })
});

// Dust density slider
~dustDensitySpec = ControlSpec(0.001, 50, \lin, units: "density (Hz)");
~dustDensitySlider = EZSlider.new(w, 60@250, "Dust density", ~dustDensitySpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\dustDensity, view.value);
    })
});

// Noise toggle button
~noiseButton = Button.new(w, Rect(60, 20, 100, 30))
.states_([
    ["enable noise", Color.black, Color.white],
    ["disable noise", Color.black, Color.new255(183, 216, 252)]
])
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        if (view.value == 1, {
            ~noiseFx.set(\outGain, 1.0);
        }, {
            ~noiseFx.set(\outGain, 0.0);
        })
    })
});

s.meter;
)