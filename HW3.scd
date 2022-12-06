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





// ----------
// Problem 2.
// Write a line of code that returns the number of audio channels in the drum loop file, and another line of code that returns the duration (seconds) of the desk bell file. No need to produce any sound — just print/return the buffer information.





// ----------
// Problem 3.
// Write a UGen function (not a SynthDef) that plays desk bell sample once, at its original playback rate. Make sure to account for the possibility of mismatched sample rates. The Synth should free itself when it reaches the end of the sound file.





// ----------
// Problem 4.
// Convert the UGen function from the previous problem into a SynthDef. Declare arguments for the bufnum, the playback rate, the overall signal amplitude, and the output bus. After adding the SynthDef, create a few Synths to show that your SynthDef works correctly.





// ----------
// Problem 5.
// Use an iteration method to create five Synths from the SynthDef you created. Each Synth should play the desk bell sample at a unique playback rate, resulting in a five-voice chord. Make sure the amplitude of the overall sound doesn't clip above 0 dB (use s.meter to monitor output signal levels).





// ----------
// Problem 6.
// Modify the existing SynthDef with a new argument used to determine whether playback will loop. Also, add a sustaining amplitude envelope with a gate argument, so that the Synth can be faded out at any time. Distribute doneActions appropriately. After modifying the SynthDef, create a Synth which endlessly loops through the drum sample at its original rate, backwards. Add another line of code that closes the envelope gate.





// ----------
// Problem 7.
// Use iteration to create three Synths that loop-play the drum sample backwards. Their playback rates should be slightly different (e.g. -0.99, -1.0, -1.01), so that these three Synths drift out of phase with each other over time. Make sure the amplitude of the overall sound doesn't clip above 0 dB. Write another line of code that fades out all three Synths.

