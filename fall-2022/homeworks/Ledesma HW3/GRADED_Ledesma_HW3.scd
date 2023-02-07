// GRADE: 97/100

// HW3

// This homework involves audio files in addition to SC code. First, create a new folder on your computer named "Lastname HW3". Save this code file as "Lastname HW3.scd inside this new folder. Download the following audio samples and save them in the same folder as your scd file.

drum loop
https://uofi.box.com/s/vrh8j78mhend29hvyydpt4gygtlb0wfh

desk bell
https://uofi.box.com/s/2jcyp9wic50dqs78fa1weyijihldwwtj

// All three of your files should remain together in the same folder. When ready to submit this assignment, compress your folder (containing your code and audio files) as a zip file, and upload the zip file.

// ----------
// Problem 1.
// Using "thisProcess.nowExecutingPath" or "resolveRelative", write some code that reads the audio files into Buffers, and stores each Buffer using a unique global variable name. You may want/need to use the PathName class. If done correctly, I should be able to run your code on my computer and successfully load the audio files into buffers, without having to change any of your code or move any files around.

(
~readFiles = {
	~drumLoopFileName = "drumloop1.wav";
	~deskBellFileName = "deskBell.aiff";
	~scdFileName = "Ledesma_HW3.scd";

	~drumLoopBuffer = Buffer.read(s, ~drumLoopFileName.resolveRelative);

	~deskBellBuffer = Buffer.read(s, ~deskBellFileName.resolveRelative);
}.play;
)

// EMF: (-2) careful — you don't actually want to 'play' this function, just 'value' it. if you play it, it creates a silent Synth! (check the node tree). you can put this code in a function if you like, but you don't really need to, at least not for this problem:

(
~drumLoopFileName = "drumloop1.wav";
~deskBellFileName = "deskBell.aiff";
~scdFileName = "Ledesma_HW3.scd";
~drumLoopBuffer = Buffer.read(s, ~drumLoopFileName.resolveRelative);
~deskBellBuffer = Buffer.read(s, ~deskBellFileName.resolveRelative);
)

// EMF: or

(
~readFiles = {
	~drumLoopFileName = "drumloop1.wav";
	~deskBellFileName = "deskBell.aiff";
	~scdFileName = "Ledesma_HW3.scd";
	~drumLoopBuffer = Buffer.read(s, ~drumLoopFileName.resolveRelative);
	~deskBellBuffer = Buffer.read(s, ~deskBellFileName.resolveRelative);
};

~readFiles.();
)


// ----------
// Problem 2.
// Write a line of code that returns the number of audio channels in the drum loop file, and another line of code that returns the duration (seconds) of the desk bell file. No need to produce any sound — just print/return the buffer information.

~drumLoopBuffer.numChannels
~deskBellBuffer.duration





// ----------
// Problem 3.
// Write a UGen function (not a SynthDef) that plays desk bell sample once, at its original playback rate. Make sure to account for the possibility of mismatched sample rates. The Synth should free itself when it reaches the end of the sound file.

(
~play = {
	var sig;

	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: ~deskBellBuffer.bufnum,
		rate: BufRateScale.kr(~deskBellBuffer.bufnum),
		doneAction: 2
	);
}.play;
)



// ----------
// Problem 4.
// Convert the UGen function from the previous problem into a SynthDef. Declare arguments for the bufnum, the playback rate, the overall signal amplitude, and the output bus. After adding the SynthDef, create a few Synths to show that your SynthDef works correctly.

(
SynthDef.new(\play, {
	var sig;

	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		doneAction: 2,
	);

	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;
)

// pitched down bell
(
Synth.new(
	\play,
	[
		buf: ~deskBellBuffer.bufnum,
		rate: -14.midiratio,
		amp: 0.9,
	]
);
)

// drum loop twice as fast
(
Synth.new(
	\play,
	[
		buf: ~drumLoopBuffer.bufnum,
		rate: 2,
		amp: 0.5,
	]
);
)

// drum loop slowed down an fifth
(
Synth.new(
	\play,
	[
		buf: ~drumLoopBuffer.bufnum,
		rate: -7.midiratio,
		amp: 0.6,
	]
);
)



// ----------
// Problem 5.
// Use an iteration method to create five Synths from the SynthDef you created. Each Synth should play the desk bell sample at a unique playback rate, resulting in a five-voice chord. Make sure the amplitude of the overall sound doesn't clip above 0 dB (use s.meter to monitor output signal levels).


// EMF: (-1) should be five Synths, not six

(
var rates = [-12, -5, 0, 2, 11, 14];
rates.do({ |rate|
	Synth.new(
		\play,
		[
			buf: ~deskBellBuffer.bufnum,
			rate: rate.midiratio,
			amp: 0.25
		]
	);
});
)





// ----------
// Problem 6.
// Modify the existing SynthDef with a new argument used to determine whether playback will loop. Also, add a sustaining amplitude envelope with a gate argument, so that the Synth can be faded out at any time. Distribute doneActions appropriately. After modifying the SynthDef, create a Synth which endlessly loops through the drum sample at its original rate, backwards. Add another line of code that closes the envelope gate.

(
SynthDef.new(\play1, {
	var sig, env;

	sig = PlayBuf.ar(
		numChannels: 2,
		bufnum: \buf.kr(0),
		rate: BufRateScale.kr(\buf.kr(0)) * \rate.kr(1),
		doneAction: 2,
		loop: \loop.ir(0)
	);

	env = EnvGen.kr(
		Env(
			levels: [0, 1, 0.5, 0],
			times: [\atk.ir(0.02), 0.1, \rel.ir(3)],
			releaseNode: 2,
		),
		doneAction: \doneAction.ir(2),
		gate: \gate.kr(0),
	);

	sig = sig * env;
	sig = sig * \amp.kr(1);

	Out.ar(\out.kr(0), sig);
}).add;
)

// plays the drum loop, reversed
(
~drumLoopRev = Synth.new(
	\play1,
	[
		buf: ~drumLoopBuffer.bufnum,
		rate: -1.0,
		amp: 0.5,
		loop: 1,
		gate: 1,
		doneAction: 2,
		rel: 0.2
	]
);
)

// closes the gate, with release of 0.2 seconds
(
~drumLoopRev.set(\gate, 0);
)



// ----------
// Problem 7.
// Use iteration to create three Synths that loop-play the drum sample backwards. Their playback rates should be slightly different (e.g. -0.99, -1.0, -1.01), so that these three Synths drift out of phase with each other over time. Make sure the amplitude of the overall sound doesn't clip above 0 dB. Write another line of code that fades out all three Synths.

// play phasey drums
(
var rates = [-0.5, -0, -2]; // EMF: not sure this counts as "slightly different" but you've obviously got the right idea. sounds pretty cool, anyway :)
~revDrums = rates.collect({
	|rate|
	Synth.new(
		\play1,
		[
			buf: ~drumLoopBuffer.bufnum,
			rate: rate,
			amp: 0.5,
			loop: 1,
			gate: 1,
			doneAction: 2,
			rel: 3
		]
	);
});
)


// close gate for all drums, triggering release & fade out
(
~revDrums.do({ |synth| synth.set(\gate, 0); })
)

