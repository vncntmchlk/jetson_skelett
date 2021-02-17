
SynthDef(\beep, { arg out, freq, sustain=1, amp=1, pan;
	var env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction: Done.freeSelf);
	Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0.5pi, amp * env), pan));
}).add;

SynthDef(\sawBeep, { arg out, freq, sustain=1, amp=1, ffreq = 3000;
	var env = EnvGen.kr(Env.perc(0.01, sustain), 1, doneAction: Done.freeSelf);
	var sig = Saw.ar(freq, amp * env);
	sig = LPF.ar(sig, ffreq);
	Out.ar(out, sig ! 2);
}).add;

SynthDef(\dusty, { arg out, freq, sustain=1, amp=1, dens= 30, ffreq = 500, rq = 0.5;
	var env = EnvGen.kr(Env.linen(0.003,sustain,0.01), 1, doneAction: Done.freeSelf);
	var sig = Dust.ar(dens) * env;
	sig = RLPF.ar(sig, ffreq, rq);
	Out.ar(out, sig * amp);
}).add;

SynthDef(\dusty2, { arg out1, out2, freq, sustain=1, amp1=1, amp2=1, dens= 30, ffreq = 500, rq = 0.5;
	var env = EnvGen.kr(Env.linen(0.003,sustain,0.01), 1, doneAction: Done.freeSelf);
	var sig = Dust.ar(dens) * env;
	sig = RLPF.ar(sig, ffreq, rq);
	Out.ar(out1, sig * amp1);
	Out.ar(out2, sig * amp2);
}).add;

SynthDef(\dusty2comb, { arg out1, out2, freq, sustain=1, amp1=1, amp2=1, dens= 30, del = 0.001, fb = -0.2;
	var env = EnvGen.kr(Env.linen(0.003,sustain,0.01), 1, doneAction: Done.freeSelf);
	var sig = Dust.ar(dens) * env;
	sig = CombN.ar(sig, 0.01, del, fb);
	Out.ar(out1, sig * amp1);
	Out.ar(out2, sig * amp2);
}).add;

SynthDef(\pinkStab, { arg out, freq, sustain=1, amp = 0.1, ffreq = 500, rq = 0.5;
	var env = EnvGen.kr(Env.linen(0.2,sustain,0.01), 1, doneAction: Done.freeSelf);
	var sig = PinkNoise.ar(0.1) * env; //* Decay2.ar(Impulse.ar(impFreq), att, dec)
	sig = RLPF.ar(sig, ffreq, rq);
	Out.ar(out, sig * amp);
}).add;

SynthDef(\pinkStab2, { arg out1, out2, freq, sustain=1, amp1=1, amp2=1, ffreq = 500, rq = 0.5;
	var env = EnvGen.kr(Env.linen(0.2,sustain,0.01), 1, doneAction: Done.freeSelf);
	var sig = PinkNoise.ar(0.1) * env; //* Decay2.ar(Impulse.ar(impFreq), att, dec)
	sig = RLPF.ar(sig, ffreq, rq);
	Out.ar(out1, sig * amp1);
	Out.ar(out2, sig * amp2);
}).add;