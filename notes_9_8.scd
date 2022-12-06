/**

Three separate programs:
1. IDE
2. Server
3. Programming language?

The server does not launch with the IDE. Must be booted separately:
`s.boot`

**/

s.boot;  // boots the server
s;
s.quit;  // quits the server

/**

`s` is special - by convention, `s` is a reference to the server application.
You can, but probably shouldn't overwrite `s`.

To fix:

```
s = Server.local;
```

**/

/**

UGens (unit generators) are the basic building blocks for signal processing.
These include:
- Oscillators
- Pulse waves
- Noise generators
- Filters
- Granular synthesis
- Delay lines
- Weird stuff

There are about 600-800 unit generators.

Cmd/Ctrl + D to bring up help file on highlighted text.

What is a digital audio signal?
- A sequence of floating point numbers
- Strung together, they form the shape of the signal
- Digital audio systems run at a sample rate that processes samples at a specific rate

All UGens implement these methods:
- ar() (audio rate, produces samples at the sample rate)
- kr() (control rate, produces one sample per block aka less samples / lower sample resolution)
- ir() (initialization rate; generates a single value and holds that value forever; a constant)

Audio rate is used for high frequency signals or actual audible signals.
Control rate is when we don't need as much resolution.
LFOs and envelopes are usually good candidates for KR.

Hello world?
{ SinOsc.ar }.play;
Cmd/Ctrl + Period (.) to stop sound

**/

// Ctrl + Shift + Spacebar to view parameters
// Tab to autocomplete parameters
{SinOsc.ar(freq: 300, phase: 0, mul: 0.2, add: 0)}.play;

// Stereo sine wave (the ! 2 duplicates the signal and puts into Array)
{SinOsc.ar(freq: 300) ! 2}.play;

{LFTri.ar(freq: 300) ! 2}.play;
{Saw.ar(freq: 300) ! 2}.play;
{Pulse.ar(freq: 300) ! 2}.play;
{PinkNoise.ar(freq: 300) ! 2}.play;

{LFSaw.ar(freq: 300) ! 2}.plot;
{Saw.ar(freq: 300) ! 2}.plot;

{LFSaw.ar( freq: XLine.kr(20,20000,10) * 0.1 ! 2 )}.plot;

/// Changing a sound as it plays

// Static sin osc
(
~fn = {
	var sig;
	sig = SinOsc.ar(freq: 260);
	sig = sig * 0.1;
	sig = sig ! 2;
};
)

x = ~fn.play;

// Changing frequency
(
~fn = {
	arg freq = 260, freqtime = 2;
	var sig;
	freq = freq.lag(freqtime);
	sig = SinOsc.ar(freq: freq);
	sig = sig * 0.1;
	sig = sig ! 2;
};
)

x = ~fn.play;

x.set(\freq, exprand(200, 2000));

x.free;'
