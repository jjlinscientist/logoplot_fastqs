#' Print a pdf from a list of grobs,
#'
#' Creates a pdf from a list of grobs e.g. the output of make_logoplots().
#'
#' @author Justin Lin, \email{justin.jnn.lin@@gmail.com}
#' @keywords graphics
#'
#' @param grobs A list of grobs
#' @param output_filename Name of the output file, including full path 
#' @param plot_width Width (in inches) to draw each plot. Defaults to 8.
#' @param plot_height Height (in inches) to draw each plot. Defaults to 3.
#'
#' @examples
#' print_grobs(grobs, '/path/to/output.pdf', plot_width = 8, plot_height = 3)

print_grobs <- function(grobs, output_filename, plot_width = 8, plot_height = 3) {
    scaleFactor <- length(grobs)
    pdf(file = output_filename, width = plot_width, height = plot_height * scaleFactor)
    print(marrangeGrob(grobs = grobs, nrow = scaleFactor, ncol = 1))
    dev.off()
}
