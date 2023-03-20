#' WokeWindows citations
#' @docType data
#' @format
#' An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 150000 rows and 43 columns.
#' \describe{
#'   \item{issuing_agency}{Boston Police division that issuing officer belongs to. a character vector.}
#'   \item{agency_code}{Shorthand code for issuing agency. a character vector.}
#'   \item{officer_id}{Unique identifier for BPD offficers. a character vector.}
#'   \item{officer_name}{The name of the issuing officer.}
#'   \item{event_date}{Year-Month-Day.}
#'   \item{time_hh}{Hour of incident.}
#'   \item{time_mm}{Minute of incident.}
#'   \item{am_pm}{Whether the citation occurred in before midday or after midday.}
#'   \item{viol_type}{The type of violator. Owner, operator, passenger, or bike.}
#'   \item{citation_number}{"unique identifier for the citation; the same number will appear multiple times in the spreadsheet if the ticket is for multiple offenses." (Woke Windows)}
#'   \item{citation_type}{Can be civil, criminal, or arrest.}
#'   \item{offense}{"code for an offense; seems to correspond to a section in the Massachusetts General Laws e.g. '90160' is MGL c.90 §16" (Woke Windows).}
#'   \item{offense_description}{Detailed description of offense.}
#'   \item{disposition}{Code for result of offense.}
#'   \item{disposition_desc}{The description for the result of the offense, elaborates on disposition variable.}
#'   \item{location_name}{The location of the Boston neighborhood where the offense occurred.}
#'   \item{searched}{Whether a search was conducted.}
#'   \item{crash}{Whether the incident was a collision.}
#'   \item{court_code}{"see \href{https://www.mass.gov/info-details/trial-court-codes-numerical-listing}{Trial Court codes} for mapping" (Woke Windows)}
#'   \item{gender}{a character vector}
#'   \item{year_of_birth}{Birthdate of violator.}
#'   \item{lic_state}{State in which driver is licensed.}
#'   \item{lic_class}{See \href{https://www.mass.gov/files/documents/2018/03/22/chapter_1_0.pdf}{Massachussets Driver's Manual} for more information on license classes.}
#'     \item{cdl}{Whether the driver's license is a Commercial Driver's License.}
#'     \item{plate_type}{This is likely plate type as specified \href{https://www.mass.gov/doc/passenger-plates-manual/download}{here}}
#'     \item{vhc_state}{State in which vehicle is registered.}
#'     \item{vhc_year}{a numeric vector}
#'     \item{make_model}{Vehicle manufacturer (make) and model.}
#'     \item{commercial}{Whether the vehicle is commercial class.}
#'     \item{vhc_color}{Color of vehicle.}
#'     \item{sxteen_pass}{Whether the vehicle was capable of holding 16 or more passengers.}
#'     \item{haz_mat}{Whether hazardous materials were present upon search.}
#'     \item{amount}{Dollar fee associated with citation.}
#'     \item{paid}{Whether the citation was paid.}
#'     \item{hearing_requested}{Did the defendant request a hearing.}
#'     \item{speed}{Whether the citation was speed-related.}
#'     \item{posted_speed}{Posted speed limit in miles per hour (MPH).}
#'     \item{viol_speed}{Speed in MPH. Provided if citation is speed-related.}
#'     \item{posted}{Possibly whether a violater knew the posted speed.}
#'     \item{radar}{Type of radar used to check speed.}
#'     \item{clocked}{NA, "UNK", "CLOCK", or "EST".}
#'     \item{officer_cert}{Likely how the citation was served on the violator.}
#'     \item{race}{The race of the violator.}
#'}
#' @source \url{https://www.wokewindows.org/exports}
#' @source \url{https://github.com/nstory/boston_pd_citations}
"boston_pd_1120"

#' @docType data
#' @format
#' An object of class \code{tbl_df} (inherits from \code{tbl}, \code{data.frame}) with 174 rows and 2 columns.
#' \describe{
#'   \item{court_code}{Massachusetts court codes.}
#'   \item{court}{The court corresponding to a court code.}
#' }
#' @source \url{https://www.mass.gov/info-details/trial-court-codes-numerical-listing}
"court_codes"


