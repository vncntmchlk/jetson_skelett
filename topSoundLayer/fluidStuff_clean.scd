(
~mel = (
	quantVal: 1/8,
	hiFr: 900, //2100,
	lowFr: 70,
	numBands: 90,
	fftSize: 2.pow(13),
	doubleFrameRate: (2.pow(13) / s.sampleRate) * 2,
	chordSize: 0,
	noteDecayFactor: 0.75,
	midichn: 0,
	newValues: false,
	scale: Scale.dorian(),
	calcMB: { |self|
		var vals = [self.lowFr, self.hiFr].collect(1127 * log(1 + (_ / 700))),
		incr = (vals[1] - vals[0]) / (self.numBands + 1),
		steps =  (vals[0], (vals[0] + incr) .. vals[1]),
		newVals = steps.collect((exp(_ / 1127) - 1) * 700);
		self.melFreqs = newVals[1..self.numBands]
	},
	setScale: { |self, sc|
		self.melMidi = self.melFreqs.collect{|i| i.cpsmidi.nearestInScale(sc)};
		self.scale = sc;
	},
	startMel: { |self, inbus = 0|
		self.calcMB;
		self.melMidi = self.melFreqs.collect{|i| i.cpsmidi.nearestInScale(self.scale)};
		self.notePlaying = false ! 128;
		self.noteFired = false ! 128;
		self.activeNotes = ();
		self.melSynth !? {self[\melSynth].free};
		self.playMidi !? {self.playMidi.free};
		self.melSynth = { |thresh = 0.15|
			var source = In.ar(inbus, 2).sum;
			var mb = FluidMelBands.kr(
				source,
				self.numBands,
				self.lowFr,
				self.hiFr,
				self.numBands,
				1, self.fftSize,
				self.fftSize / 4,
				self.fftSize,
				self.fftSize
			);
			var diff = mb - Delay1.kr(mb);
			var diffSum = diff.sum;
			//var sendArr = Select.kr(which, [mb, diff.clip(0,100)]);
			// beide versionen haben was, vielleicht ein Select um auszusuch
			SendReply.kr((diffSum.abs > thresh) * Changed.kr(diffSum), '/reply', mb); //diff.clip(0,100)
			// SendReply.kr((diffSum.abs > thresh) * Changed.kr(diffSum), '/reply', mb);
		}.play(target: ~snd.lastGroup);
		OSCdef(\re, {|msg|
			var ampsExcludeLowestFreq = msg[3..(self.numBands + 2)],
			selectedIndices = ampsExcludeLowestFreq.order.reverse[..self.chordSize];
			selectedIndices.do { |ix|
				var note = self.melMidi[ix].asInteger;
				if(self.activeNotes[note].isNil){
					self.activeNotes[note] = [ampsExcludeLowestFreq[ix], self.midichn, note];
				}{
					self.activeNotes[note][0] = self.activeNotes[note][0] + ampsExcludeLowestFreq[ix]
				}
			};
		}, '/reply');
	},
	chanSequence: Pseq([0,0,0,0,1],inf).asStream,
	playMidiVoices: { |self|
		Task {
			inf.do {
				var notesNow = ~stealing.muteGroups.collect {|ev| ev.midinote}[\a];
				// hier koennten auch andere selected werden, beispielsweise die aufwaerts gehenden
				var selected = if(notesNow.isNil){
					self.activeNotes
				}{
					self.activeNotes.reject{|ev, key| notesNow.includes(key)}
				};
				// notesNow.postln;
				if(selected.isEmpty.not){
					// nur die strongest note nehmen
					var winner = selected.maxItem({ |ev| ev[0]});
					var note = winner[2];
					var amp = winner[0].lincurve(0,0.05,0,1,-2);
					{
						self.midichn = self.chanSequence.next;
						~stealing[\mainstream].next(
							(
								freq: note.asInteger.midicps,
								chan: self.midichn,
								amp: amp
							)
						).play; // next event
					}.defer(l.timeToNextBeat.mod(self.quantVal))
				};
				self.activeNotes.keysValuesDo { |note|
					self.activeNotes[note][0] = (self.activeNotes[note][0] * self.noteDecayFactor);
					if(self.activeNotes[note][0] < 0.0025){ // das ist quasi decay time fuer die noten
						self.activeNotes[note] = nil
					}
				};
				// self.activeNotes.clear;
				//(self.doubleFrameRate).wait;
				(1/16).wait;
			}
		}//.play(l)
	},
	playMidi: { |self|
		Task {
			inf.do {
				// alle der skala zuweisen
				if(self.activeNotes.isEmpty.not){
					// self.activeNotes.postln;
					self.activeNotes.keysValuesDo { |note, ampAndChan|
						if(self.notePlaying[note] && self.noteFired[note]){
							self.activeNotes[note][0] = (self.activeNotes[note][0] * 0.75);
							if(self.activeNotes[note][0] < 0.0025){
								self.notePlaying[note] = false;
								self.noteFired[note] = false;
								~mOut.noteOff(self.activeNotes[note][1], note, 0);
								self.activeNotes[note] = nil
							}
						}{
							self.notePlaying[note] = true;
							{
								if(self.noteFired[note].not){
									self.noteFired[note] = true;
									self.activeNotes[note][1] = self.midichn;
									~mOut.noteOn(self.midichn, note, ampAndChan[0].lincurve(0,0.05,0,127,-2));
								}
							}.defer(l.timeToNextBeat.mod(self.quantVal))
						}
					};
				};
				(1/16).wait;
			}
		}//.play(l)
	}
);
)
