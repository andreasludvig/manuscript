# Calculate geometric mean ------------------------------------------------

# Geometric mean function
#' Geometric mean
#'
#' @param x Vector of numericals
#'
#' @return Returns a numeric vector of one with the geometric mean of input
#'
geometric_mean <- function(x, na.rm = TRUE) {
  exp(mean(log(x), na.rm = na.rm))
}





# Get experiment and plate id ---------------------------------------------

#' Extract name 
#'
#' @param path String with path to file
#'
#' @return Experiment name and plate number, eg. ASXXXX_Plate_XX
#' @export
#'
#' @examples
extract_name <- function(path) {
  match_position <- regexpr("AS\\d+_Plate_\\d+", path) # Looking for AS(any_digits)_Plate_(any digits)
  return(regmatches(path, match_position))
}


