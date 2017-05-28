#' Read in a file and return a tbl dataframe
#'
#' @param filename The name of a csv file to read in.
#' @return a data frame tbl containing the data in the file
#' @note file has to be in the working directory.  If no file called filename exists in the working directory,
#' then return an error

fars_read <- function(filename) {
        if(!file.exists(filename))
                stop("file '", filename, "' does not exist")
        data <- suppressMessages({
                readr::read_csv(filename, progress = FALSE)
        })
        dplyr::tbl_df(data)
}

#' Create a file name for a given year
#'
#' @param year an integer
#' @return a string representing a file name
#' @examples make_filename(2014) returns "accident_2014.csv.bz2"
#'
make_filename <- function(year) {
        year <- as.integer(year)
        sprintf("accident_%d.csv.bz2", year)
}

#' Compute month and year information for given years
#'
#' @param years  A vector of integers
#' @return a list of tbl dataframes which have columns MONTH and year
#' @examples fars_read_years(c(2013, 2014))
#' @note "dplyr" package is required.  If the argument "years" include a year
#' where no data file exist, then the function returns NULL and a
#' warning showing an invalid year
fars_read_years <- function(years) {
        lapply(years, function(year) {
                file <- make_filename(year)
                tryCatch({
                        dat <- fars_read(file)
                        dplyr::mutate(dat, year = year) %>%
                                dplyr::select(MONTH, year)
                }, error = function(e) {
                        warning("invalid year: ", year)
                        return(NULL)
                })
        })
}

#' Show a summary of accidents during given years
#'
#' @param years  a vector of integers
#' @return a tibble showing summary of number of accidents by month
#' for each input year
#' @note "dplyr" package is required.  If input years contains a year where no data exists,
#' then the function will returns summary for valid years and a warning of invalid year.
#' error and warning message are returned when the list of years contains no valid year.
fars_summarize_years <- function(years) {
        dat_list <- fars_read_years(years)
        dplyr::bind_rows(dat_list) %>%
                dplyr::group_by(year, MONTH) %>%
                dplyr::summarize(n = n()) %>%
                tidyr::spread(year, n)
}

#' Draw accident locations on the map
#'
#' @param stat.num  a state number shown in the "state" column data
#' @param year specify the year of data
#' @return a map based on the Longitude and Latitude in the data
#' @note "maps" package is required
fars_map_state <- function(state.num, year) {
        filename <- make_filename(year)
        data <- fars_read(filename)
        state.num <- as.integer(state.num)

        if(!(state.num %in% unique(data$STATE)))
                stop("invalid STATE number: ", state.num)
        data.sub <- dplyr::filter(data, STATE == state.num)
        if(nrow(data.sub) == 0L) {
                message("no accidents to plot")
                return(invisible(NULL))
        }
        is.na(data.sub$LONGITUD) <- data.sub$LONGITUD > 900
        is.na(data.sub$LATITUDE) <- data.sub$LATITUDE > 90
        with(data.sub, {
                maps::map("state", ylim = range(LATITUDE, na.rm = TRUE),
                          xlim = range(LONGITUD, na.rm = TRUE))
                graphics::points(LONGITUD, LATITUDE, pch = 46)
        })
}
