~kpState = (
	last: (),
	now: (),
	diff: (),
	diffSum: 0,
	copyClear: { |self|
		self.last = self.now.copy;
		self.now.clear;
		self.diff.clear;
	},
	calcDiff: { |self|
		(self.last.keys & self.now.keys).do { |k|
			var calcDiff = self.now[k].asPoint.dist(self.last[k]);
			self.diff[k] = if(calcDiff > ~analysis.kpDiffThresh){1}{calcDiff};
		};
		self.diffSum = self.diff.values.sum;
	}
);

~fieldsWithColors = (
	allColors: Set[\blue, \green, \yellow, \magenta, \cyan],
	colorWheel: Pseq([\blue, \green, \yellow, \magenta, \cyan],inf).asStream,
	appearingColors: Set.new,
	fieldCoords: List.new,
	colorDict: (
		blue: (clusterSize: 0, alpha: 0),
		green: (clusterSize: 0, alpha: 0),
		yellow: (clusterSize: 0, alpha: 0),
		magenta: (clusterSize: 0, alpha: 0),
		cyan: (clusterSize: 0, alpha: 0)
	),
	closestKeypointColor: { |self, point|
		point = point * ~bm.rescaleFactor; // scale back
		~kpTree.nearest(point)[0].label
	},
	compareSimple: { |self, fields|
		self.appearingColors.clear;
		self.fieldCoords.clear;
		//self.centerPoints.clear;
		fields.do { |field|
			var myCluster = field[0];
			var squareXY = field[1];
			var squareOffset = field[2];
			if(~analysis.squareTest(squareXY)){
				var myCenter = squareOffset + (squareXY * 0.5);
				var myClosestPoint = self.closestKeypointColor(myCenter);
				var myColor = ~keypointColors[myClosestPoint];
				self.colorDict[myColor].clusterSize = self.colorDict[myColor].clusterSize + myCluster.size;
				self.colorDict[myColor].alpha = (self.colorDict[myColor].alpha + ~ctl.alphaInc).clip2(1);
				self.appearingColors.add(myColor);
				self.fieldCoords.add([
					self.makeFieldCoords(squareXY, squareOffset),
					myColor,
					field, // nicht die eleganteste loesung hier alles zu kopieren aber die simpelste
					myCenter,
					myClosestPoint
				]);
			}
		};
		//decrement all colors that didnt appear
		(self.allColors - self.appearingColors).do { |colNow|
			self.colorDict[colNow].clusterSize = (self.colorDict[colNow].clusterSize - ~ctl.clusterDec).clip(0, inf);
			self.colorDict[colNow].alpha = (self.colorDict[colNow].alpha - ~ctl.alphaDec).clip(0, 1);
		};
	},
	makeFieldCoords: { |self, maxPoints, offset|
		var coords = List.new;
		//from upperLeft to upperRight
		(0 .. (maxPoints[1] - 1)).do { |ix|
			coords.add([0 + offset[0], (ix + offset[1])]);
		};
		//from lowerLeft to lowerRight
		(0 .. (maxPoints[1] - 1)).do { |ix|
			coords.add([(maxPoints[0] + offset[0]), (ix + offset[1])]);
		};
		//from upperLeft to lowerLeft
		(0 .. (maxPoints[0] - 1)).do { |ix|
			coords.add([(ix + offset[0]), 0 + offset[1]]);
		};
		//from upperRight to lowerRight
		(0 .. (maxPoints[0] - 1)).do { |ix|
			coords.add([(ix + offset[0]), (maxPoints[1] + offset[1])]);
		};
		coords
	}
);

~fieldsFromClusters = (
	getMinMax: {|self, p|
		var allX = p.flop[0];
		var allY = p.flop[1];
		var minX = allX.minItem;
		var maxX = allX.maxItem;
		var minY = allY.minItem;
		var maxY = allY.maxItem;
		[[minX, minY], [maxX, maxY]]
	},
	padTo: {|self, input, target = 4|
		(target - (input % target)) % target
	},
	getFieldsFromClusters: { |self, clusters|
		var padding = [2, 2];
		self.minMax = clusters.collect{|cl| self.getMinMax(cl)};
		self.offsets = self.minMax.collect {|minMax| minMax[0]};
		self.clusters = clusters.collect{|cl ix|
			cl -.t (self.offsets[ix] - padding + 1)
		}; // zusaetzlich + 1 damit die punkte richtig ins array eingefuegt werden (index startet bei 0)..
		self.lowerRight = self.minMax.collect {|minMax ix|
			self.newField(minMax[0], minMax[1], self.offsets[ix], padding)[3]
		};
		[self.clusters, self.lowerRight, self.offsets].flop
	},
	newField: {|self, minP, maxP, offset, padding|
		var upperLeft = minP - offset;
		var upperRight = [minP[0], maxP[1]] - offset + [0, padding[1]];
		var lowerLeft = [maxP[0], minP[1]] - offset + [padding[0], 0];
		var lowerRight = maxP - offset + padding;
		upperRight = upperRight + [0, self.padTo(upperRight[1])];
		lowerLeft = lowerLeft + [self.padTo(lowerLeft[0]), 0];
		lowerRight = lowerRight + self.padTo(lowerRight);
		[upperLeft,upperRight,lowerLeft,lowerRight]
	},
);


~bm = (
	initBitmap: {|self, rows, cols, numDelays = 8|
		self.counter = Pseries().asStream;
		self.rescaleFactor = ~origPixels / rows;
		self.scaleBackFactor = rows / ~origPixels;
		self.rows = rows;
		self.cols = cols;
		self.coords = Set[];
		self.delays = self.coords ! numDelays;
		self.numDelays = numDelays;
	},
	testLine: { |self, x0, y0, x1, y1|
		var dx = abs(x1 - x0), sx = if(x0 < x1){1}{-1};
		var dy = abs(y1 - y0), sy = if(y0 < y1){1}{-1};
		var err = (if(dx>dy){dx}{-1 * dy})/2;
		var loop = true;
		while ({loop}, {
			var e2;
			self.coords.add([x0, y0]);
			if (x0 == x1 && y0 ===y1) {loop = false};
			e2 = err;
			if (e2 > (-1 * dx)) { err = err - dy; x0 = x0 + sx; };
			if (e2 < dy) { err = err + dx; y0 = y0 + sy; }
		})
	},
	evalLines: { |self, linePoints|
		var rescale = (linePoints / self.rescaleFactor).collect(_.asInteger); // von 224 auf 32 * 32
		(self.numDelays - 1 .. 1).do { |ix|
			self.delays[ix] = self.delays[ix - 1].copy
		};
		self.delays[0] = self.coords.copy;
		self.coords.clear;

		(linePoints.size / 4).do { |ix|
			var i = ix * 4;
			self.testLine(rescale[i], rescale[i + 1], rescale[i + 2], rescale[i + 3])
		};
		self.diffCoords = self.coords - self.delays.reduce(_ | _);
	},
	getClusters: { |self, bounds = 1|
		var coords = self.diffCoords.asArray;
		var restShapes = List.new;
		if(coords.isEmpty.not){
			var tree;
			var graph = Dictionary.new;
			tree = KDTree.new(coords);
			tree.do({|node|
				var loc = node.location;
				var neighbours = tree.rectSearch(loc - bounds, loc + bounds).collect(_.location);
				graph[loc] = neighbours
			});
			block {|break|
				inf.do {
					if(graph.keys.isEmpty){
						break.value(restShapes)
					}{
						restShapes.add(self.newShape(graph))
					};
				};
			};
		};
		restShapes
	},
	dfs: { |self, graph, node, visited|
		if(visited.includes(node).not){
			visited.add(node);
			graph[node].do { |n|
				self.dfs(graph, n, visited)
			}
		};
		visited
	},
	newShape: { |self, graph|
		var newShape = self.dfs(graph,graph.keys.asArray[0], List.new);
		newShape.do {|rem| graph.removeAt(rem) };
		newShape
	}
);

~newGui = {
	var width= 512, height= 512;
	var cellWidth;
	var cellHeight;
	var newWin = Window("aa", Rect(0, 0, width, height));

	cellWidth = width / ~bm.rows;
	cellHeight = height / ~bm.cols;

	newWin.drawFunc = {
		if(~draw.skelett){
			Pen.fillColor = Color.red(1, 0.5);
			~bm.coords.do { |co|
				Pen.addRect(
					Rect(width - (co[0] * cellWidth), (co[1] * cellHeight), cellWidth, cellHeight)
				);
			};
			Pen.fill;
		};
		if(~draw.diff){
			Pen.fillColor = Color.blue(1, 0.5);
			~bm.diffCoords.do { |co|
				Pen.addRect(
					Rect(width - (co[0] * cellWidth), (co[1] * cellHeight), cellWidth, cellHeight)
				);
			};
			Pen.fill;
		};
		if(~draw.fields){
			~fieldsWithColors.fieldCoords.do { |coords|
				coords[0].do{|co|
					var color = coords[1];
					var alphaOfColor = ~fieldsWithColors.colorDict[color].alpha;
					Pen.fillColor = Color.perform(color).alpha_(alphaOfColor);
					Pen.addRect(
						Rect(
							(width - (co[0] * cellWidth)) % width,
							(co[1] * cellHeight) % height,
							cellWidth,
							cellHeight
						)
					);
					Pen.fill;
				};
			};
		};
		if(~draw.keypoints){
			~kp.do { |arr| // ans neue KP anpassen!!!
				var x = arr[0] * ~bm.scaleBackFactor;
				var y = arr[1] * ~bm.scaleBackFactor;
				var kpSize = ~kpState.diff[arr[2]] ? 1;
				Pen.fillColor = Color.perform(~keypointColors[arr[2]]);
				Pen.addRect(
					Rect(
						(width - (x * cellWidth)) % width,
						(y * cellHeight) % height,
						cellWidth * kpSize,
						cellHeight * kpSize
					)
				);
				Pen.fill;
			};
		};
	};
	newWin.front;
	newWin
};