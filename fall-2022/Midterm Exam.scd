// MUS 499C Midterm Exam

// ----------
// Problem 1.
// The following code prints an error and fails to produce sound. Correct the error and add a comment indicating what the problem was.

s.boot;

(
x = {
	gate = 1, freq = 100, brownamp = 0.04, amp = 1;
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






// ----------
// Problem 3.
// Use an iteration method to produce a chord containing five Synths, using the SynthDef from the previous problem. Write a second iteration block that fades out all five Synths. Choose five different pitches, and use the server meters to make sure the overall signal does not clip above 0 dB.






// ----------
// Problem 4.
// Copy, paste, and modify the SynthDef so that the frequency parameter ("freq") slowly fluctuates by a small random amount. The resulting pitch deviation should be subtle, but audible. Create a new, different chord consisting of five unique (slowly fluctuating) pitches to demonstrate the sound of this change, along with a second iteration block that fades out all five Synths. Again, the overall signal must not clip above 0 dB.







