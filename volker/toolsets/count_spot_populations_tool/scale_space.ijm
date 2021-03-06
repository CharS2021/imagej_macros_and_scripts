var _SSF = sqrt(2);
var _SIGMA_START = 0.8;
//var _SIGMA_START = 1.2;
// var _SIGMA_START = 4;
var _SIGMA_DELTA = 0.4;
var _SCALE_SPACE_PARTS_OF_WIDTH = 15;
var _MAXIMA_PROMINENCE = 200;
//var _MAXIMA_PROMINENCE = 100;


macro "Automatic scale spot detector Action Tool - C444D10D19D2cD69D72D82D97Db0Db3Db8Dc1C666D07D09D1eD1fD22D2bD2dD2fD31D32D42D4aD4cD60D6fD77D81D86D8dD90D9aD9bDa2Da6Da7DaeDb5Db6Db9Dc5DcdDceDd0Dd5Dd6Dd7DeaDeeDf2Df5Df6Df9DffC3bbD13D17D24D27D53D54C777D05D18D2eD39D3cD3dD76D8bD99Dd9DddDf4C466D63C777D08D12D1bD29D41D4eD52D5aD6bD75D87D88D89D91D92D93D94Da0Da1Da4Db2Db4DbeDc0Dc8Dc9DcfDd8De0De6Df0Df1DfcDfdC0ffD15D16D33D38D43D65DabDbaDbcDc3DcbDd2Dd4De3C8aaD34D46D47D56D58D67Dd3DdaDdcDfaC555D01D0eD0fD11D21D2aD3bD3fD40D51D5cD5fD62D71D7aD7bD7eD7fD80D8fD95D9fDadDc6Dd1DedDefDf3Df8DfbC1eeD14D23D28D64D66C888D06D68D6aD74D84DbdDdeDdfDebDecDfeC666D02D03D04D0aD0bD0cD1dD20D3aD3eD49D4bD4dD4fD5bD5dD5eD61D6eD70D79D7dD83D85D8cD8eD96D9dD9eDa3Da5Da8DafDb1DbfDe8De9C1eeD48D57DcaDccCbbbD25D26D35D36D37D44D45D55DbbDdbC555D00D0dD1aD1cD30D50D59D6cD6dD73D78D7cD8aD98D9cDa9Db7Dc7De1De5De7Df7C1eeDaaDacDc2Dc4De2De4"{

}

function detectSpots() {
	setBatchMode(true);
	Overlay.remove;
	run("Select None");
	imageID = getImageID();
	sigmas = createScaleSpace();
	scaleSpaceID = getImageID();
	findMaxima(sigmas, imageID, scaleSpaceID);
	// filterMaxima(imageID, scaleSpaceID);
	setBatchMode("exit and display");
	print("Done!");
}

function createScaleSpace() {
	width = getWidth();
	height = getHeight();
	max = round(width/_SCALE_SPACE_PARTS_OF_WIDTH);
	title = getTitle();
	run("Duplicate...", " ");
	rename("tmp");
	run("Duplicate...", " ");
	run("Images to Stack", "name=Scale-Space title=[tmp] use");
	run("Size...", "width="+width+" height="+height+" depth="+max+" constrain average interpolation=Bilinear");
	sigmas = newArray(nSlices);
	stackID = getImageID();
	run("32-bit");
	for(i=1; i<=nSlices; i++) {
		setSlice(i);
		run("Duplicate...", " ");
		sliceID = getImageID();
		sigma = _SIGMA_START + (i-1) * _SIGMA_DELTA;
		sigmas[i-1] = sigma;
		run("FeatureJ Laplacian", "compute smoothing="+sigma);
		laplacianID = getImageID();
		run("Multiply...", "value="+(sigma*sigma));
		run("Select All");
		run("Copy");
		selectImage(stackID);
		run("Paste");
		selectImage(sliceID);
		close();
		selectImage(laplacianID);
		close();
	}
	run("Select None");
	resetMinAndMax();
	return sigmas;
}

function findMaxima(sigmas, imageID, scaleSpaceID) {
	selectImage(scaleSpaceID);
	Stack.setSlice(1);
	run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
	getSelectionCoordinates(xpoints, ypoints);
	run("Select None");
	
	for (i = 0; i < xpoints.length; i++) {
		
		oldMin = 99999999;
		currentMin = 1111111;
		
		while(oldMin!=currentMin) {
	
			selectImage(scaleSpaceID);
			x = xpoints[i];
			y = ypoints[i];
			setSlice(1);
			makePoint(x, y);
			run("Plot Z-axis Profile");
			Plot.getValues(pxpoints, pypoints);
			close();
			ranks = Array.rankPositions(pypoints);
			minIndex = ranks[0]+1;
			currentMin = pypoints[minIndex-1];
			
			sigma = sigmas[minIndex-1];
			radius = sigma*_SSF;

			setSlice(minIndex);
			makeRectangle(x-radius, y-radius, 2*radius+1, 2*radius+1);
			Roi.getContainedPoints(rxpoints, rypoints);
			oldMin = currentMin;
			for(j=0; j<rxpoints.length; j++) {
				for(k=0; k<rypoints.length; k++) {
					v = getPixel(rxpoints[j], rypoints[k]);
					if (v<currentMin) {
						currentMin = v;
						xpoints[i] = rxpoints[j];
						ypoints[i] = rypoints[k];
					}			
				}
			}
			
		}
		run("Select None");
		selectImage(imageID);
		if (round(radius)%2==1) makeOval((x+0.5)-radius, (y+0.5)-radius, (2*radius), (2*radius));
		else makeOval((x+0.5)-radius, (y+0.5)-radius, (2*radius), (2*radius));
		Overlay.addSelection;
		run("Select None");
	}
	Overlay.show;
}

function filterMaxima(imageID, scaleSpaceID) {
	selectImage(imageID);
	Overlay.copy;
	selectImage(scaleSpaceID);
	setSlice(1);
	Overlay.paste;
	nrOfBlobs = Overlay.size;
	toBeRemoved = newArray(0);
	for (i = 0; i < nrOfBlobs; i++) {
		Overlay.activateSelection(i);
		getStatistics(area, mean, min, max, std);
		if (mean>-20) {
			toBeRemoved = Array.concat(toBeRemoved, i);
		}
	}
	roiManager("reset");
	run("To ROI Manager");
	roiManager("select", toBeRemoved);
	roiManager("Delete");

	run("From ROI Manager");
	
	Overlay.copy;
	selectImage(imageID);
	Overlay.remove;
	Overlay.paste;
	roiManager("reset");
}
