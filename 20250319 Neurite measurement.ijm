// Neuron Branch Length Calculation for the Whole Image
// Compiled by Szu-Ting, Lin (March, 11 2025)
// step1: neuon mask --> skeletonization
// step2: neuon mask--> local thickness --> get soma mask
// step3: skeletonizaed neuon mask - soma mask --> neutrites --> calculation --> table
// step4: dapi --> segment by starist  --> cell count --> table

setBatchMode(true); 
	
	// prepare
	dir = getDirectory("Choose the input file"); 
	dir2 = getDirectory("Choose the output file"); 
	t1 = getTime(); 
	list = getFileList(dir); 	
	Table.create("batch_results");
	Table.save(dir2 + File.separator + "batch_results.csv");
	
	for (i = 0; i < list.length; i++) {
	    if (!endsWith(list[i], ".tif")) continue;     
	    open(dir + list[i]);
	    tifName = getTitle();
	    Name = replace(tifName, ".tif", "");		
	    rename("raw");
	    run("Split Channels");
	    selectWindow("raw (red)");
	    rename("C1-raw");
	    close;	  
	    selectWindow("raw (green)");
	    rename("C2-raw");	    
	    selectWindow("raw (blue)");
	    rename("C3-raw");
	
	    // neuron	
	    selectImage("C2-raw");
	    run("Duplicate...", "title=neu");
	    run("8-bit");
	    Image.removeScale;
	    
	    run("Duplicate...", "title=neu2");
	    setMinAndMax(0, 60);
	    setAutoThreshold("RenyiEntropy dark");
	    run("Analyze Particles...", "size=1500-Infinity show=Masks ");
	    rename("ske");
	    
	    run("Duplicate...", "title=cyto");
	    
	    // Apply skeletonization
	    selectImage("ske");
	    run("Skeletonize");
	
	    selectImage("C2-raw");
	    close;
	    selectImage("neu2");
	    close;
	
	    // Local Thickness to get soma mask
	    selectImage("cyto");
	    run("Local Thickness (complete process)", "threshold=125");
	   
	    setAutoThreshold("IsoData dark");
	    run("Convert to Mask");
	    run("Invert");
	    
	    run("Divide...", "value=255.000"); 
	    imageCalculator("Multiply create", "ske","cyto_LocThk");
	
	    selectImage("Result of ske");
	    run("Set Measurements...", "area integrated redirect=None decimal=3");
	    run("Measure");
	    total_l = getResult("IntDen", 0) / 255;  
	   
	    run("Clear Results");
	    selectImage("ske");
	    close;
	
	    // dapi
	    selectImage("C3-raw");
	    run("8-bit");	    
	    run("Duplicate...", "title=dapi");
	    setAutoThreshold("Otsu dark");
	    run("Convert to Mask");	
	    selectImage("cyto");
	    run("Divide...", "value=255.000");
	    rename("positive neu");
	    imageCalculator("Multiply create", "dapi","positive neu");
	
	    // StarDist for segmentation
	    run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'Result of dapi', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'100.0', 'probThresh':'0.55', 'nmsThresh':'0.85', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'1', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");	    
	    
	    cell_n = roiManager("count");
	
	    selectImage("positive neu");
	    close;
	    selectImage("Result of dapi");
	    close;
	    selectImage("dapi");
	    close;
	    selectImage("C3-raw");
	    close;	
	
	    // table
	    ratio = total_l / cell_n;
	    open(dir2 + File.separator + "batch_results.csv");			
	    Table.set("Filename", i, Name);
	    Table.set("neurite area (pixel)", i, total_l);
	    Table.set("cell number", i, cell_n);
	    Table.set("average neurite area/cell", i, ratio);
	    Table.save(dir2 + File.separator + "batch_results.csv");

	    // create composite image to check
	    selectWindow("Result of ske");
	    run("16-bit");	    
	    selectWindow("neu");
	    run("16-bit");
	    run("Merge Channels...", "c1=[Result of ske] c2=[Label Image] c4=[neu] create ignore");	
	    Stack.setChannel(2);
	    run("glasbey on dark");	
	    save(dir2 + File.separator + Name + " composite.tif");
	    roiManager("reset");
	    close("*"); 
	}
	
// Finish
	t2 = getTime();
	t = (t2 - t1) / 1000;
	print("Processing completed in " + t + " s");
	
setBatchMode(false); 
