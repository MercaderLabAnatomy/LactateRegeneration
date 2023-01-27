//data for output file
output_filename = "images_quantification.csv";
column_names = "file_name,Channel_1_BFP,Channel_2_RFP,";

//getting input and output directories from user

#@ File (label="Select input directory", style="directory") input_dir
#@ File (label="Select output directory", style="directory") output_dir
#@ File (label="Select file to start analysis", style="file") starting_file

input_dir = input_dir + "/"
output_dir = output_dir + "/"

starting_file = File.getName(starting_file);

//getting a list of all files in the input directory
file_array = getFileList(input_dir);

//getting the index of the starting file
for (j = 0; j < file_array.length; j++) {
	if (file_array[j]==starting_file) {
			starting_file_index = j;
			break
		} 
	}


//for loop to iterate through all the files in the input directory
for (i = starting_file_index; i < file_array.length; i++) { 

	file_path = input_dir + file_array[i];
	file_name = file_array[i];
	file_name_no_extension = File.getNameWithoutExtension(file_name);

	//open file wih Bioformats (will not require opening options)
	run("Bio-Formats", "open="+file_path+" color_mode=Composite rois_import=[ROI manager] specify_range view=Hyperstack stack_order=XYCZT c_begin=1 c_end=2 c_step=1");

	
	//makes sure the table log is empty
	roiManager("reset");
	run("Clear Results");

	//get tool boxes
	run("Channels Tool...");
	run("Brightness/Contrast...");

	//opening chanel one and two, redefining colour and setting brightness/contrast to auto
	Stack.setChannel(1);
	run("Blue");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setDisplayMode("color");
	waitForUser("Adjust Blue channel if necessary");
	Stack.setChannel(2);
	run("Red");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setDisplayMode("color");
	waitForUser("Adjust Red channel if necessary");
	//at the end displaying composite mode again
	Stack.setDisplayMode("composite");
	
	original_image = getTitle();
	run("Duplicate...", "duplicate");
	duplicate_image = getTitle();

	//selecting the heart
	selectWindow(duplicate_image);
	setTool("polygon");
	waitForUser("Select the heart and press okay");
	roiManager("Add");
	last_roi_index = roiManager("count")-1;
	roiManager("select", last_roi_index);
	roiManager("Rename", "heart_selection");
	roiManager("Set Color", "yellow");
	roiManager("Set Line Width", 0);

	run("Clear Outside");
	run("Split Channels");
	
	selectWindow("C1-"+duplicate_image);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	run("Threshold...");
	setAutoThreshold("Default dark");
	waitForUser("Adjust Threshold in necessary");
	selectWindow("C1-"+duplicate_image);
	run("Create Selection");
	roiManager("Add");
	last_roi_index = roiManager("count")-1;
	roiManager("select", last_roi_index);
	roiManager("Rename", "blue_channel");
	roiManager("Set Color", "green");
	roiManager("Set Fill Color", "green");
	run("Measure");

	selectWindow("C2-"+duplicate_image);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	run("Threshold...");
	setAutoThreshold("Default dark");
	waitForUser("Adjust Threshold in necessary");
	selectWindow("C2-"+duplicate_image);
	run("Create Selection");
	roiManager("Add");
	last_roi_index = roiManager("count")-1;
	roiManager("select", last_roi_index);
	roiManager("Rename", "red_channel");
	roiManager("Set Color", "orange");
	roiManager("Set Fill Color", "orange");
	run("Measure");

	channel_1_area = getResult("Area", 0);
	channel_2_area = getResult("Area", 1);
	
	//storing measurements into variable
	final_results = file_name_no_extension+","+channel_1_area+","+channel_2_area+",";

	//saving all ROIs selections to outpu directory
	roiManager("Deselect");
	roiManager("Save", output_dir + file_name + ".rois.zip");

		//Creating file for storing measurements or just appending if file was alreay created
		if (File.exists(output_dir+output_filename)) 
			{File.append(final_results, output_dir+output_filename);
			} 
		else{File.open(output_dir+output_filename);
			File.append(column_names + "\n" + final_results, output_dir+output_filename);
			}

	//option to interrupt macro
	waitForUser("Image measurement complete. To continue press okay, hold shift and press okay to exit");
	stop_var = isKeyDown("shift");

	//closes file window before opening the next image
	close("*");
	if (stop_var == true) {break}

}