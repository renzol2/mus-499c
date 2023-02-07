s.boot;

// Patterns
// - Prepackaged, algorithmic units
// - A language within a language
// - Can be a challenge to fully digest
// - Patterns are *stateless*; they return a "stream" or stream-adjacent class
// - Therefore, patterns cannot be played
// - Rather, they serve as templates or sequences that can spawn additional, independent streams
// - Think; interfaces (or classes in general?)

(
~noteGen = Routine.new({
    var pch;
    inf.do({
        pch = -12;
        8.do({
            pch.yield;
            pch = pch + rrand(1,6);
        });
    });
});
)

~noteGen.next;

// noteGen written as a pattern
(
p = Pseq([ Pseries(-12, Pwhite(1,6,inf), 8) ], inf);
q = p.asStream;
)

q.next;
q.nextN(8);
q.reset

Synth(\pulse, [freq: (q.next + 60).midicps]);

(
SynthDef(\pulse, {
    var sig, env, freq, cf;

    freq = \freq.kr(100);
    freq = freq( { Rand(-0.1, 0.1).midiratio }.dup(4));
    cf = freq * \harm.ir(2);

    sig = Pulse.ar(freq, \width.ir(0.5)).sum * 0.1;
    sig = LPF.ar(sig, cf.clip(20,20000));

    env = EnvGen.kr(
        Env(
            levels: [0,1,0],
            times: [\atk.ir(0.01), \rel.ir(0.5)],
            curve: [-2, -4],
        ),
        doneAction: 2,
    );

    sig = Pan2.ar(sig, \pan.kr(0), \amp.kr(0.2));
    sig = sig * env;
    Out.ar(\out.kr(0), sig);

}).add;
)

Synth(\pulse, [freq:400, width: 0.5, amp: 0.5, rel: 3, harm: 8]);

(
p = Pseq(list: [3, 7, -3, 10], repeats: 4, offset: 0);
q = p.asStream;
)

(
p = Prand(list: [3, 7, -3, 10], repeats: inf);
q = p.asStream;
)

(
p = Pwrand(list: [10, 20, 30], weights: [0.1, 0.4, 0.9].normalizeSum, repeats: inf);
q = p.asStream;
)

(
p = Pseq(list: [Pshuf(list: (1..5))], repeats: inf);
q = p.asStream;
)

(
p = Pseries(start: 0, step: 12, length: 4);
q = p.asStream;
)

(
p = Pgeom(start: 1, grow: 2, length: inf);
q = p.asStream;
)
(
p = Pgeom(start: 1, grow: -3.dbamp, length: inf);
q = p.asStream;
)

q.next;
q.nextN(40);
q.reset;


// Ranged randomness
(
p = Pwhite(lo: 1, hi: 9, length: inf);  // identical to Prand((1..9))
q = p.asStream;
)

(
p = Pexprand(lo: 1, hi: 1000, length: inf);
q = p.asStream;
)

// Others:
Pbrown()
Plprand()
Phprand()
Pmeanrand()
Pn()
Pdup()

(
p = Pdup(2, Pwhite(1, 100, inf));
q = p.asStream;
)

(
p = Pfunc({
    var num;
    num = 4;
    num = num + rrand(1,5);
    num = num + num.isPrime.asInteger;
});
q = p.asStream;
)


(
// hardcodes this value to result of rrand
p = Pseq([10,20,30], rrand(1,3));
q = p.asStream;
)

(
p = Plazy({  // force a pattern to come into existence again
    Pseq([10,20,30], rrand(1,3));
});
q = p.asStream;
)

q.next;
q.nextN(40);
q.reset;


////

Event
// Events - a type of collection
// events are unordered collections - a namespace of sorts
// a hashmap?? lmao

e = (guppy: 5, goldfish: 3, minnow: 4);
e[\minnow]
e[\goldfish]
e[\goldfish] = e[\goldfish] + 3
e[\beta] = 2;

// Why Events?
// Events are used to store actions, which can be PLAYED

(type: \note).play  // default
(freq: 400, amp: 0.5, pan: -0.5, sustain: 3).play
(instrument: \pulse, sustain: 3, amp: 0.5, width: 0.05, blurf: 7).play;


// Lots of built in event types
Event.eventTypes.keys;