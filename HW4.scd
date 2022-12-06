// HW4

// First, save this scd file as a new file, renaming it with your Last name at the beginning of the file name (e.g. "Fieldsteel HW4.scd"). Write your answers and upload this renamed file to the course website for your submission.

// ----------
// Problem 1.
// Using a pattern or combination of patterns, create an infinite-length stream that begins at zero and counts upward by five (0, 5, 10, 15...). On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.




// ----------
// Problem 2.
// Modify your previous answer so that the stream counts from 0 to 40 by five, then from 40 to 0 by eight, producing the following sequence, repeated indefinitely: (0, 5, 10, 15, 20, 25, 30, 35, 40, 32, 24, 16, 8). DO NOT use one long Pseq, even if it might be considered the most "efficient" solution - the exercise here is to come up with an alternative. On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.




// ----------
// Problem 3.
// Using a pattern or combination of patterns, create an infinite-length stream that outputs the number 60 approximately 85% of the time, the number 67 approximately 11% of the time, and the number 70 approximately 4% of the time. On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.




// ----------
// Problem 4.
// Using a pattern or combination of patterns, create an infinite-length stream that randomly outputs one of the following three things: (1) The number one, once, (2) the number 0.5, twice in a row, or (3) the number 0.25, four times in a row. Each of these three possibilities should have an equal probability of occurring, but the the same outcome should never occur twice in a row (e.g. we should never get the number 0.25 eight times in a row).




// ----------
// Problem 5.
// Using a pattern or combination of patterns, create an infinite-length stream that starts at one and counts upward by one, but skips every multiple of five, e.g.: (1, 2, 3, 4, 6, 7, 8, 9, 11, 12, 13, 14, 16, 17, 18, 19...). On a separate line, use 'nextN' to return an array of several output values to demonstrate the correctness of your stream.





// ----------
// Problem 6.
// Boot the server. Create and add a SynthDef that plays a triangle oscillator with a percussive envelope applied to it. Include arguments for frequency, amplitude, stereo pan position, envelope attack & release, and output bus. Separately, create a few Synths to demonstrate your SynthDef.






// ----------
// Problem 7.
// Create and play a Routine that generates an infinite sequence of Synths, using the stream values from Problem 3, treated as MIDI note numbers. The attack and release times of each Synth should be very short, but long enough that the pitch of each note is perceptible. The Routine should wait for 0.15 seconds after generating each Synth. Write a separate line of code that stops the Routine.





// ----------
// Problem 8.
// Relying on a custom instance of TempoClock, modify the Routine from the previous problem so that when it plays, it now also uses output values from the stream in Problem 4 as durations, treated as beats at a tempo of 108 bpm. In other words, the rhythmic behavior of the Routine will be a random sequence of (1) a quarter note, (2) two eighth notes, and (3) four sixteenth notes, but never the same rhythmic unit twice in a row. Write a separate line of code that stops the Routine.






// ----------
// Problem 9.
// Rewrite the previous problem using Pbind instead of Routine.






// -------------------
// Bonus Problem (+3).
// Do these exercises spark ideas for other creative applications of algorithmic sequencing? Extend the content of Problems 8–9 by applying algorithmic sequences to other Synth parameters. Optionally, modify/augment the SynthDef, and/or create additional Routines/Pbinds that play in parallel. Get creative and make some interesting melodies/rhythms/textures/drones!