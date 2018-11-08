var	_METHODS = newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "Otsu");
var _NAMES = newArray("one", "two");
var _LINE_X1 = 814;
var _LINE_Y1 = 22;
var _LINE_X2 = 298;
var _LINE_Y2 = 1244;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Heights_of_Surfaces_Tools";

macro "MRI Heights of Surfaces Tools (f5) Help Action Tool - Cf00D1bD1cD24D25D28D29D31D32D33D41D42D43D44D45D68D69D6aD76D77D83D84D85D91D92D93D94D95Da6Da7Da9DaaDb9Dc6Dc7Dd5Dd6De7DfaDfbCfffD00D01D02D03D04D05D06D07D08D09D0aD0dD0eD0fD10D11D12D13D14D15D16D17D1dD1eD1fD20D21D22D23D2aD2bD2cD2dD2eD2fD30D34D35D37D38D39D3aD3bD3cD3dD3eD3fD40D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D5dD5eD5fD60D61D62D63D64D65D66D67D6dD6eD6fD70D71D72D73D74D75D78D79D7aD7cD7dD7eD7fD80D81D82D86D87D88D8bD8cD8dD8eD8fD90D96D97D99D9aD9bD9cD9dD9eD9fDa0Da1Da2Da3Da4Da5DabDacDadDaeDafDb0Db1Db2Db3Db4Db5Db6Db7DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd7Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8DfcDfdDfeDffC00fD0bD0cD18D19D36D47D6bD6cD7bD89D8aD98Dc8Dd8Df9Cf0fD1aD26D27D46D57D58D59D5aD5bD5cDa8Db8De8De9"{
	help();
}

macro "help [f5]" {
	help();
}

function help() {
	run('URL...', 'url='+helpURL);
}

macro "create surface image [f6]" {
	createSurfaceImage(); 
}
macro 'Create Surface Image (f6) Action Tool - C000T4b12c' {
	createSurfaceImage();
}

macro "plot heights [f7]" {
	plotHeights(); 
}

macro 'Plot heights (f7) Action Tool - C000T4b12p' {
	plotHeights();
}

function createSurfaceImage() {
	method = _METHODS[6];
	titles = getList("image.titles");
	for (i = 0; i < titles.length; i++) {
		selectImage(titles[i]);
		rename("tmp");
		getVoxelSize(width, height, depth, unit);
		setAutoThreshold(method + " dark no-reset stack");
		run("Convert to Mask", "method="+method+" background=Dark black");
		zEncodeStack();															//	run("Macro...", "code=[v=(v/255) * (z+1)] stack");
		selectImage("tmp");
		run("Z Project...", "projection=[Max Intensity]");
		selectImage("tmp");
		close();
		run("Calibrate...", "function=[Straight Line] unit="+unit+" text1=[1 10] text2=["+depth+" "+10*depth+"]");
		rename(_NAMES[i]);
	}
	
	run("Merge Channels...", "c1=["+_NAMES[0]+"] c3=["+_NAMES[1]+"] create");
	setSlice(2);
	run("Enhance Contrast", "saturated=0.35");
	setSlice(1);
	run("Enhance Contrast", "saturated=0.35");
}

function plotHeights() {
	imageID = getImageID();
	run("Line Width...", "line=20");
	makeLine(_LINE_X1, _LINE_Y1, _LINE_X2, _LINE_Y2);
	dy = _LINE_Y2-_LINE_Y1;
	dx = _LINE_X2-_LINE_X1; 
	length=sqrt(dx*dx + dy*dy);
	setSlice(1);
	selectImage(imageID);
	blue = getProfile();
	setSlice(2);
	getStatistics(area, mean, min, max, std, histogram);
	red = getProfile();
	xValues = newArray(red.length);
	for (i = 0; i < xValues.length; i++) {
		xValues[i] = width*i;
	}
	Plot.create("Height of channels", "Distance ("+unit+")", "Height ("+unit+")");
	Plot.setColor("blue");
	Plot.add("line", xValues, blue);
	Plot.setColor("red");
	Plot.add("line", xValues, red);
	upperRange = max + (max/10.0);
	Plot.setLimits(0.0,length + (0.02 * length),0.00, upperRange);
	Plot.show();
}

function zEncodeStack() {
	run("Divide...", "value=255 stack");
	for(z=1; z<=nSlices ; z++) {
		setSlice(z);
		run("Multiply...", "value="+z+" slice");
	}
	setSlice(1);
}

function fractionOfRedAboveBlue(redID, blueID) {
	
}