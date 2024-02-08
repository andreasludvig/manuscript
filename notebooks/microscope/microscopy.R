# Organize microscopy photos ----------------------------------------------
# Purpose of this script is to organize microscopy photos

# Donor 1/AS0003 and donor 2/AS0006. Are already done without R

# Donor 3, AS0012 ---------------------------------------------------------
# Reorganize by copying photos from same well on each day to a new colder
# Well 8G is good.

### Code commented out after use.
# library(fs)
# 
# # Base path where the Day folders are located
# path <- "C:/Users/alosvendsen/OneDrive - Syddansk Universitet/PhD/LAB books/Analyzed_Data/AS0012/microscope"
# 
# # Get the list of Day folders, excluding 'Day 0'
# folders <- dir_ls(path, type = "directory")
# folders <- folders[!grepl("plate", folders)]
# 
# # Well ID to process
# well_id <- "8G"
# 
# # New folder path for the specific well
# new_folder_path <- paste0(path, "/plate 1 ", well_id)
# 
# # Create the new folder for the well ID if it doesn't exist
# if (!dir_exists(new_folder_path)) {
#   dir_create(new_folder_path)
# }
# 
# 
# # Exclude the new well folder from the list of folders to process
# # In cases of rerunning the script. Avoids duplicates.
# folders <- folders[folders != new_folder_path]
# 
# # Loop through each Day folder to find and copy the images for the specified well ID
# for (folder in folders) {
#   # Extract the day number from the folder path
#   day_number <- basename(folder)
#   
#   # Construct the pattern to match files for the given well ID and exclude any files that already have a day number in their name
#   file_pattern <- paste0("PLATE 1 ", well_id)
#   
#   # List all matching files
#   files <- dir_ls(folder, regexp = file_pattern)
#   
#   # Copy each file to the new folder, appending the day number to the file name
#   for (file in files) {
#     # Extract the original file name
#     original_file_name <- basename(file)
#     
#     # Create a new file name with the day number prefixed
#     new_file_name <- paste0(day_number, " ", original_file_name)
#     
#     # Define the full path for the new file
#     new_file_path <- file.path(new_folder_path, new_file_name)
#     
#     # Check if the file already exists in the destination
#     if (!file_exists(new_file_path)) {
#       # If it doesn't exist, copy the file to the new location
#       file_copy(file, new_file_path)
#     }
#   }
# }



