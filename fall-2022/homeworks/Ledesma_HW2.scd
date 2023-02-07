// HW2

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW2.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// The following UGen function produces an error when we attempt to play it. Study the code and the error message, then correct the error and add a comment indicating what the problem was.

s.boot;

(
x = {
	var sig, freq, freq2, width;  // `freq2` needed to be defined here
	freq = LFSaw.ar(freq: 1/5, iphase: 1).exprange(200, 1500);
	freq2 = LFNoise0.ar(freq: 40 ! 2).range(1, 100);
	freq = (freq + freq2).round(50);
	width = LFTri.ar(freq: 0.2).exprange(0.02, 0.5);
	sig = VarSaw.ar(freq: freq, iphase: 0, width: width, mul: 0.05);
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 2.
// The following UGen function produces an error when we attempt to play it. Study the code and the error message, then correct the error and add a comment indicating what the problem was.

(
x = {
	var sig, freq, amp;
	freq = LFNoise0.ar(freq: 9).exprange(40,500);
	// the line below had a comma after .ar() rather than a period
	amp = LFSaw.ar(freq: 9, iphase: 1).range(0, 1).sqrt.neg + 1;
	sig = SinOsc.ar(freq: freq, mul: 0.2) * amp;
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 3.
// The following code does not produce an error, but fails to produce sound. Correct the error and add a comment indicating what the problem was.

(
x = {
	var sig, noiseHz;
	noiseHz = LFNoise1.ar(freq: 10).exprange(500, 5000);
	sig = LFDNoise1.ar(freq: noiseHz, mul: 0.08);
	// sig = sig * 0;  this line multiplied the signal level by 0, making silence
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 4.
// The following code does not produce an error, but fails to produce sound. Correct the error and add a comment indicating what the problem was.

(
x = {
	var sig, mod;
	mod = SinOsc.kr(freq: 1/4, phase: 3pi/2).range(0.02, 1);
	sig = PinkNoise.ar(0.2 ! 2);  // missing use of .ar()
	sig = sig * mod;
	sig = sig ! 2;
}.play;
)

x.free;

// ----------
// Problem 5.
// Use the 'plot' method to visualize exactly four complete cycles of a triangle wave whose frequency is 160 Hz. Note that plot accepts several arguments, the first of which is a duration in seconds.


{ LFTri.ar(160) }.plot(4 / 160);


// ----------
// Problem 6.
// Create a UGen function that produces a sine wave whose frequency is determined by a linear ramp oscillator (LFSaw). The frequency of the sine wave should go from 200 Hz to 1000 Hz once per second, and the frequency should begin at 200 Hz when the function is played (hint: you'll need to specify the correct initial phase for the ramp oscillator). Read the help files! Add an additional line of code that fades out the sound over 5 seconds (hint: store the played function in a variable and use 'release').

{ LFSaw.kr(freq: 1, iphase: 1).range(200, 1000) }.plot(1);

(
x = {
	var sinHz, sig;
	sinHz = LFSaw.kr(freq: 1, iphase: 1).range(200, 1000);
	sig = SinOsc.ar(freq: sinHz, mul: 0.5);
	sig = sig ! 2;
}.play;
)

x.release(5);


// ----------
// Problem 7.
// Create and play a UGen function that emulates a police siren. You can use this video for reference:

// https://www.youtube.com/watch?v=1G9mNBUymP8

// You'll have to use your ears to figure out the right numbers. It doesn't have to be perfect — full credit if you're close and demonstrate that you've got the right idea.

(
x = {
	var sinHz, sig, z, y;
	// ~4.6s period for siren
	// Hz range is approximate but good enough :)
	sinHz = LFTri.kr(freq: 1 / 4.6, iphase: 0).range(740, 1200);
    sig = LPF.ar(Pulse.ar(freq: sinHz, mul: 0.4), freq: 1000);  // square wave!
	sig = sig ! 2;

	// let's try reverb and noise? trying too hard to emulate the youtube clip
    sig = sig + BPF.ar(PinkNoise.ar(0.02), freq: 5000);
    sig = FreeVerb.ar(sig, mix: 0.4, room: 0.8, damp: 1);

}.play;
)

x.release(2);
x.free;




// ----------
// Problem 8.
// If you grew up with a landline phone in your house, or if you've watched classic horror movies, you may have heard the sound of a telephone that's been left off the hook for too long. It's kind of a disturbing sound: a periodic on-off pulsation of a harsh, mid-range tone. If you have no idea what I'm talking about, paste this link into your browser:

// https://www.youtube.com/watch?v=KO_YErq1M-M

// Create and play a UGen function that emulates this sound. From a spectral analysis perspective, I will tell you that it contains the following sinusoidal frequencies: [1400, 2060, 2450, 2600] Hz. The rest is up to you!

(
x = {
	var sig, env;
	sig = Mix.ar([1400, 2060, 2450, 2600].collect({
		|freq, i| SinOsc.ar(freq, mul: 0.1)
	}));
    env = EnvGen.kr(
		envelope: Env.new(
			levels: [0, 1, 1, 0],
			times: [0, 1, 0],
			curve: [0, 0, 0],
			releaseNode: 2
        ),
        gate: Trig.kr(Impulse.kr(5), dur: 0.1),
		doneAction: 0
	);
    sig = sig * env;
	sig = sig ! 2;
}.play;
)

x.free;




// -------------
// Bonus Problem
// Summer's here! Time to put on your bathing suit and run through a sprinkler. A particular type of sprinkler, in fact, which produces rapid-fire bursts of water for a few seconds, followed by slower bursts over a longer period of time. Then, this cycle repeats. Paste the following link into your browser to see an image of one of these sprinklers:
// http://diy.sndimg.com/content/dam/images/diy/fullset/2014/2/24/0/RX-iStock-187558829_Water_Lawn_Sprinkler_h.jpg.rend.hgtvcom.616.462.suffix/1420798717602.jpeg

// Here's a video of one of these sprinklers in action:
// https://www.youtube.com/watch?v=-nA7kUgLykA

// And, here's some audio, produced in SC, which emulates the sound of this sprinkler.
// https://uofi.box.com/s/vi5qb9h4yh2uv6mcn9dni7ienjj3p318

// Create and play a UGen function that emulates this sound. There are more ways that one to approach this problem. White noise makes a good sound source, and LFPulse makes a good amplitude modulator for creating noisy "water" bursts. Have at it!
{ WhiteNoise.ar(0.04) }.play;
{ LFPulse.kr(freq: 1/3, width: 0.5); }.plot(3);
s.scope;
(
// NOTE(Renzo): I wasn't able to get the different burst frequencies :/
x = {
    var sig, env, burstFreq;

    // This was my attempt/thought process:
    // Burst frequency determined by some value `toggleSig`.
    // `toggleSig` is either 0 or 1, determined by a pulse wave.
    // Pulse wave frequency (set at a period of 20s now) determines the
    //  rate at which the burst frequency changes.
    // I don't think I'm extracting the value out of this pulse wave correctly.

    env = EnvGen.kr(                                  // amp env of bursts
		envelope: Env.perc(
            attackTime: 0.01,
            releaseTime: 0.25,
            level: 0.4,
            curve: SinOsc.kr(1/5).range(-1.5, -5.0)  // oscillate curve of release env
        ),
        gate: Trig.kr(Impulse.kr(LFPulse.kr(freq: 1/5, width: 0.5).range(13, 6.5)), dur: 0.04),
		doneAction: 0
	);
    sig = WhiteNoise.ar(0.4);                         // base signal
    sig = BPF.ar(sig, freq: 12000, rq: 0.8);          // reduce low freqs
    sig = sig * env;                                  // apply amp envelope
    sig = sig + BPF.ar(
        WhiteNoise.ar(0.08), freq: 12000, rq: 0.5     // continuous water stream
    );
    sig = Pan2.ar(sig, SinOsc.kr(1/5));              // panning for fun :)
}.play;
)

x.free;

