~metaFuncs = ();

~metaFuncs.changeQuantAndChordSize = {
	// idee: wenn ~kpState.diffSum hoch geht wird m.quantVal groeber
	// m.quantVal = 1 / 2.pow(~kpState.diffSum.lincurve(20,80,16,1,-1).asInteger);
	~mel.quantVal = (1 / 2.pow(~kpState.diffSum.lincurve(20,80,4,1, -2).asInteger)) * 2;
	//~mel.chordSize = ~kpState.diffSum.lincurve(20,100,1,8,-3).asInteger;

	// idee: anhand von colorDict entscheiden welches midi instrument gespielt wird
	//~fieldsWithColors
};

~metaFuncs.changeQuant2 = {
	~mel.quantVal = (1 / 2.pow(~kpState.diffSum.lincurve(20,80,1,5, -2).asInteger)) * 2;
};