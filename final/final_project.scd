s.boot;

(
// Load buffer
// NOTE: declare new buffers here to read in
~pianoBuffer = Buffer.read(s, "piano.wav".resolveRelative);
~guitarBuffer = Buffer.read(s, "guitar.wav".resolveRelative);
~drumBuffer = Buffer.read(s, "drum_loop.wav".resolveRelative);
~synthBuffer = Buffer.read(s, "synth.wav".resolveRelative);
)

(
// Load SynthDefs
SynthDef.new(\playbuf, {
	arg buf = nil, wobbleControl = 0, wowRate = 0, wowMagnitude = 1, flutterRate = 1, flutterMagnitude = 0, amp = 0.3, gate = 1, out = 0;
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
	noise = LPF.ar(noise, lpfCutoff);
    sig = In.ar(in, 2);
    sig = sig + (outGain * noise);
    Out.ar(out, sig);
}).add;

SynthDef.new(\distort, {
    arg in = 0, inAmp = 1.0, amount = 0.1, outAmp = 0.8, out = 0;
    var sig, k;
    sig = In.ar(in, 2);
    sig = sig * inAmp;

	// process signal using dist. algorithm
    // Source: https://gist.github.com/jpburstrom/9cd623202f535070925a
    // Desmos visualization: https://www.desmos.com/calculator/kgyo2v0oy9
	k = 2 * amount / (1 - amount);
	sig = (1 + k) * sig / (1 + (k * sig.abs));  // apply distortion
	sig = sig * outAmp;
    sig = Limiter.ar(sig, 0.9);
    Out.ar(out, sig);
}).add;

SynthDef.new(\digital, {
    arg in = 0, amp = 0.8, bitPower = 7, lpfCutoff = 2000, hpfCutoff = 20, out = 0;
    var sig;
    sig = In.ar(in, 2);
	// process signal
	sig = sig.round(2**(-1 * bitPower));  // bitcrush
	sig = LPF.ar(sig, lpfCutoff, amp);  // lpf and amplitude
    sig = HPF.ar(sig, hpfCutoff);
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
// Setup signal flow and play sound
~reverbFx = Synth(\reverb, [
	in: ~reverbBus,
	mix: 0,
	out: 0
], ~fxGroup).register;

~digitalFx = Synth(\digital, [
	in: ~digitalBus,
	bitPower: 16,
	lpfCutoff: 16000,
	amp: 1.0,
	out: ~reverbBus,
], ~fxGroup).register;

~distortFx = Synth(\distort, [
	in: ~distortBus,
    inAmp: 1.0,
	amount: 0.0,  // (-1, 1) but closer to 1 is better
	outAmp: 0.8,
	out: ~digitalBus,
], ~fxGroup).register;

~vinylFx = Synth(\vinylNoise, [
	in: ~vinylNoiseBus,
	noiseAmp: 0.0,
	out: ~distortBus
], ~fxGroup).register;

~noiseFx = Synth(\noise, [
	in: ~noiseBus,
	noiseVolume: 0.0,  // [0, 1]. make it < 0.1
	dustVolume: 0.0,
	dustDensity: 0,
    lpfCutoff: 6000,
    outGain: 0.0,
	out: ~vinylNoiseBus
], ~fxGroup).register;

~playbufFx = Synth(\playbuf, [
	buf: ~pianoBuffer,  // choose sample here
	wowRate: 0.1,
	wowMagnitude: 1.00,
	flutterRate: 0.5,
	flutterMagnitude: 0.01,
    wobbleControl: 0.0,
	out: ~noiseBus
], ~sourceGroup).register;
)

(
// Cleanup
// NOTE: running this block clears all groups and stops the sound.
// You can run the block above this to start the sound again.
~sourceGroup.freeAll;
~fxGroup.freeAll;
)


(
// Setup UI
Window.closeAll;
w = Window.new("MUS 499C 'NH-20 Nostalgic Hue'", Rect.new(600, 200, 800, 600))
.front
.alwaysOnTop_(true);

w.onClose = {
    ~playbufFx.set(\wobbleControl, 0);
};

w.addFlowLayout(10@50, 5@5);
~sliderBounds = 50@250;

// ========== Wobble ================

// 'Wow' magnitude controls
~wowMagnitudeControlSpec = ControlSpec(1.0, 1.2, \exp, units: "ratio");
~wowMagnitudeSlider = EZSlider.new(w, ~sliderBounds, "Wow magnitude", ~wowMagnitudeControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\wowMagnitude, view.value);
    })
});

// 'Wow' rate controls
~wowRateControlSpec = ControlSpec(0.01, 2, \exp, units: "Hz");
~wowRateSlider = EZSlider.new(w, ~sliderBounds, "Wow rate", ~wowRateControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\wowRate, view.value);

    })
});

// 'Flutter' magnitude controls
~flutterMagnitudeControlSpec = ControlSpec(0.001, 0.2, \exp, units: "deviation");
~flutterMagnitudeSlider = EZSlider.new(w, ~sliderBounds, "Flutter magnitude", ~flutterMagnitudeControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\flutterMagnitude, view.value);
    })
});

// 'Flutter' rate controls
~flutterRateControlSpec = ControlSpec(1, 10, \exp, units: "Hz");
~flutterRateSlider = EZSlider.new(w, ~sliderBounds, "Flutter rate", ~flutterRateControlSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        ~playbufFx.set(\flutterRate, view.value);
    })
});


// Wobble toggle button
~wobbleButton = Button.new(w, Rect(60, 20, 100, 30))
.states_([
    ["disable wobble", Color.black, Color.new255(183, 216, 252)],
    ["enable wobble", Color.black, Color.white]
])
.action_({
    |view|
    if (~playbufFx.isPlaying, {
        if (view.value == 0, {
            ~playbufFx.set(\wobbleControl, 0);
        }, {
            ~playbufFx.set(\wobbleControl, 1);
        })
    })
});

// ========== Noise ================
w.view.decorator.left_(400);


// Noise gain slider
~noiseGainSpec = ControlSpec(0.001, 0.3, \exp, units: "gain");
~noiseGainSlider = EZSlider.new(w, ~sliderBounds, "Noise gain", ~noiseGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\noiseVolume, view.value);
    })
});

// Dust gain slider
~dustGainSpec = ControlSpec(0.001, 0.3, \exp, units: "gain");
~dustGainSlider = EZSlider.new(w, ~sliderBounds, "Dust gain", ~dustGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\dustVolume, view.value);
    })
});

// Dust density slider
~dustDensitySpec = ControlSpec(0.001, 50, \lin, units: "density (Hz)");
~dustDensitySlider = EZSlider.new(w, ~sliderBounds, "Dust density", ~dustDensitySpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\dustDensity, view.value);
    })
});

// LPF cutoff slider
~noiseLpfCutoffSpec = ControlSpec(20, 20000, \exp, units: "Hz", default: 6000);
~noiseLpfCutoffSlider = EZSlider.new(w, ~sliderBounds, "LPF cutoff", ~noiseLpfCutoffSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\lpfCutoff, view.value);
    })
});

// HPF cutoff slider
~noiseHpfCutoffSpec = ControlSpec(20, 20000, \exp, units: "Hz", default: 500);
~noiseHpfCutoffSlider = EZSlider.new(w, ~sliderBounds, "HPF cutoff", ~noiseHpfCutoffSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~noiseFx.isPlaying, {
        ~noiseFx.set(\noiseHpfCutoff, view.value);
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


// ========== Vinyl ================

// Vinyl gain
~vinylGainSpec = ControlSpec(0.001, 10.0, \lin, units: "gain");
~vinylGainSlider = EZSlider.new(w, ~sliderBounds, "Vinyl gain", ~vinylGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~vinylFx.isPlaying, {
        ~vinylFx.set(\noiseAmp, view.value);
    })
});

// ========== Distortion ================

// Distortion amount
~distortAmountSpec = ControlSpec(0, 0.999, \lin, units: "amount", default: 0.0);
~distortAmountSlider = EZSlider.new(w, ~sliderBounds, "Distortion", ~distortAmountSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~distortFx.isPlaying, {
        ~distortFx.set(\amount, view.value);
    })
});

// Distortion input gain
~distortInputGainSpec = ControlSpec(0.001, 2.0, \lin, units: "gain", default: 1.0);
~distortInputGainSlider = EZSlider.new(w, ~sliderBounds, "Dist. in gain", ~distortInputGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~distortFx.isPlaying, {
        ~distortFx.set(\inAmp, view.value);
    })
});

// Distortion output gain
~distortOutputGainSpec = ControlSpec(0.001, 2.0, \lin, units: "gain", default: 1.0);
~distortOutputGainSlider = EZSlider.new(w, ~sliderBounds, "Dist. out gain", ~distortOutputGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~distortFx.isPlaying, {
        ~distortFx.set(\outAmp, view.value);
    })
});

// ========== Digital ================
w.view.decorator.left_(400);

// Digital bit power slider
~digitalBitSpec = ControlSpec(2, 16, \exp, units: "bit rounding", default: 16);
~digitalBitSpecSlider = EZSlider.new(w, ~sliderBounds, "Digital (bitcrush)", ~digitalBitSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~digitalFx.isPlaying, {
        ~digitalFx.set(\bitPower, view.value);
    })
});

// Digital LPF cutoff slider
~digitalLpfCutoffSpec = ControlSpec(20, 20000, \exp, units: "Hz", default: 16000);
~digitalLpfCutoffSlider = EZSlider.new(w, ~sliderBounds, "Digital LPF cutoff", ~digitalLpfCutoffSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~digitalFx.isPlaying, {
        ~digitalFx.set(\lpfCutoff, view.value);
    })
});

// Digital HPF cutoff slider
~digitalHpfCutoffSpec = ControlSpec(20, 20000, \exp, units: "Hz", default: 20);
~digitalHpfCutoffSlider = EZSlider.new(w, ~sliderBounds, "Digital HPF cutoff", ~digitalHpfCutoffSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~digitalFx.isPlaying, {
        ~digitalFx.set(\hpfCutoff, view.value);
    })
});

// Digital output gain
~digitalOutputGainSpec = ControlSpec(0.001, 2.0, \lin, units: "gain", default: 1.0);
~digitalOutputGainSlider = EZSlider.new(w, ~sliderBounds, "Digital out gain", ~digitalOutputGainSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~digitalFx.isPlaying, {
        ~digitalFx.set(\amp, view.value);
    })
});

// ========== Reverb ================
// Digital output gain
~reverbMixSpec = ControlSpec(0, 1.0, \lin, units: "mix", default: 0.0);
~reverbMixSlider = EZSlider.new(w, ~sliderBounds, "Reverb", ~reverbMixSpec, unitWidth:30, numberWidth:60, layout: \vert)
.action_({
    |view|
    if (~reverbFx.isPlaying, {
        ~reverbFx.set(\mix, view.value);
    })
});


// ========== Sample selection ================

// NOTE: add a new item for each new sample
~bufferMenu = PopUpMenu(w, Rect(10, 10, 130, 30))
.items_(["Piano", "Guitar", "Drums", "Synth"]);

// NOTE: add a new function for each new sample, providing appropriate buffer
~bufferMenuFuncs = [
    { ~playbufFx.set(\buf, ~pianoBuffer) },
    { ~playbufFx.set(\buf, ~guitarBuffer) },
    { ~playbufFx.set(\buf, ~drumBuffer) },
    { ~playbufFx.set(\buf, ~synthBuffer) },
];

~bufferMenuButton = Button(w, Rect(110, 10, 180, 30))
  .states_([["switch sample", Color.black, Color.new255(183, 252, 216)]])
  .mouseDownAction_({
    // I'm not sure what the best way to run these functions is,
    // but this seems to work without throwing an error!
    ~bufferMenuFuncs.at(~bufferMenu.value).value;
   });


) // EOF
