ServerTree.removeAll;
~snd = ();
~snd.makeGroups = {
	~snd.sourceGroup = Group.new();
	~snd.convGroup = Group.after(~snd.sourceGroup);
	~snd.lastGroup = Group.after(1); // nach der Default group, fuer analyseStuff
};
ServerTree.add(~snd[\makeGroups]);
~snd[\makeGroups].();
/*~snd.convPaths = [
	"/home/vincent/SC/soundfiles/klavier_sf/akkord1.wav",
	"/home/vincent/SC/soundfiles/klavier_sf/Bsaite1_kurz.wav",
	"/home/vincent/SC/soundfiles/klavier_sf/cluster6.wav",
	"/home/vincent/SC/soundfiles/klavier_sf/daempfer15.wav",
	"/home/vincent/SC/soundfiles/klavier_sf/flageolett9.wav"
];*/
~snd.convPaths = [
	"/home/vincent/SC/nano_projekt/mit_isaac/sf/underwaterIR_kurz.wav",
	"/home/vincent/SC/nano_projekt/mit_isaac/sf/ormsound_kurz.wav"
];
~snd.convBusses = {Bus.audio(s)} ! ~snd.convPaths.size;
~snd.busFromColor = ();
[\blue, \green, \yellow, \magenta, \cyan][..~snd.convPaths.size].do { |col, ix| ~snd.busFromColor[col] = ~snd.convBusses[ix] };
~snd.startConvSynths = {
	{
		~snd.convSynths = ~snd.convPaths.collect { |path ix|
			var ez = EZConv(path, fftSize: 1024);
			s.sync;
			{
				var sig = In.ar(~snd.convBusses[ix]);
				Out.ar(4, ez.ar(sig) * 0.05);
				Out.ar(5, sig);
			}.play(target: ~snd.convGroup)
			/*{
			var sig = In.ar(~convBusses[ix]);
			Out.ar(0, (LinXFade2.ar(ez.ar(sig), sig, \xfade.kr(0.5)) * \amp.kr(0.1)) ! 2)
			}.play(target: ~convGroup)*/
		}
	}.fork
};
ServerTree.add(~snd[\startConvSynths]);
~snd[\startConvSynths].();

~snd.makeNoise = { |numPoints, planeSize|
	var ambitus = planeSize.lincurve(64, 1024, 3, 36, -2);
	var dens = numPoints.lincurve(4, 150, 1, 15);
	var frameRate = 12;
	var dur = (1 / frameRate) * (1 / dens);
	{
		dens.do {|val|
			var nn = 60 + (val.linlin(0, dens, 0, ambitus));
			Synth(\beep, [\freq, nn.midicps, \sustain, 0.05, \amp, 0.1]);
			dur.wait;
		}
	}.fork
};

~snd.playDusty = { |numPoints, planeSize, rowOffset, amp = 0.1, out = 0|
	var resonanz = planeSize.lincurve(64, 1024, 0.1, 1, -2);
	var sustainFaktor = planeSize.lincurve(64, 1024, 0.8, 2, -1);
	var dens = numPoints.lincurve(4, 150, 25, 1000);
	var ffreq = rowOffset.lincurve(0, ~bm.rows, 4500, 100, -4);
	var boostLow = rowOffset.lincurve(0, ~bm.rows,0.25,1.5,-4);
	Synth(\dusty, [
		\out, out,
		\dens, dens,
		\sustain, 1/6 * sustainFaktor,
		\ffreq, ffreq,
		\rq, resonanz,
		\amp, amp * boostLow
	],
	~snd.sourceGroup
	)
};

~snd.playDusty2 = { |numPoints, planeSize, rowOffset, amp1 = 0.1, amp2 = 0.1, out1 = 0, out2 = 0|
	var resonanz = planeSize.lincurve(64, 1024, 0.1, 1, -2);
	var sustainFaktor = planeSize.lincurve(64, 1024, 0.8, 2, -1);
	var dens = numPoints.lincurve(4, 150, 25, 1000);
	var ffreq = rowOffset.lincurve(0, ~bm.rows, 4500, 100, -4);
	var boostLow = rowOffset.lincurve(0, ~bm.rows,0.25,1.5,-4);
	Synth(\dusty2, [
		\out1, out1,
		\out2, out2,
		\dens, dens,
		\sustain, 1/6 * sustainFaktor,
		\ffreq, ffreq,
		\rq, resonanz,
		\amp1, amp1 * boostLow,
		\amp2, amp2 * boostLow
	],
	~snd.sourceGroup
	)
};

// delay vom comb koennte driften fuern coolen sound
~snd.playDusty2comb = { |numPoints, planeSize, rowOffset, amp1 = 0.1, amp2 = 0.1, out1 = 0, out2 = 0|
	var fb = planeSize.lincurve(64, 1024, 0.1, 0.5, -2);
	var sustainFaktor = planeSize.lincurve(64, 1024, 0.8, 2, -1);
	var dens = numPoints.lincurve(4, 150, 25, 1000);
	var del = rowOffset.lincurve(0, ~bm.rows, 0.001, 0.05, 2);
	var boostLow = rowOffset.lincurve(0, ~bm.rows,0.25,1.5,-4);
	Synth(\dusty2comb, [
		\out1, out1,
		\out2, out2,
		\dens, dens,
		\sustain, 1/6 * sustainFaktor,
		\del, del,
		\fb, fb,
		\amp1, amp1 * boostLow,
		\amp2, amp2 * boostLow
	],
	~snd.sourceGroup
	)
};

~snd.playPinkStab = { |numPoints, planeSize, rowOffset, amp = 0.1, out = 0|
	var resonanz = planeSize.lincurve(64, 1024, 0.1, 1, -2);
	var sustainFaktor = planeSize.lincurve(64, 1024, 0.8, 2, -1);
	var ffreq = rowOffset.lincurve(0, ~bm.rows, 4500, 100, -4);
	var boostLow = rowOffset.lincurve(0, ~bm.rows,0.25,1.5,-4);
	Synth(\pinkStab, [
		\out, out,
		\sustain, 1/2 * sustainFaktor,
		\ffreq, ffreq,
		\rq, resonanz,
		\amp, amp * boostLow
	],
	~snd.sourceGroup
	)
};

~snd.playPinkStab2 = { |numPoints, planeSize, rowOffset, amp1 = 0.1, amp2 = 0.1, out1 = 0, out2 = 0|
	var resonanz = planeSize.lincurve(64, 1024, 0.1, 1, -2);
	var sustainFaktor = planeSize.lincurve(64, 1024, 0.8, 2, -1);
	var ffreq = rowOffset.lincurve(0, ~bm.rows, 4500, 100, -4);
	var boostLow = rowOffset.lincurve(0, ~bm.rows,0.25,1.5,-4);
	Synth(\pinkStab2, [
		\out1, out1,
		\out2, out2,
		\sustain, 1/2 * sustainFaktor,
		\ffreq, ffreq,
		\rq, resonanz,
		\amp1, amp1 * boostLow,
		\amp2, amp2 * boostLow
	],
	~snd.sourceGroup
	)
};
