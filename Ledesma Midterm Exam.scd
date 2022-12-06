// MUS 499C Midterm Exam

// ----------
// Problem 1.
// The following code prints an error and fails to produce sound. Correct the error and add a comment indicating what the problem was.

s.boot;


// RL: keyword `arg` needs to precede arguments of a function
(
x = {
	arg gate = 1, freq = 100, brownamp = 0.04, amp = 1;
	var sig, env;
	env = EnvGen.kr(Env.asr(3, 1, 2), gate, doneAction: 2);
	sig = Pulse.ar(freq + [0, 1], 0.5, 0.06);
	sig = sig + SinOsc.ar(1.5 * freq + [0, 0.6], 0, 0.15);
	sig = sig + BrownNoise.ar(brownamp ! 2);
	sig = sig * env * amp;
}.play;
)

x.set(\gate, 0);

// ----------
// Problem 2.
// Copy/Paste the corrected UGen function from the previous problem, and convert it to a SynthDef. You may add additional arguments if you wish, but this is not required. Add a line of code that creates a Synth, and another line that fades the Synth out, to demonstrate that your SynthDef works properly.

(
SynthDef.new(\noisySynth, {
    arg gate = 1, freq = 100, brownamp = 0.04, amp = 1, out = 0;
    var sig, env;
    env = EnvGen.kr(Env.asr(3, 1, 2), gate, doneAction: 2);
	sig = Pulse.ar(freq + [0, 1], 0.5, 0.06);
	sig = sig + SinOsc.ar(1.5 * freq + [0, 0.6], 0, 0.15);
	sig = sig + BrownNoise.ar(brownamp ! 2);
	sig = sig * env * amp;

    Out.ar(out, sig);
}).add;
)

x = Synth.new(\noisySynth, [ freq: 400, brownamp: 0.2, amp: 0.9 ]);
x.set(\gate, 0);




// ----------
// Problem 3.
// Use an iteration method to produce a chord containing five Synths, using the SynthDef from the previous problem. Write a second iteration block that fades out all five Synths. Choose five different pitches, and use the server meters to make sure the overall signal does not clip above 0 dB.

// RL: play the synths
(
~noisySynths = [200, 400, 600, 800, 1200].collect({
    |freq, i|
    Synth.new(
        \noisySynth,
        [
            freq: freq,
            brownamp: 0.05,
            amp: 0.2 / (i+1),
        ]
    );
});
)

// RL: Fade the synths
(
~noisySynths.do({ |synth| synth.set(\gate, 0); })
)




// ----------
// Problem 4.
// Copy, paste, and modify the SynthDef so that the frequency parameter ("freq") slowly fluctuates by a small random amount. The resulting pitch deviation should be subtle, but audible. Create a new, different chord consisting of five unique (slowly fluctuating) pitches to demonstrate the sound of this change, along with a second iteration block that fades out all five Synths. Again, the overall signal must not clip above 0 dB.

// RL: new synth def
(
SynthDef.new(\wobbly, {
    arg gate = 1, freq = 100, brownamp = 0.04, amp = 1, out = 0;
    var sig, env;
    env = EnvGen.kr(Env.asr(3, 1, 2), gate, doneAction: 2);
	sig = Pulse.ar(
        freq: SinOsc
          .ar(Rand(0.05, 0.3))
          .range(freq-Rand(2, 10), freq+Rand(2, 10)) + [0, 1],
        width: 0.5,
        mul: 0.06
    );
	sig = sig + SinOsc.ar(1.5 * SinOsc.ar(Rand(0.05, 0.3)).range(freq-Rand(2, 10), freq+Rand(2, 10)) + [0, 0.6], 0, 0.15);
	sig = sig + BrownNoise.ar(brownamp ! 2);
	sig = sig * env * amp;

    Out.ar(out, sig);
}).add;
)

// RL: testing with one synth
y = Synth.new(\wobbly, [ freq: 300, brownamp: 0.2, amp: 0.9 ]);
y.set(\gate, 0);

// RL: play the wobbly synths
(
~wobblySynths = [199, 250, 678, 778, 978].collect({
    |freq, i|
    Synth.new(
        \wobbly,
        [
            freq: freq,
            brownamp: 0.05,
            amp: 0.2 / (i+1),
        ]
    );
});
)

// RL: Fade the wobbly synths
(
~wobblySynths.do({ |synth| synth.set(\gate, 0); })
)




