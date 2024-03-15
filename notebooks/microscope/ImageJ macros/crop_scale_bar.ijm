// Define the cropping size in microns
sizeInMicrons = 600;

// Define the desired length of the scale bar in microns
scaleBarLengthInMicrons = 200; // Adjust as needed

// Calculate the number of pixels per micron using the current scale
getPixelSize(unit, pixelWidth, pixelHeight);
pixelsPerMicron = 1 / pixelWidth;

// Calculate the size of the crop in pixels
sizeInPixels = sizeInMicrons * pixelsPerMicron;

// Define the output directory
outputDirectory = "C:/Users/alosvendsen/OneDrive - Syddansk Universitet/PhD/LAB books/Analyzed_Data/AS0006_7/Microscope/cropped images/";

// Check if the output directory exists, if not, create it
File.makeDirectory(outputDirectory);

// Process each opened image
for (i = 1; i <= nImages; i++) {
    // Select the current image
    selectImage(i);
    
    // Get the title for use in saving
    title = getTitle();
    
    // Wait for the user to select the area to crop
    waitForUser("Select the cropping area", "Use the rectangular selection tool to select any area. A square crop of XXX x XXX µm will then be applied.");
    
    // Get the current selection bounds
    getSelectionBounds(x, y, width, height);
    
    // Calculate the center of the user selection
    centerX = x + width / 2;
    centerY = y + height / 2;
    
    // Calculate new bounds for the fixed-size crop
    newX = centerX - sizeInPixels / 2;
    newY = centerY - sizeInPixels / 2;
    
    // Make the new square selection
    makeRectangle(newX, newY, sizeInPixels, sizeInPixels);
    
    // Crop the image
    run("Crop");
    
    // Add a scale bar to the cropped image
    run("Scale Bar...", "width=" + scaleBarLengthInMicrons + " height=20 font=18 color=Black background=None location=[Lower Right] hide");

    // Save the cropped image with the scale bar in the output directory
    saveAs("Tiff", outputDirectory + title);

    // Close the image if you do not need it open anymore
    close();
}

print("Finished processing all images.");
