// HW4

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW4.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// Using a pattern or combination of patterns, create an infinite-length stream that begins at zero and counts upward by five (0, 5, 10, 15...). On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.

(
p = Pseries(0, 5, inf);
q = p.asStream;
)

q.nextN(40);



// ----------
// Problem 2.
// Modify your previous answer so that the stream counts from 0 to 40 by five, then from 40 to 0 by eight, producing the following sequence, repeated indefinitely: (0, 5, 10, 15, 20, 25, 30, 35, 40, 32, 24, 16, 8). DO NOT use one long Pseq, even if it might be considered the most "efficient" solution - the exercise here is to come up with an alternative. On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.

(
p = Pseq([
    Pseries(0, 5, 8),
    Pseries(40, -8, 5)
], inf);
q = p.asStream;
)

q.nextN(13);
q.reset();


// ----------
// Problem 3.
// Using a pattern or combination of patterns, create an infinite-length stream that outputs the number 60 approximately 85% of the time, the number 67 approximately 11% of the time, and the number 70 approximately 4% of the time. On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.

(
p = Pwrand(
    list: [60, 67, 70],
    weights: [0.85, 0.11, 0.04].normalizeSum,
    repeats: inf
);
y = p.asStream;
)

y.nextN(100).sort;  // RL: sorting to make checking easier
y.reset;

// ----------
// Problem 4.
// Using a pattern or combination of patterns, create an infinite-length stream that randomly outputs one of the following three things: (1) The number one, once, (2) the number 0.5, twice in a row, or (3) the number 0.25, four times in a row. Each of these three possibilities should have an equal probability of occurring, but the the same outcome should never occur twice in a row (e.g. we should never get the number 0.25 eight times in a row).

(
p = Pxrand(
    list: [
        Pseq([1]),
        Pseq([0.5, 0.5]),
        Pseq([0.25, 0.25, 0.25, 0.25]),
    ],
    repeats: inf
);
z = p.asStream;
)

z.nextN(60);


// ----------
// Problem 5.
// Using a pattern or combination of patterns, create an infinite-length stream that starts at one and counts upward by one, but skips every multiple of five, e.g.: (1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19...). On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.

(
p = Pseries(1, Pseq([1, 1, 1, 2], inf));
q = p.asStream;
)

(
q.nextN(100).do({
    |n|
    // RL: no 'incorrect!'s should appear
    if (n % 5 == 0, { 'incorrect!'.postln })
});
)



// ----------
// Problem 6.
// Boot the server. Create and add a SynthDef that plays a triangle oscillator with a percussive envelope applied to it. Include arguments for frequency, amplitude, stereo pan position, envelope attack & release, and output bus. Separately, create a few Synths to demonstrate your SynthDef.

s.boot;

(
SynthDef.new(\triPluck, {
    var sig, env;
    sig = LFTri.ar(\freq.kr(500), mul: 0.5);
    env = EnvGen.kr(
        envelope: Env.perc(
            attackTime: \attackTime.kr(0.01),
            releaseTime: \releaseTime.kr(1.0),
        ),
        doneAction: 2,
    );
    sig = sig * env;
    sig = sig * \amp.kr(1);
    sig = Pan2.ar(sig, \pan.kr(0));

    Out.ar(\out.kr(0), sig);
}).add;
)

// default
(
Synth.new(\triPluck);
)

// higher, quicker pluck
(
Synth.new(\triPluck, [
    freq: 650,
    attackTime: 0.001,
    releaseTime: 0.1,
    amp: 0.8,
    pan: -0.5
])
);

// lower, slower "pluck"
(
Synth.new(\triPluck, [
    freq: 300,
    attackTime: 0.3,
    releaseTime: 1,
    amp: 0.7,
    pan: 0.5
])
);




// ----------
// Problem 7.
// Create and play a Routine that generates an infinite sequence of Synths, using the stream values from Problem 3, treated as MIDI note numbers. The attack and release times of each Synth should be very short, but long enough that the pitch of each note is perceptible. The Routine should wait for 0.15 seconds after generating each Synth. Write a separate line of code that stops the Routine.

(
r = Routine.new({
    inf.do({
        Synth.new(\triPluck, [
            freq: y.next.midicps,
            attackTime: 0.001,
            releaseTime: 0.1,
            amp: 0.6,
        ]);
        0.15.yield;
    });
});
r.play;
)

r.stop;




// ----------
// Problem 8.
// Relying on a custom instance of TempoClock, modify the Routine from the previous problem so that when it plays, it now also uses output values from the stream in Problem 4 as durations, treated as beats at a tempo of 108 bpm. In other words, the rhythmic behavior of the Routine will be a random sequence of (1) a quarter note, (2) two eighth notes, and (3) four sixteenth notes, but never the same rhythmic unit twice in a row. Write a separate line of code that stops the Routine.

(
t = TempoClock.new(108/60);
g = Routine.new({
    inf.do({
        Synth.new(\triPluck, [
            freq: y.next.midicps,
            attackTime: 0.001,
            releaseTime: 0.1,
            amp: 0.6,
        ]);
        z.next.yield;
    });
});
g.play(t);
)

g.stop;




// ----------
// Problem 9.
// Rewrite the previous problem using Pbind instead of Routine.

(
// RL: couldn't think of a way to reuse the Pattern from before, since
// we need to pass frequencies into the synth rather than MIDI numbers
f = Pwrand(
    list: [60, 67, 70].collect({ |note| note.midicps }),
    weights: [0.85, 0.11, 0.04].normalizeSum,
    repeats: inf
);
t = TempoClock.new(108/60);
p = Pbind.new(
    \instrument, \triPluck,
    \freq, f,
    \attackTime, 0.001,
    \releaseTime, 0.1,
    \amp, 0.6,
    \dur, z,
);
q = p.play(t);
)

q.stop;



// -------------------
// Bonus Problem (+3).
// Do these exercises spark ideas for other creative applications of algorithmic sequencing? Extend the content of Problems 8–9 by applying algorithmic sequences to other Synth parameters. Optionally, modify/augment the SynthDef, and/or create additional Routines/Pbinds that play in parallel. Get creative and make some interesting melodies/rhythms/textures/drones!