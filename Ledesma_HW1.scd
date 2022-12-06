// HW1

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW1.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// The following code produces an error when evaluated. Remember to use the correct keystroke to evaluate the code. Correct the error and add a comment indicating the problem.

(
var oranges = 3; // requires `var` keyword when declaring a variable
oranges = oranges * 2;
oranges = oranges - 1;
)






// ----------
// Problem 2.
// The following code produces an error when evaluated. Correct the error and add a comment indicating the problem.

(
var oldBalance, deposit, newBalance;
oldBalance = 5;  // requires a semicolon
deposit = 100;
newBalance = oldBalance + deposit;
)





ir
// ----------
// Problem 3.
// The following code produces an error when evaluated. Correct the error and add a comment indicating the problem.

(
var classroomSize, numClasses, totalStudents;
classroomSize = 30;
numClasses = 4;
totalStudents = classroomSize * numClasses;  // variable spelled incorrectly
)






// ----------
// Problem 4.
// The following code produces an error when evaluated. Correct the error and add a comment indicating the problem.

(
~func = {
	arg x = 5, y = 6, z = 7;  // keyword `arg` should not be followed by a comma
	var product;
	product = x * y * z;
};
)






// ----------
// Problem 5.
// Consider the following expression. "odd" returns a Boolean value indicating whether its receiver is an odd number. It is written exclusively in the "receiver-dot-method" syntax. Rewrite this expression so that it is exclusively in the "method(receiver)" syntax.

45.squared.odd;
odd(squared(45));  // rewritten






// ----------
// Problem 6.
// Write a comment that explains why the following code expression produces an error message when evaluated.

45.odd.squared;

// odd(45) produces a boolean value, which is the incorrect parameter type
// for the `squared` function




// ----------
// Problem 7.
// Create a function that accepts an Array as its input argument, and returns an Array that is identical except the first and last items have swapped places. If the input array contains exactly one or zero items, the function should return the exact same array it was given. After creating this function, include one or more additional lines of code that evaluate the function, to demonstrate that it works correctly.

(
~swapFirstAndLast = {
	|arr|
	if ( arr.size == 0,
		{ arr },
		{ arr.swap(0, arr.size - 1) }
	)
};

~swapFirstAndLast.(["hi", 1, 2, 3]).postln;
~swapFirstAndLast.(["hi"]).postln;
~swapFirstAndLast.([]).postln;
)




// ----------
// Problem 8.
// Write a function that accepts a pitch and octave indicator. (e.g. "C4", "Bb5", "Ds3") and returns the corresponding MIDI note number. You can design your function to accept strings or symbols, but not necessarily both. I recommend using "s" for sharp instead of "#", but this is not required. For example, "C4" should return 60, "Cs4" should return 61, "B3" should return 59, and so on. Your function should be able to handle at least all 88 pitches present on a piano (A0 through C8).

// Some potentially useful methods:

// symbol-string conversion:

"hello".asSymbol.class;	// -> Symbol
\hello.asString.class;	// -> String

// "last" returns the last character in a string,
// and "digit" converts a character to an integer:

"C4".last.digit; 		// -> 4

// "drop" removes one or more characters from either end
// of a string, depending on the sign of the argument:

"supercollider".drop(1);	// -> "upercollider"
"supercollider".drop(-3);	// -> "supercolli"

(
// Maps pitch letter names to pitch classes
~pitchLetterNameToClass = Dictionary[
	\C -> 0,
	\D -> 2,
	\E -> 4,
	\F -> 5,
	\G -> 7,
	\A -> 9,
	\B -> 11,
];

// Maps accidental names to modifiers
~accidentalToModifier = Dictionary[
	\bb -> -2,  // double flat?
	\b  -> -1,  // flat
	\n  ->  0,   // natural
	\s  ->  1,   // sharp
	\ss ->  2,   // double sharp?
];

// Converts note to MIDI number in the format "[pitch letter][accidental][octave]".
// - pitch letter corresponds to { C, D, ..., A, B }
// - accidental can be 'b' (flat), 'n' or ommitted (natural), or 's' (sharp)
// - octave is an integer from 0 to 8
~noteToMidi = {
	|noteName|
	var pitch, pitchName, pitchClass, accidental, accidentalModifier, octave;
	pitch = noteName[0..noteName.size-2];

	// get pitch class
	pitchName = pitch.first;
	pitchClass = ~pitchLetterNameToClass.matchAt(pitchName.asSymbol);

	// get accidental modifier
	if (pitch.size > 1,
		{ accidental = pitch[1..pitch.size] },
		{ accidental = "n" }
	);

	accidentalModifier = ~accidentalToModifier.matchAt(accidental.asSymbol);

	// get octave
	octave = noteName.last.digit;

	((octave + 1) * 12) + pitchClass + accidentalModifier
};

// Tests noteToMidi with printed message
~testNoteToMidi = {
	|noteName, expectedMidiNumber|
	var message, actualMidiNumber;

	actualMidiNumber = ~noteToMidi.(noteName);
	message = "noteName = %, actual = %, expected = %".format(noteName, actualMidiNumber, expectedMidiNumber);

	if (actualMidiNumber == expectedMidiNumber,
		{ ("✅" + message).postln },
		{ ("❌" + message).postln }
	);
};

// Code to run tests
[
	["C8",   108],
	["Cb8",  107],
	["C3",   48],
	["C4",   60],
	["Cs4",  61],
	["Css4", 62],
	["D4",   62],
	["B3",   59],
	["As7",  106],
	["Bb7",  106],
	["E6",   88],
	["A0",   21],
	["As0",  22],
	["Ab0",  20],

].do({
	|pair|
	~testNoteToMidi.(pair[0], pair[1])
});

)







