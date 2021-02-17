(
s.waitForBoot {
	l = LinkClock.new().permanent_(true);
	if(MIDIClient.initialized.not){
		~mOut = ConnectVirmidi();
	};
	~useMidi = false; // bezieht sich auf midiCC
	"snd.scd".loadRelative;
	"synthDefs.scd".loadRelative;
	"globalObjects.scd".loadRelative;
	"initValues.scd".loadRelative;
	"sourceSounds.scd".loadRelative;
	"bodyOsc.scd".loadRelative;

	"topSoundLayer/fluidStuff_clean.scd".loadRelative;
	"topSoundLayer/voice_stealing.scd".loadRelative;
	"topSoundLayer/metaFuncs.scd".loadRelative;
	w = ~newGui.(); // rows, cols, numDelays 56 56 3
};
)


/// Die metafuncs testen und welche dazunehmen die midichns tauschen

OSCFunc.trace(false, true)
ServerTree.removeAll; // gruppen und conv synths raushauen
// data easy mapping
~draw = (
	skelett: true,
	diff: false,
	fields: false,
	keypoints: false
);

~analysis = (
	kpDiffThresh: 15,
	squareTest: { |self, sq| (sq[0] > 4) && (sq[1] > 4)},
	clusterBounds: 2
);

~ctl = (
	alphaInc: 0.1,
	alphaDec: 0.2,
	clusterDec: 8
);

~mel.startMel(4); // channel 4 wo alles nach bw geht (und 5
~mel.playMidiVoices.play;
~mel.quantVal = 1/2
~mel.melSynth.set(\thresh, 0.05);
~mel.setScale(Scale.harmonicMinor)
~mel.setScale(Scale.chromatic)
~mel.chordSize = 10
~mel.noteDecayFactor = 4/6; // anders als man denkt?
~mel.playMidiVoices.stop;
~mel.setScale(Scale.dorian)

~stealing.softLimit = 5;
~stealing.hardLimit = 6;
~stealing.strategyNow = \nearest;
~stealing.strategyNow = \oldest;
~stealing.strategyNow = \wrandom;

~mel.playMidi.play;
~mel.playMidi.stop

~mel.midichn = 0
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav";
b = Buffer.read(s, p);
b.play
~mel.startMel(0); // channel 4 wo alles nach bw geht (und 5
~mel.playMidiVoices.play;
{
	inf.do {
		~mel.midichn = 2.rand;
		0.25.wait;
	}
}.fork
~stealing.muteGroups[\a].size

{
	inf.do {
		~mel.quantVal = [1/16, 1/4, 1/3, 1/7].choose;
		(1 + 3.rand).wait;
	}
}.fork