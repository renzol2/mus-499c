// HW1

// Save this scd file in a new folder, and name that folder "LastName_HW1". Write your answers in this scd file, and copy any necessary audio files into this folder as well. When finished, zip the folder and upload it to the course website.

// ----------
// Problem 1.
// The Studio Z loudspeakers are (roughly) positioned at the vertices of a regular dodecahedron. Assuming your head is at the center of the array while seated, create an array of 'directions' that represents the location of each loudspeaker. The information for each speaker should be an array containing an azimuth angle and elevation angle, and the internal arrays should be in the same order as the numbering of the loudspeakers (they're labeled with tape). Note that there is a geometrically "correct" answer to this question, but your answer doesn't have to be perfect, because the loudspeaker array isn't a "perfect" dodecahedron, either, and your head usually isn't at the exact center. Just get reasonably close by making educated guesses. You can also use the tape measure provided in Studio Z to measure distances and do a bit of trigonometry. You can provide your values in degrees, just keep in mind they'll need to be converted to radians later on (using ".degrad").

// As a reference, here is an array of directions representing a horizontal (2D) quadraphonic loudspeaker array in a square room, all positioned on the equatorial plane (level with your head):

// front-left, back-left, back-right, front-right
~directions = [[45, 0], [135, 0], [-135, 0], [-45, 0]];






// ----------
// Problem 2.
// Create a 1st-order ambisonic decoder (using the HOA toolset) for the Studio Z dodecahedron array, using ".newModeMatch", and your array of directions from the previous problem.






// ----------
// Problem 3.
// The ATK includes example B-format files, which are in "traditional" B-format (FuMa/MaxN). If the ATK is installed on your computer, you can print the location of this sound file directory by evaluating:

Atk.userSoundsDir;

// Select one of the B-format files from the Atk sounds library, copy it to your HW folder, and load it into a Buffer. Write your code so that I'll be able to load this sound file without having to rewrite anything (e.g. thisProcess.nowExecutingPath or a similar technique).

// Then, create a 1st-order ambisonic encoder that encodes from FuMa/MaxN to the HOA default format, which is ACN/N3D. The easiest way to to this is by using the ".newFormat" method for the HoaMatrixEncoder class, providing an appropriate symbol (represnting the source format) and the ambisonic order. You can evaluate

AtkHoa.formatDict;

// to return a dictionary of valid symbols. \fuma is the correct choice in this case, since the ATK's B-format example files are in this format.









// ----------
// Problem 4.
// Create and play a UGen function that generates an audio signal from reading the B-format file (PlayBuf), encodes the B-format signal to ACN/N3D format using your encoder from the previous problem (HoaEncodeMatrix), and decodes this signal for the dodecahedron array using your decoder from Problem 2 (HoaDecodeMatrix).






// ----------
// Problem 5.
// Create a 3rd-order decoder for the Studio Z dodecahedron array. This should be nearly identical to your decoder from Problem 2.






// ----------
// Problem 6.
// Record yourself speaking the following eight phrases:

/*
"up front left"
"up front right"
"up back left"
"up back right"
"down front left"
"down front right"
"down back left"
"down back right"
*/

// Quality isn't the focus here — feel free to record using your phone, or your computer's built-in microphone — whatever is easiest/fastest for you. Cut and export your recordings (e.g. using Audacity) so that you have eight separate wav/aiff files. Then, load these recordings into eight one-channel Buffers in SC. Again, write your code so that when I run it, it'll work without me having to change or rewrite anything.







// ----------
// Problem 7.
// Create and add a SynthDef that generates a monophonic signal by playing one of these buffers (PlayBuf), encodes that monophonic signal as a directional 3rd order ambisonic signal (HoaEncodeDirection), and then decodes this signal for the dodecahedron array using the decoder from Problem 5. Your SynthDef must include arguments for bufnum, azimuth angle, and elevation angle.






// ----------
// Problem 8.
// Create and play a Pbind that plays each of your eight buffers, one-by-one, and spatializes each one along the appropriate vector in 3D space, based on the spoken text. For example, "up front left" should appear to emanate 45 degrees left of front, and 45 degrees above the equatorial plane.






