(
~stealing = ();
~stealing.muteGroups = ();
~stealing.softLimit = 3;
~stealing.hardLimit = 5;
~stealing.strategies = (
	\oldest: {
		|playing, current|
		playing.minItem({ |e| e.startTime })
	},
	\newest: {
		|playing, current|
		playing.maxItem({ |e| e.startTime })
	},
	\nearest: {
		|playing, current|
		playing.minItem({ |e|
			(e.use(_.freq) - current.use(_.freq)).abs
		})
	},
	\random: {
		|playing, current|
		playing.choose
	},
	\wrandom: { |playing, current|
		var weights = playing.collect{|ev| if(ev.chan ==0){10}{1}};
		playing.wchoose(weights.normalizeSum)
	}
);
~stealing.strategyNow = \random;

Pdef(\muteGroup).clear;
Pdef(\muteGroup, Pfunc({
	|event|
	var voiceToFree, voices = ~stealing.muteGroups[event.muteGroup];

	event[\startTime] = thisThread.clock.beats;
	//event.postln;
	//voices = voices.select(_[\isPlaying]); // purge any non-playing voices
	while { voices.size > (~stealing.softLimit - 1) } {
		voiceToFree = ~stealing.strategies[~stealing.strategyNow].(voices, event);
		if (voices.size > (~stealing.hardLimit - 1)) {
			"Way too many voices, freeing voice at % chan %".format(voiceToFree.midinote, voiceToFree.chan).postln;
			//voiceToFree.free; // free immediately
			~mOut.noteOff(voiceToFree.chan, voiceToFree.midinote);
		} {
			"Gating voice at % chan %".format(voiceToFree.midinote, voiceToFree.chan).postln;
			~mOut.noteOff(voiceToFree.chan, voiceToFree.midinote);
			//voiceToFree.set(\gate, 0); // let envelope free in due course
		};
		voices.remove(voiceToFree);
	};

	voices = voices.add(event);
	~stealing.muteGroups[event.muteGroup] = voices;

	event; // pass the event along
}));

~stealing.mainstream = (Pdef(\muteGroup) <> Pbind(
	\type, \midi,
	\midiout, ~mOut,
	\muteGroup, \a,
	\hasGate, false,
)).asStream;

~stealing.clearGroups = { |self|
	self.muteGroups[\a].collect{|ev|
		~mOut.noteOff(0, ev.midinote.postln);
	};
	self.muteGroups.clear
};
)

//
// ////////////// SEHR WICHTIG, DAS MUSS VOR ALLEN ANDEREN AUSGEFUEHRT WERDEN
// ~mOut = ConnectVirmidi()
// //
// (~mainstream.next((freq: 440))).play; // next event
//
// ~stealing.muteGroups[\a].size
//
// ~lastGroup = Group.after(1);
//
// (a: [1, 23]).values
//
// l = LinkClock.new.permanent_(true)
//
// ~mel.startMel
// ~mel.playMidiVoices.play
//
// ~mel.muteGroups[\a].size
// (~stealing[\mainstream].next((freq: 60.midicps.postln))).play;
// ~softLimit = 1;
// ~hardLimit = 6;
// Pdef.clear
// p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
// b = Buffer.read(s, "/home/vincent/Soundfiles_48khz/seulki_gesang.wav");
// b = Buffer.read(s, p);
// b.play
// ~mel.midichn = 0
// ~stealing.strategyNow = \nearest;
//
// ~mel.chordSize = 0
// ~mel.quantVal = 1/74
// ~mel.setScale(Scale.chromatic)
//
// 277.18263097687.cpsmidi
