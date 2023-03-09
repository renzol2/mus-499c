// HW2

// Save this scd file in a new folder, and name that folder "LastName_HW2". Write your work in this scd file, and copy any necessary audio files into this folder as well. When finished, zip the folder and upload it to the course website.

// Setup server
(
ServerOptions.devices; // all devices
ServerOptions.inDevices; // input devices
ServerOptions.outDevices; // output devices

s.options.numOutputBusChannels = 24;
s.options.numWireBufs = 1024;
s.options.outDevice = 'Audio Out';
s.options.sampleRate = 44100;

s.boot;
)

// ----------
// Overview: For this assignment, you will make a spatial recording of a sound object using a first-order A-format tetrahedral ambisonic microphone, encode this information as an ambisonic signal, creatively manipulate the soundfield by processing the ambisonic signal, and decode it for the Studio Z dodecahedron. Consider this as a preliminary exercise that will lead you into more in-depth creative ambisonic work.





// ----------
// Step 1: Identify one or two interesting sound-producing objects that can be brought into the studio. I recommend using the seminar space just outside of Studio Z (MB 4029B), moving the table and chairs aside. Set up the ambisonic mic as demonstrated in class, and record 30-60 seconds of your sound object(s) while moving the object(s) around in three dimensions.

// Tip: Be sure to adjust the preamplifier gain on the 4 preamp channels so that the capsules are closely gain-matched. You can do this by playing a tone from your phone directly into each capsule (on-axis) from a constant distance, and adjusting the preamp gain knobs until the signal levels are sufficiently close in the receiving software. I found that channel two needed to be a bit higher than the others.

// Tip: Remember to connect the microphone to the preamp in "rainbow" order (red, yellow, green, blue).

// Tip: After recording, you may find it beneficial to apply a high pass filter with a relatively low cutoff frequency (~50 Hz) to reduce low frequency noise that may be present in the signal.





// ----------
// Step 2: Export/Render your A-format recording as a four-channel AIFF or WAV file. You can do this in Audacity by selecting "Use Advanced Mixing Options" in the "Import/Export" preferences dialog.





// ----------
// Step 3: In Studio Z, write some code that encodes the A-format recording as a first-order B-format HOA signal. This process may involve two steps: one to convert from A-format to B-format (see 'newAtoB') and another to convert from the FOA to HOA toolset (see the help file titled "Ambisonic Format Exchange" — you'll need to convert to the correct component ordering, normalization, and reference radius). There may be other approaches, but this approach seemed to worked well, and seemed to be consistent with the intended use of the FOA/HOA tools.

// Old files
(
b = [
	Buffer.read(s, "A-format-test-1_2023-02-15.aiff".resolveRelative),
	Buffer.read(s, "A-format-test-2_2023-02-15.aiff".resolveRelative),
];
)

// My files
(
b = [
	Buffer.read(s, "A-format-test-1_2023-03-08.aiff".resolveRelative),
	Buffer.read(s, "A-format-test-2_2023-03-08.aiff".resolveRelative),
];
)

// A-format-testing_2023-02-25
(
~encoder = FoaEncoderMatrix.newAtoB('flu', 'uns');
~foaToHoa = HoaMatrixEncoder.newFormat(AtkFoa.format, AtkFoa.defaultOrder);
~decoder = HoaMatrixDecoder.newModeMatch(
	directions: ~directions,
	beamShape: \energy,
	match: \energy,
	order: 1
);
)

// Ambisonic Format Exchange
(
~encoder = HoaMatrixEncoder.newFormat(
	AtkFoa.format,
	AtkFoa.defaultOrder
);
)


// ----------
// Step 4: Before applying soundfield transformations, decode your B-format signal for the dodecahedron loudspeaker array, to verify that the soundfield image is correct. You may find it useful to look back at the previous homework assignment to revisit decoding techniques.

// Directions for dodecahedron
(
~directions = [
	// 1 - 5
	[36, 75], [108, 75], [180, 75], [-108, 75], [-36, 75],

	// 6 - 10
	[36, 20], [108, 20], [180, 20], [-108, 20], [-36, 20],

	// 11 - 15
	[0, -20], [72, -20], [144, -20], [-144, -20], [-72, -20],

	// 16 - 20
	[0, -75], [72, -75], [144, -75], [-144, -75], [-72, -75],
].degrad;
)

// Play signal
(
{
	var sig;
	sig = PlayBuf.ar(4, b[0], BufRateScale.ir(b[0]), doneAction:2);
	sig = HPF.ar(sig, 60);
	sig = FoaEncode.ar(sig, ~encoder);
	sig = HoaNFCtrl.ar(
		in: HoaEncodeMatrix.ar(sig, ~foaToHoa),
		encRadius: AtkFoa.refRadius,
		decRadius: AtkHoa.refRadius,
		order: 1
	);
	sig = HoaDecodeMatrix.ar(sig, ~decoder);
}.play
)




// ----------
// Step 5: Insert a soundfield processing technique of your choice between the encoding and decoding parts of your code. You are free to explore, but your processing technique should make something interesting happen! I recommend HoaZoom or HoaFocus, and perhaps using various UGens to control the distortion angle, azimuth, and/or elevation. Alternatively, you could incorporate Pbind and sequencing techniques. You are also encouraged to experiment with processing the source itself (filters, delays, etc.), in addition to processing its spatial imagery.

// Play signal
(
{
	var sig;
	sig = PlayBuf.ar(4, b[0], BufRateScale.ir(b[0]), doneAction:2);
	sig = HPF.ar(sig, 60);
	sig = FoaEncode.ar(sig, ~encoder);
	sig = HoaNFCtrl.ar(
		in: HoaEncodeMatrix.ar(sig, ~foaToHoa),
		encRadius: AtkFoa.refRadius,
		decRadius: AtkHoa.refRadius,
		order: 1
	);
	sig = HoaDecodeMatrix.ar(sig, ~decoder);
}.play
)




// ----------
// Step 6. When finished, your code should be written in such a way that I can easily run it myself, on my own computer, after downloading your submission, without having to change anything. Be sure to include your A-format source file with your submission! Add comments in your code, if you feel they are necessary. Finally, compress everything as a zip file and upload it to the course website.





