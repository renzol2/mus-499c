(
Window.closeAll;
b = 3.collect({
    3.collect({
        Button().minHeight_(100)
        .minWidth_(100)
    });
});


w = Window.new.front
.alwaysOnTop_(true)
.layout_(
    GridLayout.rows(
        b[0],
        b[1],
        b[2]
    )
)

)

s.boot;
(
SynthDef(\sound, {
    var sig, mod;
    mod = SinOsc.kr(\modhz.ir(8)).bipolar(\modamp.ir(10));
    sig = LFTri.ar(\freq.ir(400) + mod);
    sig = sig * \amp.kr(0.2);
    sig = sig * Env.perc(\atk.ir(0.01), \rel.ir(0.2)).kr(2);
    sig = Pan2.ar(sig, \pan.ir(0));
    Out.ar(\out.ir(0), sig);
}).add;
)

(
p = Pbind(
    \instrument, \sound,
    \dur, 1/8,
    \freq, Pseq([
        413.0, 797.0, 291.0, 1745.0, 144.0, 1962.0, 907.0
    ], inf) + Pbrown(-100, 100, 5, inf),
    \modamp, Pexprand(1, 100, inf),
    \amp, 0.2,
    // \out, ~wobbleBus
);
)

~seq = p.play;

s.scope;
Synth(\sound, [modhz: 40, modamp: 400, rel: 4, pan: 1]);