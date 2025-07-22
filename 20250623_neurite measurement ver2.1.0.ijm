/*Neuron Branch Length Calculation for the Whole Image 
 * Compiled by Szu-Ting, Lin (March, 11 2025)
 * ver 2.0.0 – Features:
 * 1. Applied skeletonization to neuron mask.
 * 2. Derived soma mask from neuron mask using local thickness.
 * 3. Extracted neurites by subtracting soma mask from skeletonized neuron mask, followed by quantitative analysis and table export.
 * 4. Processed DAPI channel: segmentation via StarDist, followed by cell counting.

 * ver 2.1.0 – Updated on 2025/6/5 with the following changes:
 * ----1. Set the binary background to white to prevent errors during skeletonization.
 * ----2. Added: Enhance Contrast, Gaussian Blur, and Otsu-based thresholding (user adjustable) on neuron mask.
 * ----3. Implemented dialog windows for selecting folders.
 * ----4. Images names are more descriptive and user-friendly.
 * ----5. Added 3 checkpoints to prevent runtime errors.

*/
//setBatchMode(true); 
	run("Close All");
	run("Clear Results");;

// Prepare
#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output

	t1 = getTime(); 
	list = getFileList(input);
	list = Array.sort(list);
	Table.create("batch_results");
	Table.save(output + File.separator + "batch_results.csv");
	run("Options...", "iterations=1 count=1 white do=Nothing");
	
	open(input + File.separator + list[0]);
		run("Duplicate...", "title=reference");
	    run("Split Channels");
	    selectWindow("reference (green)");
	    run("8-bit");
	    Image.removeScale;    
	    run("Duplicate...", "title=neu2");
	    run("Enhance Contrast", "saturated=0.35");
		run("Gaussian Blur...", "sigma=2");
		run("Threshold...");
	    setAutoThreshold("Otsu dark");
	    waitForUser("adjust threshold "); //手動調整threshold，調完按ok
	    getThreshold(lower, upper);
	    run("Close All");
	
	for (i = 0; i < list.length; i++) {
	    if (!endsWith(list[i], ".tif")) continue;     
	    open(input + File.separator + list[i]);
	    tifName = getTitle();
	    Name = replace(tifName, ".tif", "");		
	    rename("raw");
	    run("Split Channels");
	    selectWindow("raw (red)");
	    close;	  
	    selectWindow("raw (green)");
	    rename("neuron");	    
	    selectWindow("raw (blue)");
	    rename("dapi");

	    // neuron	
	    selectImage("neuron");
	    run("8-bit");
	    Image.removeScale;    
	    run("Duplicate...", "title=neu2");
	    run("Enhance Contrast", "saturated=0.35");
		run("Gaussian Blur...", "sigma=2");
		setThreshold(lower, upper);	
	    run("Convert to Mask");
	    run("Analyze Particles...", "size=1500-Infinity show=Masks ");
	   // waitForUser("Checkpoint 1: Masks");	    //Checkpoint 1: Mask，確認按ok，不需要的話在前面加'//'
	    rename("mask");	    
	    run("Duplicate...", "title=mask2");
	
	    // Apply skeletonization
	    selectImage("mask");
	    run("Skeletonize");
	    rename("ske_neu");
	    
	 	//waitForUser("Checkpoint 2:Skeletonized neuron");  //Checkpoint 2:Skeletonized neuron，確認按ok，不需要的話在前面加'//'
	 		
	    // Local Thickness to get soma mask
	    selectImage("mask2");
	    run("Local Thickness (complete process)", "threshold=125");
	    setAutoThreshold("IsoData dark");
	    run("Convert to Mask");
	    run("Invert");	    
	    run("Divide...", "value=255.000");
	    rename("cyto");
	    imageCalculator("Multiply create", "ske_neu","cyto");
	    rename("neurites");	
	    
	    //waitForUser("Checkpoint 3: Neurites"); //Checkpoint 3: Neurites，確認按ok，不需要的話在前面加'//'
	    
		//measure neurites total area
	    selectImage("neurites");
	    run("Set Measurements...", "area integrated redirect=None decimal=3");
	    run("Measure");
	    total_l = getResult("IntDen", 0) / 255;  
	   
	    run("Clear Results");
	    selectImage("neu2");
	    close;
	    selectImage("ske_neu");
	    close;
	
	    // dapi
	    selectImage("dapi");
	    run("8-bit");	    
	    run("Duplicate...", "title=dapi2");
	    setAutoThreshold("Otsu dark");
	    run("Convert to Mask");	
	    selectImage("mask2");
	    run("Divide...", "value=255.000");
	    imageCalculator("Multiply create", "dapi2","mask2");
	    rename("nucleus");
	
	    // StarDist for segmentation
	    run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'nucleus', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'100.0', 'probThresh':'0.55', 'nmsThresh':'0.85', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'1', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");	    
	    
	    cell_n = roiManager("count");
	
	    selectImage("mask2");
	    close;
	    selectImage("dapi2");
	    close;
	    selectImage("nucleus");
	    close;	
	
	    // table
	    ratio = total_l / cell_n;
	    open(output + File.separator + "batch_results.csv");			
	    Table.set("Filename", i, Name);
	    Table.set("neurite area (pixel)", i, total_l);
	    Table.set("cell number", i, cell_n);
	    Table.set("average neurite area/cell", i, ratio);
	    Table.save(output + File.separator + "batch_results.csv");

	    // create composite image to check
	    selectWindow("neurites");
	    run("16-bit");	    
	    selectWindow("neuron");
	    run("16-bit");
	    run("Merge Channels...", "c1=[neurites] c2=[Label Image] c4=[neuron] create ignore");	
	    Stack.setChannel(2);
	    run("glasbey on dark");	
	    save(output + File.separator + Name + " composite.tif");
	    roiManager("reset");
	    close("*"); 
	}
	
// Finish
	t2 = getTime();
	t = (t2 - t1) / 1000;
	print("Processing completed in " + t + " s");
	
setBatchMode(false); 
