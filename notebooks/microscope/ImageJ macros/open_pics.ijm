// Define the directory containing the images
// inputDirectory = "C:/Users/alosvendsen/OneDrive - Syddansk Universitet/PhD/LAB books/Analyzed_Data/AS0012/microscope/plate 1 8G/";
inputDirectory = "C:/Users/alosvendsen/OneDrive - Syddansk Universitet/PhD/LAB books/Analyzed_Data/AS0006_7/Microscope/Plate 1 well 9G 10X/"
// Get a list of all files in the directory
listOfFiles = getFileList(inputDirectory);

// Open each image file
for (i = 0; i < listOfFiles.length; i++) {
    // Construct the full path to the image file
    path = inputDirectory + listOfFiles[i];
    
    // Check if the file is an image file based on the extension
    if (endsWith(path, ".tif") || endsWith(path, ".tiff") || endsWith(path, ".jpg") || endsWith(path, ".jpeg") || endsWith(path, ".png")) {
        // Open the image file
        open(path);
    }
}

print("Finished opening images.");
