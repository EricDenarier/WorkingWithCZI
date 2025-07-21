
In = getDirectory("Choose directory with ROI images");
Out=getDirectory("Choose directory for results");
list=getFileList(In);



var KI67Ch="C2";
var HuNuCh="C3";
var minNuclei=20;
var maxNuclei=150;

Dialog.create("Choice of channels");
Dialog.addString("Channel for KI67 ?", KI67Ch);
Dialog.addString("Channel for HuNu ?", HuNuCh);
Dialog.addNumber("Min size for a nuclei (µm2)?" , minNuclei);
Dialog.addNumber("Max size for a nuclei (µm2)?" , maxNuclei);
Dialog.show();

KI67Ch=Dialog.getString();
HuNuCh=Dialog.getString();
minNuclei=Dialog.getNumber();
maxNuclei=Dialog.getNumber();

if (isOpen("Log")) { selectWindow("Log"); run("Close");}
if (isOpen("ROI Manager")) roiManager("reset");
if (isOpen("Results")) run("Clear Results");
print ("HuNu Nuclei Bis are calculated from segmented surface of HuNU/by average size of Ki67 nuclei. \n percent of KI67inHuNu=(Number of Ki67Nuclei in HuNuNuclei)/Number of HuNu Nuclei Bis)*100");
print ("Image     \t     #NumberNuclei KI67     \t    Total Area KI67      \t     AverageSize KI67      \t     #NumberNuclei HuNu     \t     Total Area HuNu   \t     AverageSize HuNu     \t     #NumberNuclei KI67inHuNu     \t     Total Area KI67inHuNu      \t     AverageSizeKI67inHuNu      \t     #NumberNuclei HuNu Bis     \t     Percent of KI67inHuNu");

//////////// Loop in folder

for (j=0;j<list.length;j++) { 
	
open(In+list[j]);
title=getTitle();
run("Select None");



getDimensions(width, height, channels, slices, frames);
setLocation(0, 200, width/2, height/2);


////////////////////

setSlice(2);
run("Enhance Contrast", "saturated=0.35");

run("Duplicate...", "title=Stack duplicate channels=1-3");

run("Split Channels");

selectWindow(HuNuCh+"-Stack"); rename ("HuNu");setLocation(100+width/2, 200, width/2, height/2);
selectWindow(KI67Ch+"-Stack"); rename ("KI67");setLocation(100+width/4, 200, width/2, height/2);


/////////// Segment KI67 image with min and max size for nuclei and Analyze

run("Subtract Background...", "rolling=50");
setAutoThreshold("Yen dark");
waitForUser("check Threshold");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size="+minNuclei+"-"+maxNuclei+" show=Masks in_situ summarize");


selectWindow(title);
setSlice(3);
run("Enhance Contrast", "saturated=0.35");

////////////////////// Segments HuNu image and Analyze
selectWindow("HuNu");
run("Subtract Background...", "rolling=50");
setAutoThreshold("Li dark");
waitForUser("check Threshold");
run("Convert to Mask");
run("Analyze Particles...", "  show=Nothing summarize");

////////////// Create image of KI67 AND HuNu with min and max size and Analyze
imageCalculator("AND create", "KI67","HuNu");

run("Analyze Particles...", "size="+minNuclei+"-"+maxNuclei+" summarize");

///////////////// get the results in different Arrays
IJ.renameResults("Summary","Results");

count=getCol("Count");
totalArea=getCol("Total Area");
averageSize=getCol("Average Size");
line=title+"    \t     ";

////////////// Prints the results in the Log
for (i=0;i<count.length;i++) line=line+count[i]+"     \t     "+totalArea[i]+"     \t     "+averageSize[i]+"     \t     ";

HuNuNuclei=floor(totalArea[1]/averageSize[0]);
percentKI37=count[2]/HuNuNuclei*100;

/////////////// Calulate percent Ki67 in HuNu Nuclei (calculated form average surface of Ki67 nuclei)
line=line+HuNuNuclei+"     \t     "+percentKI37;

print (line);

////////////// Merge and save segmented images and close
run("Merge Channels...", "c1=HuNu c2=KI67 c4=[Result of KI67] create ignore");
saveAs("Tiff", Out+title);
run("Close All");
run("Clear Results");

}

/////////// Save Log file
selectWindow("Log");
saveAs("Text", Out+"Log.txt");




////////////// Function to read column of the result table
function getCol(s) {
  a=newArray(nResults);
  for(i=0; i<a.length; i++) a[i]=getResult(s,i);
  return a;
}