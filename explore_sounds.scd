~path   = "/home/vincent/SC/soundfiles/klavier_sf/akkord1.wav";
~ezConv = EZConv(~path);

Ndef(\src, { PinkNoise.ar(0.5 ! 2) * Decay2.ar(Impulse.ar(0.5), 0.15, 0.75)})
Ndef(\src, { RLPF.ar(Dust.ar(\dens.kr(20)), \ffreq.kr(500), \rq.kr(0.5)) ! 2})

Ndef(\conv, {
	var o = Ndef.ar(\src); // stereo source
	~ezConv.ar(o) * 0.1; // watch out for gain buildup when convolving.
}
)

Ndef(\conv).play

Ndef(\src).set(\rq, 0.9)
Ndef(\src).set(\ffreq, 3000)
Ndef(\src).set(\dens, 5)

Ndef(\src).gui



// pro farbe anderes conv file
(
s.waitForBoot {
	~makeGroups = {
		~sourceGroup = Group.new();
		~convGroup = Group.after(~sourceGroup);
	};
	ServerTree.add(~makeGroups);
	~makeGroups.();
	~convPaths = [
		"/home/vincent/SC/soundfiles/klavier_sf/akkord1.wav",
		"/home/vincent/SC/soundfiles/klavier_sf/Bsaite1_kurz.wav",
		"/home/vincent/SC/soundfiles/klavier_sf/cluster6.wav",
		"/home/vincent/SC/soundfiles/klavier_sf/daempfer15.wav",
		"/home/vincent/SC/soundfiles/klavier_sf/flageolett9.wav",
		"/home/vincent/SC/soundfiles/klavier_sf/schlag8.wav"
	];
	~convBusses = Bus.audio(s) ! ~convPaths.size;
	~startConvSynths = {
		{
			~convSynths = ~convPaths.collect { |path ix|
				var ez = EZConv(path);
				s.sync;
				{Out.ar(0, ez.ar(In.ar(~convBusses[ix])) * \amp.kr(0.1))}.play(target: ~convGroup)
			}
		}.fork
	};
	ServerTree.add(~startConvSynths);
	~startConvSynths.();
};
)

ServerTree.removeAll;