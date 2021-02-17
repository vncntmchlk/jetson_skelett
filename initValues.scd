~origPixels = 224;
thisProcess.openUDPPort(9876);

~bm.initBitmap(56, 56, 3); // rows, cols, numDelays 56 56 3

~analysis = (
	kpDiffThresh: 15,
	squareTest: { |self, sq| (sq.sum > 8)}, // 12
	clusterBounds: 2
);

~draw = (
	skelett: true,
	diff: true,
	fields: true,
	keypoints: false
);

~ctl = (
	alphaInc: 0.1,
	alphaDec: 0.2,
	clusterDec: 40
);

~keypointColors = (
	nose: \green,
	left_eye: \green,
	right_eye: \green,
	left_ear: \green,
	right_ear: \green,
	left_shoulder: \yellow,
	right_shoulder: \blue,
	left_elbow: \yellow,
	right_elbow: \blue,
	left_wrist: \yellow,
	right_wrist: \blue,
	left_hip: \cyan,
	right_hip: \magenta,
	left_knee: \cyan,
	right_knee: \magenta,
	left_ankle: \cyan,
	right_ankle: \magenta,
	neck: \green
);

/* noch ohne verwendung
~keypoints = ["nose", "left_eye", "right_eye", "left_ear", "right_ear", "left_shoulder", "right_shoulder", "left_elbow", "right_elbow", "left_wrist", "right_wrist", "left_hip", "right_hip", "left_knee", "right_knee", "left_ankle", "right_ankle", "neck"];

~skeletonConnections = (
	[[16, 14], [14, 12], [17, 15], [15, 13], [12, 13], [6, 8], [7, 9], [8, 10], [9, 11], [2, 3], [1, 2], [1, 3], [2, 4], [3, 5], [4, 6], [5, 7], [18, 1], [18, 6], [18, 7], [18, 12], [18, 13]] - 1
);
*/
