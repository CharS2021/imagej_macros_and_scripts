/*
 *	Heights of surfaces tools 
 *	
 *	The tool compares the height in the z-dimension of the signals in two different channels (red and blue). It calculates the fraction of the volume of the
 *	red signal that lies above the blue signal and the fraction of the red signal that lies below the blue signal. Only places where both signals are present 
 *	(heights of red and blue bigger than zero) are taken into account.
 *	
 * (c) 2020, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
 */
var	_METHODS = getList("threshold.methods");
var _METHOD = _METHODS[0];
var _EXTENSION = ".czi";
var _REMOVE_BACKGROUND = true;
var _REFERENCE_CHANNEL = 4;
var _CHANNELS_TO_PLOT = newArray(0);
var _CHANNEL_SELECTION = newArray(true, true, true, true, true, true, true, true, true, true, true, true);
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Heights_of_Surfaces_Tools";

// FOR DEBUGGING
//createSurfaceImage();
//plotHeights();
//calculateVolumes();

macro "MRI Heights of Surfaces Tools (f5) Help Action Tool - Cf00D1bD1cD24D25D28D29D31D32D33D41D42D43D44D45D68D69D6aD76D77D83D84D85D91D92D93D94D95Da6Da7Da9DaaDb9Dc6Dc7Dd5Dd6De7DfaDfbCfffD00D01D02D03D04D05D06D07D08D09D0aD0dD0eD0fD10D11D12D13D14D15D16D17D1dD1eD1fD20D21D22D23D2aD2bD2cD2dD2eD2fD30D34D35D37D38D39D3aD3bD3cD3dD3eD3fD40D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D5dD5eD5fD60D61D62D63D64D65D66D67D6dD6eD6fD70D71D72D73D74D75D78D79D7aD7cD7dD7eD7fD80D81D82D86D87D88D8bD8cD8dD8eD8fD90D96D97D99D9aD9bD9cD9dD9eD9fDa0Da1Da2Da3Da4Da5DabDacDadDaeDafDb0Db1Db2Db3Db4Db5Db6Db7DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd7Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8DfcDfdDfeDffC00fD0bD0cD18D19D36D47D6bD6cD7bD89D8aD98Dc8Dd8Df9Cf0fD1aD26D27D46D57D58D59D5aD5bD5cDa8Db8De8De9"{
	help();
}

macro "help [f5]" {
	help();
}

function help() {
	run('URL...', 'url='+helpURL);
}

macro "correct background [f6]" {
	correctBackgrounds(); 
}

macro 'Correct Background (f6) Action Tool - C000T4b12b' {
	correctBackgrounds();
}

macro "create surface image [f7]" {
	createSurfaceImage(); 
}
macro 'Create Surface Image (f7) Action Tool - C000T4b12c' {
	createSurfaceImage();
}

macro 'Create Surface Image (f7) Action Tool Options' {
	createSurfaceOptions();
}
macro "plot heights [f8]" {
	plotHeights(); 
}

macro 'Plot heights (f8) Action Tool - C000T4b12p' {
	plotHeights();
}

macro 'Plot heights (f8) Action Tool Options' {
	createPlotOptions();
}

macro 'Measure Heights (f9) Action Tool - C000T4b12h' {
	calculateHeights();
}

macro 'measure heights [f9]' {
	calculateHeights();
}

macro 'Batch process (f11) Action Tool - C444D22D2cD52D5cD68D85D9dDe8Df6C000D29D41D67D8fDd4DebCcccD32D33D39D3cD57D65D69D6bD8aDa9Db8Dc7Dd7De7CbbbD26D7cD80D8bD8cD8eD92D95D99D9bD9cDa8DaaDabDb9DbaDbbDc4Dc9DcaDccDd6C222D31D3dD90D9eDc1Dd9DdaCeeeD17D36D37D38D45D46D48D49D4aD55D56D58D59D63D64D73D82D83Da4Da5Db3Db4Dc2Dc3C888D16D28D34D3aD42D4cD62D6cD70D79D7dDa7Db2Dd2Dd8DdbDdcDe6C111D06D98Df8CeeeD44D4bD53D54D5aD72D81Db5Db6CcccD35D71D7bD8dD9aDa6Dc8DcbC333D07D23D2bD66D91DbcDd5CfffD27D47D74D84D93D94Da3C555D18D75D7eD89Da2DacDd3Df7C111D08D25D61D96DcdCdddD3bD43D5bD6aD7aDb7Dc5Dc6' {
	runBatchProcessing();
}

macro 'Batch process folders [f11]' {
	runBatchProcessing();
}

macro 'Batch process (f11) Action Tool Options' {
	 Dialog.create("Create Surface Batch Image Options");
	 Dialog.addString("File extension: ", _EXTENSION);
	 Dialog.addCheckbox("Remove background: ", _REMOVE_BACKGROUND)
 	 Dialog.show();
 	 _EXTENSION = Dialog.getString();
 	 _REMOVE_BACKGROUND = Dialog.getCheckbox();
}

function createSurfaceOptions() {
	 Dialog.create("Create Surface Image Options");
	 Dialog.addChoice("Auto-threshold method: "_METHODS, _METHOD)
	 Dialog.addNumber("Reference channel ", _REFERENCE_CHANNEL);
 	 Dialog.show();
 	 _METHOD = Dialog.getChoice();
 	 _REFERENCE_CHANNEL = Dialog.getNumber();
}

function createPlotOptions() {
	if (nImages==0) return;
	Stack.getDimensions(width, height, channels, slices, frames);
	Dialog.create("Create Plot Options");
	Dialog.addMessage("Plot Channel:");
	for (i = 1; i <= channels; i++) {	
		Dialog.addCheckbox(i+". channel", _CHANNEL_SELECTION[i-1]);
	}
	Dialog.show();
	for (i = 1; i <= channels; i++) {	
		_CHANNEL_SELECTION[i-1] = Dialog.getCheckbox();
	}
}

function createSurfaceImage() {
	getDimensions(width, height, channels, slices, frames);
	setBatchMode(true);
	imageTitle = getTitle();
	rename("image");
	method = _METHOD;
	imageID = getImageID();
	run("Split Channels");
	getVoxelSize(width, height, depth, unit);
	for (i = 1; i <= channels; i++) {
		wait(500);
		selectImage("C"+i+"-image");
		getLut(reds, greens, blues);
		currentID = getImageID();
		setAutoThreshold(method+" dark stack");
		run("Convert to Mask", "method="+method+" background=Dark black");
		zEncodeStack(); // 						run("Macro...", "code=[v=(v/255) * (z+1)] stack"); 	
		selectImage(currentID);	
		run("Z Project...", "projection=[Max Intensity]");
		projectionID = getImageID();
		selectImage(currentID);
		close();
		selectImage(projectionID);		
		setLut(reds, greens, blues);
		run("Calibrate...", "function=[Straight Line] unit="+unit+" text1=[1 10] text2=["+depth+" "+10*depth+"]");
	}
	mergeString = "";
	for (i = 1; i <= channels; i++) {
		mergeString += "c"+i+"=[MAX_C"+i+"-image] ";
	}
	mergeString += "create";
	run("Merge Channels...", mergeString);
	for (i = 1; i <= channels; i++) {
		setSlice(i);
		run("Enhance Contrast", "saturated=0.35");	
	}
	setBatchMode(false);
	rename(imageTitle + "-surface");
	setMetadata("original_nr_of_slices", toString(slices));
}

function plotHeights() {
	imageWidth = getWidth();
	imageHeight = getHeight();
	imageID = getImageID();

	Stack.getDimensions(iwidth, iheight, channels, slices, frames)
	getVoxelSize(width, height, depth, unit);
	_CHANNELS_TO_PLOT = newArray();
	for (i = 1; i <= channels; i++) {	
		if (_CHANNEL_SELECTION[i-1]) _CHANNELS_TO_PLOT = Array.concat(_CHANNELS_TO_PLOT, i);
	}
	type = selectionType();
	if (type!=5) makeLine(imageWidth, 0, 0, imageHeight);
	getLine(x1, y1, x2, y2, lineWidth);
	if (lineWidth==1) run("Line Width...", "line=20");
	dy = y2-y1;
	dx = x2-x1; 
	length=sqrt(dx*dx + dy*dy)*width;
	setSlice(_REFERENCE_CHANNEL);
	getStatistics(area, mean, min, max, std, histogram);

	Plot.create("Height of channels", "Distance ("+unit+")", "Height ("+unit+")");
	setSlice(_CHANNELS_TO_PLOT[0]);
	profile = getProfile();
	xValues = newArray(profile.length);
	for (i = 0; i < xValues.length; i++) {
		xValues[i] = width*i;
	}
	for (i = 0; i < _CHANNELS_TO_PLOT.length; i++) {
		setSlice(_CHANNELS_TO_PLOT[i]);
		getLut(reds, greens, blues);
		color = nameOfColor(reds, greens, blues);
		profile = getProfile();
		
		Plot.setColor(color);
		Plot.add("line", xValues, profile);
		upperRange = max + (max/10.0);
		Plot.setLimits(0.0,length + (0.02 * length),0.00, upperRange);
	}
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

function calculateHeights() {
	inputImageID = getImageID();
	imageName = getTitle();
	Overlay.remove;
	roiManager("reset");
	run("Select None");
	Stack.setChannel(_REFERENCE_CHANNEL);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	cmax = calibrate(max);
	print("max. height is " + cmax + " determined using channel " + _REFERENCE_CHANNEL);
	run("Duplicate...", " ");
	run("Macro...", "code=[v=(v=="+max+") * 255]");
	referenceMaskID = getImageID();
	referenceMaskTitle = getTitle();
	selectImage(inputImageID);
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(width, height, depth, unit);
	xValues = newArray(256);
	for (j = 0; j < histogram.length; j++) {
		xValues[j] = (j * depth) / cmax;
	}
	title = "histograms";
	if (!isOpen(title)) {
		Table.create(title);
	}
	Table.setColumn("rel. height max="+cmax+" "+unit + " - " + imageName, xValues, "histograms");
	for (i = 1; i <= channels; i++) {
		if (i==_REFERENCE_CHANNEL) continue;
		roiManager("reset");
		run("Select None");
		Stack.setChannel(i);
		run("Duplicate...", " ");
		run("Macro...", "code=[v=(v>0) * 255]");
		maskID = getImageID();
		maskTitle = getTitle();
		imageCalculator("AND create", referenceMaskTitle, maskTitle);
		setThreshold(1, 255);
		run("Create Selection");
		roiManager("Add");
		close();
		close();
		selectImage(inputImageID);
		roiManager("select", 0);

		imageName = getTitle();
		getStatistics(area, mean, min, max, std, histogram);
		Table.setColumn(imageName + "_" + i, histogram, "histograms");

		run("From ROI Manager");
		roiManager("select", 0);
		run("Measure");

		stats = computeStats(histogram, xValues, true);
		Table.set("mean", nResults-1, stats[0], "Results");
		Table.set("stdDev", nResults-1, stats[1], "Results");
		Table.set("mode", nResults-1, stats[2], "Results");
		Table.set("min (q0)", nResults-1, stats[3], "Results");
		Table.set("q1", nResults-1, stats[4], "Results");
		Table.set("median (q2)", nResults-1, stats[5], "Results");
		Table.set("q3", nResults-1, stats[6], "Results");
		Table.set("max (q4)", nResults-1, stats[7], "Results");
	}
	selectImage(referenceMaskID);
	close();	
	roiManager("reset");
	unpackHistograms();
}

// Return an array with mean, stdDev, mode, min (q0), q1, median (q2), q3, and max.
function computeStats(hist, xValues, withoutZero) {
	histogram = Array.copy(hist);
	if (withoutZero) histogram[0] = 0;
	lastIndex = 255;
	for (i = 255; i > 0; i--) {
		lastIndex = i;
		if(histogram[i]>0) break;
	}
	firstIndex = 0;
	for (i = 0; i <=lastIndex; i++) {
		firstIndex = i;
		if(histogram[i]>0) break;
	}
	sum = 0;
	sum2 = 0;
	longPixelCount = 0;
	maxCount = -1;
	mode = 0;
	for (i = firstIndex; i <= lastIndex; i++) {
		count = histogram[i];
		longPixelCount += count;
		value = xValues[i];
		sum += value*count;
		sum2 += (value*value)*count;
		if (count>maxCount) {
			maxCount = count;
			mode = xValues[i];
		}
	}
	mean = sum / longPixelCount;
	stdDev = 0;
	if (longPixelCount>0) {
		stdDev = ((longPixelCount*sum2) - (sum*sum)) / longPixelCount;
		if (stdDev>0) {
			stdDev = sqrt(stdDev / (longPixelCount-1));
		}
		else {
			stdDev = 0;
		}
	} else {
		stdDev =0;
	}
	
	oneFourth = longPixelCount / 4;
	threeFourth =  oneFourth * 3;
	median = longPixelCount / 2;

	qZeroIndex = firstIndex;
	qOneIndex = 0;
	medianIndex = 0;
	qThreeIndex = 0;
	doneQ1 = false;
	doneMedian = false;
	doneQ3 = false;
	qFourIndex = lastIndex;
	runningSum = 0;
	for (i = firstIndex; i <= lastIndex; i++) {
		runningSum += histogram[i];
		if (runningSum>=oneFourth && !doneQ1) {
			qOneIndex = i-1;
			if (i==firstIndex) qOneIndex = i;
			if (qOneIndex<0) qOneIndex = 0;
			doneQ1 = true;
		}
		if (runningSum>=median && !doneMedian) {
			medianIndex = i-1;
			if (i==firstIndex) medianIndex = i;
			if (medianIndex<0) medianIndex = 0;
			doneMedian = true;
		}
		if (runningSum>=threeFourth && !doneQ3) {
			qThreeIndex = i-1;
			if (i==firstIndex) qThreeIndex = i;
			if (qThreeIndex<0) qThreeIndex = 0;
			doneQ3 = true;
		}
	}

	result = newArray(mean, stdDev, mode, xValues[qZeroIndex], xValues[qOneIndex], xValues[medianIndex], xValues[qThreeIndex], xValues[qFourIndex]);
	return result;
}

function correctBackgrounds() {
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= channels; i++) {
		correctBackground(i);
	}
	return;
}

function correctBackground(channel) {
	imageID = getImageID();
	Stack.setChannel(channel);
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	run("Maximum...", "radius=20 stack");
	run("Z Project...", "projection=[Sum Slices]");
	setAutoThreshold("Triangle dark no-reset");
	run("Create Selection");
	run("Fill", "stack");
	run("Select None");
	setAutoThreshold("Default dark no-reset");
	run("Create Selection");
	run("Make Inverse");
	close();
	close();
	run("Restore Selection");
	run("Plot Z-axis Profile");
	Plot.getValues(xpoints, ypoints);
	close();
	selectImage(imageID);
	run("Select None");
	Fit.doFit("3rd Degree Polynomial", xpoints, ypoints);
	for (i = 0; i < xpoints.length; i++) {
		Stack.setSlice(i+1);
		y = Fit.f(xpoints[i]);
		run("Subtract...", "value="+y+" slice");
	}
	Stack.setSlice(1);
}

function runBatchProcessing() {
	input = getDirectory("Choose the input folder!");
	output = getDirectory("Choose the output folder!");	
	run("Clear Results");
	t = getTime();
	ts = d2s(t, 0);
	processFolder(input, output, ts);
	selectWindow("Results");
	saveAs("results", output + "heights_of_surfaces-"+ts+".xls");
	selectWindow("histograms");
	saveAs("results", output + "histograms_of_heights-"+ts+".xls");
	selectWindow("raw data");
	saveAs("results", output + "raw_data_of_heights-"+ts+".xls");
}

function processFolder(input, output, ts) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output, ts);
		if(endsWith(list[i], _EXTENSION))
			processFile(input, output, list[i], ts);
	}
}

function processFile(input, output, file, ts) {
	print("Processing: " + input + File.separator + file);
	run("Bio-Formats Importer", "open=["+input + file +"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	if (_REMOVE_BACKGROUND) correctBackgrounds();
	createSurfaceImage();
	image = getImageID();
	plotHeights();
	Plot.makeHighResolution("Height of channels_HiRes",4.0);
	save(output + file +"-plot"+ts+".tif");
	close();
	close();
	run("Select None");
	calculateHeights();
	print("Saving to: " + output + File.nameWithoutExtension + ts + ".tif");
	selectImage(image);
	Overlay.show;
	saveAs("tiff", output + File.nameWithoutExtension + ts + ".tif");
	Overlay.hide;
	wait(500);
	run("Capture Image");
	save(output + File.nameWithoutExtension + ts + ".png");
	close();
	close();
}

function nameOfColor(red, green, blue) {
	Array.getStatistics(red, min, max);
	redIsZero = (max==0);
	Array.getStatistics(green, min, max);
	greenIsZero = (max==0);
	Array.getStatistics(blue, min, max);
	blueIsZero = (max==0);
	
	name = "Grays";
	if (!redIsZero && !greenIsZero && blueIsZero) name = "yellow";
	if (!redIsZero && greenIsZero && !blueIsZero) name = "magenta";
	if (redIsZero && !greenIsZero && !blueIsZero) name = "cyan";
	if (!redIsZero && greenIsZero && blueIsZero) name = "red";
	if (redIsZero && !greenIsZero && blueIsZero) name = "green";
	if (redIsZero && greenIsZero && !blueIsZero) name = "blue";
	return name;
}

function unpackHistograms() {
	selectWindow("histograms");

	headings = Table.headings("histograms");
	headings = split(headings, "\t");
	countHeadingsStrings = "";
	countHeadings = newArray(0);
	
	for (i = 0; i < headings.length; i++) {
		heading = headings[i];	
		if(!startsWith(heading, "rel. height")) {
			countHeadings = Array.concat(countHeadings, heading);
			countHeadingsStrings += heading;
			if (i<headings.length-1) countHeadingsStrings += "\t";
		}
	}
	
	Table.create("raw data");
	
	selectWindow("histograms");
	numberOfLines = Table.size("histograms");
	
	counter = 0;
	for (column = 0; column < headings.length; column++) {
		if (startsWith(headings[column], "rel. height")) {
			values = Table.getColumn(headings[column], "histograms");			
			continue;
		}
		counts = Table.getColumn(headings[column], "histograms");
		sum = 0;
		for (i = 0; i < counts.length; i++) {
			if (values[i]>1) break;
			sum += counts[i];
		}
		newColumn = newArray(sum);
		rawCounter = 0;
		for (i = 0; i < counts.length; i++) {
			if (values[i]>1) break;
			for(j=0; j<counts[i]; j++) {
				newColumn[rawCounter++] = values[i];
			}
		}
		Table.setColumn(countHeadings[counter++], newColumn, "raw data");
	}
}
