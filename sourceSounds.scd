~sourceSounds = ();

~sourceSounds.conv2 = {
	~fieldsWithColors.fieldCoords.do { |f|
		var origField = f[2];
		var color = f[1];
		var center = f[3];
		var closestKP = f[4];
		// wo liegt die row vom center?

		var amp1 = center[0] / ~bm.rows;
		var amp2 = 1 - amp1;
		var kpAmp;
		kpAmp = if(~kpState.diff[closestKP].notNil){
			~kpState.diff[closestKP].lincurve(0,8,0,1,4)
		}{
			0//0.05
		};


		// [amp1, amp2].postln;
		if([\blue, \yellow].includes(color)){
			~snd[\playDusty2comb].(
				numPoints: origField[0].size,
				planeSize: origField[1][0] * origField[1][0],
				rowOffset: origField[2][1],
				amp1: amp1.lincurve(0, 1, 0, 1, 2) * kpAmp,
				amp2: amp2.lincurve(0, 1, 0, 1, 2) * kpAmp,
				out1: ~snd.convBusses[0], // random choices fuer links und rechts
				out2: ~snd.convBusses[1]
			);

		}{
			~snd[\playPinkStab2].(
				numPoints: origField[0].size,
				planeSize: origField[1][0] * origField[1][0],
				rowOffset: origField[2][1],
				amp1: amp1.lincurve(0, 1, 0, 1, 2) * kpAmp,
				amp2: amp2.lincurve(0, 1, 0, 1, 2) * kpAmp,
				out1: ~snd.convBusses[0], // random choices fuer links und rechts
				out2: ~snd.convBusses[1]
			);
			/*			~snd[\playDusty2].(
			numPoints: origField[0].size,
			planeSize: origField[1][0] * origField[1][0],
			rowOffset: origField[2][1],
			amp1: amp1.lincurve(0, 1, 0, 1, 2) * kpAmp,
			amp2: amp2.lincurve(0, 1, 0, 1, 2) * kpAmp,
			out1: ~snd.convBusses[0], // random choices fuer links und rechts
			out2: ~snd.convBusses[1]
			);*/

		}
	};
};

~sourceSounds.pink = {
	~fieldsWithColors.fieldCoords.do { |f|
		var origField = f[2];
		var color = f[1];
		var center = f[3];
		var closestKP = f[4];
		// wo liegt die row vom center?

		var amp1 = center[0] / ~bm.rows;
		var amp2 = 1 - amp1;
		var kpAmp;
		kpAmp = if(~kpState.diff[closestKP].notNil){
			~kpState.diff[closestKP].lincurve(0,8,0,1,4)
		}{
			0//0.05
		};

		~snd[\playPinkStab2].(
			numPoints: origField[0].size,
			planeSize: origField[1][0] * origField[1][0],
			rowOffset: origField[2][1],
			amp1: amp1.lincurve(0, 1, 0, 1, 2) * kpAmp,
			amp2: amp2.lincurve(0, 1, 0, 1, 2) * kpAmp,
			out1: ~snd.convBusses[0], // random choices fuer links und rechts
			out2: ~snd.convBusses[1]
		)

	};
};

~sourceSounds.el = {
	~fieldsWithColors.fieldCoords.do { |f|
		var origField = f[2];
		var color = f[1];
		var center = f[3];
		var closestKP = f[4];
		// wo liegt die row vom center?

		var amp1 = center[0] / ~bm.rows;
		var amp2 = 1 - amp1;
		var kpAmp;
		kpAmp = if(~kpState.diff[closestKP].notNil){
			~kpState.diff[closestKP].lincurve(0,8,0,1,4)
		}{
			0//0.05
		};

		~snd[\playDusty2comb].(
			numPoints: origField[0].size,
			planeSize: origField[1][0] * origField[1][0],
			rowOffset: origField[2][1],
			amp1: amp1.lincurve(0, 1, 0, 1, 1) * kpAmp,
			amp2: amp2.lincurve(0, 1, 0, 1, 1) * kpAmp,
			out1: ~snd.convBusses[0], // random choices fuer links und rechts
			out2: ~snd.convBusses[1]
		);

	};
};