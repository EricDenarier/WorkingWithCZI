
/* This macro extract all scenes from .czi file from AxioScan
It asks for the level of the pyramid image you want (1= Full size 2= 2time smaller 3= 4 time smaller etc...)
It detects a new scene by comparing image size (when imageX size > imageX-1 size, the scene has changed) found in the metadata
Save images in a new folder
*/


input=getDirectory("Choose a folder for czi");
output=getDirectory("Choos a folder for result tif images");

var scale=3;

Dialog.create("Choice of image scale (1 for full size 2 for 2time smaller");
Dialog.addNumber("What scale of image do you want ?", scale);
Dialog.show();


scale=Dialog.getNumber();

setBatchMode(true);

liste=getFileList(input);

for (j=0;j<liste.length;j++) { 
	
	

		
		  if (endsWith(liste[j], ".czi"))	




run("Bio-Formats Importer", "open=["+input+liste[j]+"] autoscale color_mode=Composite display_metadata rois_import=[ROI manager] view=[Metadata only] stack_order=Default");metaData=getInfo("window.contents");



metaData=split(getInfo("window.contents"),'\n');
lineSizeX=newArray();
lineImageNumber=newArray();


for (i = 0; i < metaData.length; i++) {
	
	if (indexOf(metaData[i], "SizeX")!=-1) 	{
		
			lineX=split(metaData[i],'\t');
			lineImageNumber=push(lineImageNumber,lineX[0]);
			lineSizeX=push(lineSizeX,lineX[1]); // LineX[1] is image size;
			
		}
}

ImageSize=newArray(lineSizeX.length);

for (i = 0; i < lineSizeX.length; i++) ImageSize[i]=parseInt(lineSizeX[i]); // ImageSize is an array with numbers 


diffSize=newArray(ImageSize.length-1);
bigImageIndices=newArray();


///////////// Detection of new  Scene by increased size of the image
for (i = 0; i < ImageSize.length-1; i++) {
	
	if (i==0) diffSize[0]=-1;
	
	else diffSize[i]=ImageSize[i]-ImageSize[i+1];
	
	}

// Image openning				
for (i = 0; i < diffSize.length-2; i++) 	{
		
			
		if (diffSize[i]<0) { 
					
			
			if (i==0) nbre=i+scale;
			else nbre=i+1+scale;
			series=" series_"+nbre;
		
			run("Bio-Formats", "open=["+input+liste[j]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"+ series);
			title=getTitle();
			saveAs("Tiff", output+nbre+"_"+File.nameWithoutExtension);
			run("Close All");	
			
			
			/*selectWindow("Original Metadata - "+liste[j]);
			run("Close");	*/
			
	}						
}
run("Close");					
call("java.lang.System.gc");
						
			
						}



	

function push(array,value) {
  a = newArray(array.length+1);
  for(i=0; i<array.length; i++) a[i]= array[i];
  a[a.length-1] = value;
  return a;
}
