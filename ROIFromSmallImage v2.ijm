/*  This macro opens a small scale image with ROI from a folder
 *   and extracts the ROI from a larger scale image (with the same name) from another folder
 *   saves ROI in a new folder named after file name.
 * usefull after extraction of scenes from an axioscan .czi with pyramidal images :
 *  
 */
 
scale=4;

input=getDirectory("Choose folder with Small images containing ROI");
input2=getDirectory("Choose folder with Large images ");

Dialog.create("Difference of scale");
Dialog.addNumber("What difference of scale between images ?", scale);
Dialog.show();


scale=Dialog.getNumber();


liste=getFileList(input);
setBatchMode(true);
for (j=0;j<liste.length;j++) { 
	
	if (isOpen("ROI Manager"));roiManager("reset");
	
		open(input+liste[j]); 
		
		if (Overlay.size!=0){

		title=getTitle();print(title);
		
		open(input2+liste[j]);rename("big");
		newName=File.nameWithoutExtension;
		output=input+newName;
		File.makeDirectory(output);
		
		selectWindow(title);
		run("To ROI Manager");
		nROI=roiManager("count");
		
				for (i = 0; i <nROI; i++) {

						roiManager("select", i);
						Roi.getBounds(x, y, width, height);
						selectImage("big");
						makeRectangle(x*scale, y*scale, width*scale, height*scale);
						run("Duplicate...", "title=big_"+i+" duplicate");
						}
						
		close("big");
		close ("title");
		
	
			
			for (i = 0; i <nROI; i++) {
				selectWindow("big_"+i);
				saveAs("Tiff", output+"\\"+newName+"_ROI_"+i);
			}

 	}

 	else print (list[i]+"  No Overlay");
 			
 			run("Close All");
	
 	call("java.lang.System.gc"); //////Cleans the memory	
 	}