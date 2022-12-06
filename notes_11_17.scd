s.boot;

x = Synth(\default);

x = Synth(\default);
x.set(\freq, 800);

x.free;

// Under the hood, SC sends OSC messages whenever we do
// pretty much anything in SC. ex. creating a synth, deleting a node, etc.
// For more details, see the help file: Server Command Reference

// To send OSC to a device, you need the local IP of that address and
// the port that device is using to listen to.

~renzo = NetAddr.new("10.194.235.154", 57120);
~eli = NetAddr.new("10.193.51.47", 57120);

~eli.sendMsg('/test', -3, 0.1, 'can i send stuff here? - renzo');

// Creating an OSCdef:
(
OSCdef(\receiver, {
    arg msg;
    msg.postln;
    Synth(\default, [ freq: msg[1].midiratio ]);
}, '/test')
)
// This only reponds to messages with the address '/test'

// Laptop ensemble moment!!!!!!

// Debug mode:
OSCFunc.trace(true);  // or false

// this is for USB controls? GCC?
SerialPort
