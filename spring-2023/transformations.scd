// three workflows: encoding, transformations, and decoding
// transformations are where the "interesting" things happen

// transformations are just deciding what signals are played at what volumes
// out of what channels (which correspond) to different monitors

// we have azimuth and elevation angles, but what about distance?
// HOA tools have a parameter for radius
// wavefront -> curvature of the sound wave as it hits a listener

HoaNFCtrl  // controls how far away a sound is

// reference radius, one of the components of ambisonics
AtkFoa.refRadius

(
{
	var sig;
	sig = PlayBuf.ar(2, ~ocean, BufRateScale.ir(~ocean), startPos: SampleRate.ir * 20);
	sig = HoaEncodeDirection.ar(sig[0], 45.degrad, 0.degrad, 1.5, 3);
	sig = HoaNFCtrl.ar(sig, 1.5, MouseX.kr(0.01, 50, 1).poll, 3);
	sig = HoaDecodeMatrix.ar(sig, ~decoder);
}.play;
)

/// Transformations
FoaXformDisplay.new;

// useful transformations: `rotate`, `tilt`, `tumble`
HoaRTT // - `rtt` is a combination of all of them
// - `direct`: "focuses" a sound?
HoaZoom // - `push` and `zoom`: similar to `direct`
HoaDominate
HoaFocus
// these are axial transformations

HoaUGen.browse

(
{
	var sig;
	sig = PlayBuf.ar(2, ~birds, BufRateScale.ir(~birds), startPos: SampleRate.ir * 20);
	sig = HoaEncodeMatrix.ar(
		sig,
		HoaMatrixEncoder.newDirections(
			directions: [[90, 75], [-90, 75]].degrad,
			beamShape: \controlled,
			match: \rms,
			order: 3
		)
	);

	// Transform here!
	/*sig = HoaZoom.ar(
		in: sig,
		angle: MouseX.kr(0, pi/2).poll,
		theta: -45.degrad,
		phi: 0,
		radius: 1.5,
		order: 3
	);*/

	sig = HoaTilt.ar(
		in: sig,
		angle: MouseX.kr(0, 2pi).poll,
		order: 3
	);

	sig = HoaDecodeMatrix.ar(sig, ~decoder);
}.play
)
