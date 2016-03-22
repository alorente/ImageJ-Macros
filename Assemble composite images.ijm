// Macro by Andrés Lorente-Rodríguez - Dec 5, 2015
// Postdoctoral fellow in Dr. Melanie H. Cobb Lab
// Pharmacology Department - UT Southwestern Medical Center
// I give permision to freely modify and distribute
// Aknowledgments of use would be nice
// Copyright held by UT Southwestern Medical Center


// Arrays have to be defined before using them

// Defining variables after "var" makes the variables global

var path = path1 = path2 = path3 = "";
var ListForTiles = newArray(); var nameArray = newArray(); var stainingArray = newArray();
var divider = "wv";
var Ch_1 = 	Ch_2 = Ch_3 = Ch_4 = Ch_1_ID = Ch_2_ID = Ch_3_ID = Ch_4_ID = "";
var color_1 = color_2 = color_3 = color_4 = b = g = r = w = "";
var Min_1 = Max_1 = Min_2 = Max_2 = Min_3 = Max_3 = Min_4 = Max_4 = 0;
var DIC_auto_enh = false; var DIC_sat = 0.35;

// These are the variables to modify by the user
var colorArray = newArray("Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Grays", "Fire", "blue orange icb", "cool", "Cyan Hot", "gem", "glasbey", "glow", "Green Fire Blue", "HiLo", "Magenta Hot", "Orange Hot", "phase", "physics", "Rainbow RGB", "Red Hot", "sepia", "smart", "thallium", "Thermal", "Yellow Hot");
var bitdepth = newArray("16", "12", "8");
var fileformat = newArray(".tif", ".lsm", ".zci", ".zvi", ".lif");


// Introduction

Dialog.create("");

	Dialog.addMessage("This macro is designed to quickly make brightness/contrast enhancements \n"+
					"and merge single images. Do not use with image stacks");

	Dialog.addMessage("\t");

	Dialog.addChoice("Please indicate the bit depth of your images: ", bitdepth);
	Dialog.addChoice("Please indicate the file format of your images: ", fileformat);
	Dialog.addString("Please indicate the the string that marks the middle of the name (e.g. wv) \n"+
					"This will help split the name in common (top) vs. identifier (bottom, e.g. UV): ", divider);
	Dialog.addMessage("\t");
	Dialog.addMessage("In the next window, please select the directory that contains all images to process\n"+

					  "\t\t\t\t\t\t (images within subfolders will NOT be processed)");

Dialog.show();

//

	bit = Dialog.getChoice();
		bit = pow(2, bit)-1;

	ext = Dialog.getChoice();
	divider = Dialog.getString();


// Asking user for master folder

path = getDirectory("Choose the Directory containing images to process");

	if (path=="") exit();

// Obtaining the list of ALL the images in the selected folder
	ListForTiles = getFileList(path);
// making subdirectory where processed images will be saved

	path1 = path + "Processed" + File.separator; File.makeDirectory(path1);
	path2 = path1 + "Merged" + File.separator; File.makeDirectory(path2);
	path3 = path1 + "Gray images" + File.separator; File.makeDirectory(path3);


// Interface with User about image format and adjustment of brightness and contrast

Dialog.create("Image Adjustments");

	Dialog.addMessage("Select minimun and maximum values for brightness contrast enhancement \n"+
					"In here you may rename the channels to something smart \n"+
					"To make the macro more flexible, type channel identifier");
	//
	Dialog.addString("Channel 1: \t \t \t \t", "");
	Dialog.addString("Identifier string in file name", "UV");
	Dialog.addChoice("Channel color will be", colorArray);

	Dialog.addSlider("Min: ", 0, bit, 0);

	Dialog.addSlider("Max: ", 0, bit, bit);

	//

	Dialog.addMessage("\t");

	Dialog.addString("Channel 2: \t \t \t \t", "");

	Dialog.addString("Identifier string in file name", "Blue");
	Dialog.addChoice("Channel color will be", colorArray);

	Dialog.addSlider("Min: ", 0, bit, 0);

	Dialog.addSlider("Max: ", 0, bit, bit);

	//

	Dialog.addMessage("\t");
	Dialog.addString("Channel 3: \t \t \t \t", "");

	Dialog.addString("Identifier string in file name", "Green");
	Dialog.addChoice("Channel color will be", colorArray);

	Dialog.addSlider("Min: ", 0, bit, 0);

	Dialog.addSlider("Max: ", 0, bit, bit);

	//

	Dialog.addMessage("\t");

	Dialog.addString("Channel 4: \t \t \t \t", "");

	Dialog.addString("Identifier string in file name", "DIC");
	Dialog.addChoice("Channel color will be", colorArray);

	Dialog.addSlider("Min: ", 0, bit, 0);

	Dialog.addSlider("Max: ", 0, bit, bit);
	Dialog.addCheckbox("Check for automatic DIC enhancement", DIC_auto_enh); // default=false
	Dialog.addNumber("\t If checked above, indicate saturation (0-1.00)", DIC_sat);
	//

Dialog.show();

	//

	Ch_1 = 	Dialog.getString();
Ch_1_ID = Dialog.getString();
	color_1 = Dialog.getChoice(); Min_1 = Dialog.getNumber(); Max_1 = Dialog.getNumber(); 
	//

	Ch_2 = Dialog.getString(); Ch_2_ID = Dialog.getString();
	color_2 = Dialog.getChoice(); Min_2 = Dialog.getNumber(); Max_2 = Dialog.getNumber(); 

	//

	Ch_3 = Dialog.getString(); Ch_3_ID = Dialog.getString();
	color_3 = Dialog.getChoice(); Min_3 = Dialog.getNumber(); Max_3 = Dialog.getNumber(); 

	//

	Ch_4 = Dialog.getString(); Ch_4_ID = Dialog.getString();
	color_4 = Dialog.getChoice(); Min_4 = Dialog.getNumber(); Max_4 = Dialog.getNumber();
	DIC_auto_enh = Dialog.getCheckbox(); 



setBatchMode(true); // This is to make the computer process everything on the background to improve speed



	// Make two arrays: one containing of all unique file names ~6k/4 names = nameArray

	//					another containing the 4 staining conditions = stainingArray

	tempArray2 = newArray();

	for (g=0; g<lengthOf(ListForTiles); g++){

		temptitle = ListForTiles[g];
		if (endsWith(temptitle, ext)==1) {// If it is an image with the file extension selected
			if (endsWith(temptitle, File.separator)!=1) { // If the filename is a folder it will skip to the next filename

				tileIndex = indexOf(temptitle, divider); // identifying character number where "wv" is in the file name
				if(tileIndex!=-1){ //If the title contains wv proceed
					name = substring(temptitle, 0, tileIndex);  // file name from begining to "wv"
					staining = substring(temptitle, tileIndex); // file name from "wv" to end
					// The occurencesInArray function looks into the indicated array (nameArray) for the appearance of the variable (name); 0 = absent
					// The addToArray function adds the variable (name) at the end of the array (position=lengthOf(nameArray))
					// If variable (name) is present in array it will not add it
					if (occurencesInArray(nameArray, name)==0) nameArray = addToArray(name, nameArray, lengthOf(nameArray));
					if (occurencesInArray(stainingArray, staining)==0) stainingArray = addToArray(staining, stainingArray, lengthOf(stainingArray));				
				}
			}
		}

	}


	// Processing images, making merged files and saving them

	for (j=0; j<lengthOf(nameArray); j++){
		// Opening files and asignning staining condition

		for (k=0; k<lengthOf(stainingArray); k++){ // To open the set of 4 images you want to process

			temptitle = nameArray[j] + stainingArray[k];

			if (indexOf(temptitle, Ch_1_ID)!=-1) b = temptitle; // shortcut for merge b = blue

			if (indexOf(temptitle, Ch_2_ID)!=-1) g = temptitle; // shortcut for merge g = green

			if (indexOf(temptitle, Ch_3_ID)!=-1) r = temptitle; // shortcut for merge r = red

			if (indexOf(temptitle, Ch_4_ID)!=-1) w = temptitle; // shortcut for merge w = grays

			image = path + temptitle;
			run("Bio-Formats Importer", "open=image color_mode=Default view=Hyperstack stack_order=XYCZT");
		}		
		SaveImages();
	}

setBatchMode(false);
run("Close All");

		
function SaveImages(){	
	

	selectWindow(b);
	// Making, saving and closing merged images

	getDimensions(Tile_width, Tile_height, Tile_channels, Tile_slices, Tile_frames);
	getVoxelSize(Tile_pixel_width, Tile_pixel_height, Tile_voxel_depth, Tile_unit);
	newImage("Tile", "16-bit black", Tile_height, Tile_width, 3, Tile_slices, Tile_frames);
	run("Properties...", "channels=3 slices="+Tile_slices+" frames="+Tile_frames+" unit="+Tile_unit+" pixel_width="+Tile_pixel_width+" pixel_height="+Tile_pixel_height+" voxel_depth="+Tile_voxel_depth);
	extensionIndex = indexOf(b, ext); finalTitle = substring(b, 0, extensionIndex); // removing extension from filename
	rename(finalTitle + "_merge"); title = getTitle();
	for (z=1; z<=3; z++){
		if (z==1) channel = b;
		if (z==2) channel = g;
		if (z==3) channel = r;
		selectWindow(channel);
			run("Select All"); run("Copy");
		selectWindow(title);
			Stack.setChannel(z); run("Paste");
		if (z==1){
			run(color_1); setMinAndMax(Min_1, Max_1);
		}if (z==2){
			run(color_2); setMinAndMax(Min_2, Max_2);
		}if (z==3){
			run(color_3); setMinAndMax(Min_3, Max_3);
		}
	}
	run("Make Composite"); run("Stack to RGB"); saveAs("Tiff", path2 + title);

	// Saving individual images; optional 
	selectWindow(b); run("Grays"); setMinAndMax(Min_1, Max_1);
		extensionIndex = indexOf(b, ext); finalTitle = substring(b, 0, extensionIndex); // removing extension from filename
		title = finalTitle + Ch_1; run("RGB Color"); saveAs("Tiff", path3+title); close();

	selectWindow(g); run("Grays"); setMinAndMax(Min_2, Max_2);
		extensionIndex = indexOf(g, ext); finalTitle = substring(g, 0, extensionIndex); // removing extension from filename
		title = finalTitle + Ch_2; run("RGB Color"); saveAs("Tiff", path3+title); close();

	selectWindow(r); run("Grays"); setMinAndMax(Min_3, Max_3);
		extensionIndex = indexOf(r, ext); finalTitle = substring(r, 0, extensionIndex); // removing extension from filename
		title = finalTitle + Ch_3; run("RGB Color"); saveAs("Tiff", path3+title); close();
		
	selectWindow(w); run("Grays");
		if (DIC_auto_enh==false){
			setMinAndMax(Min_4, Max_4);
		}else{
			resetMinAndMax(); run("Enhance Contrast", "saturated="+DIC_sat);
		}
		extensionIndex = indexOf(w, ext); finalTitle = substring(w, 0, extensionIndex); // removing extension from filename
		title = finalTitle + Ch_4; run("RGB Color"); saveAs("Tiff", path3+title); close();

	run("Close All");
}



//Adds the value to the array at the specified position, expanding if necessary

//Returns the modified array

function addToArray(value, array, position) { // http://www.richardwheeler.net/contentpages/textgallery.php?gallery=ImageJ_Macros 

	if (position<lengthOf(array)) {

		array[position]=value;

	} else {

		temparray=newArray(position+1);

		for (z=0; z<lengthOf(array); z++) {

			temparray[z]=array[z];

		}

		temparray[position]=value;

		array=temparray;

	}

	return array;

}



//Returns the number of times the value occurs within the array

function occurencesInArray(array, value){

    count=0;

    for (a=0; a<lengthOf(array); a++) {

        if (array[a]==value) {

            count++;

        }

    }

    return count;

}