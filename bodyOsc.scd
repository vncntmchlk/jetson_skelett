OSCdef(\keyPoints, { |msg|
	var keypoints;
	~kpState.copyClear;
	keypoints = (0 .. ((msg.size - 2) / 3)).collect {|ix|
		ix = ix * 3;
		~kpState.now[msg[1 + ix]] = [msg[2 + ix], msg[3 + ix]];
		[msg[2 + ix], msg[3 + ix], msg[1 + ix]]
	};
	~kpState.calcDiff;
	~kp = keypoints;
	// muss deepCopy weil der kdtree die labels entfernt
	~kpTree = KDTree(keypoints.deepCopy, lastIsLabel: true);
}, '/kp').permanent_(true);

OSCdef(\body, { |msg|
	var dt = msg[1..];
	var clusters;
	var fields = List.new;
	// "new".postln;
	~bm.evalLines(dt);
	clusters = ~bm.getClusters(~analysis.clusterBounds); //bounds, thresh
	fields = ~fieldsFromClusters.getFieldsFromClusters(clusters);
	if(~kp.notNil){
		~fieldsWithColors.compareSimple(fields);
		~sourceSounds[\conv2].();
		//~metaFuncs[\changeQuantAndChordSize].();
	};

	// die utopia werte aktualisieren


	//{w.refresh}.defer;


}, '/body').permanent_(true);