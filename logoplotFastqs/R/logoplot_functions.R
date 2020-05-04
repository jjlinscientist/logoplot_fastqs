#' Wrapper around consensusMatrix()
#'
#' Wrapper around consensusMatrix() from the ShortRead package to import sequences from a fastq file and (optionally) align them at the 5' (left) or 3' (right) DNA base
#' depends on packages Biostrings, data.table, ShortRead
#'
#' @author Justin Lin, \email{justin.jnn.lin@@gmail.com}
#' @keywords utilities
#'
#' @param file A fastq file
#' @param right_align Logical statement to 'right justify' all sequences found in the fastq file.  defaults to FALSE
#' @return Returns a matrix of DNA base frequencies
#' 
#' @examples
#' consensusMatrix_function('path/to/file.fastq', right_align = TRUE)


consensusMatrix_function <- function(file, right_align = FALSE) {
    sequences <- ShortRead::sread(ShortRead::readFastq(file))
    if (length(sequences) == 0) {
        mat <- NA
    } else {
        if (right_align) {
            sequences <- Biostrings::reverse(sequences)
            mat <- Biostrings::consensusMatrix(sequences, as.prob = FALSE, baseOnly = TRUE)
            mat <- mat[, c(ncol(mat):1)]
        } else {
            mat <- Biostrings::consensusMatrix(sequences, as.prob = FALSE, baseOnly = TRUE)
        }
    }
    return(mat)
}

#' Creates a logoplot grob 
#' 
#' Creates a grob object (containing a read logoplot and depth barplot) from a consensusMatrix_function() matrix object
#' depends on ggplot2, ggpmisc, ggseqlogo 
#' 
#' @author Justin Lin, \email{justin.jnn.lin@@gmail.com}
#' @keywords graphics
#' 
#' @param mat A matrix object from consensusMatrix_function()
#' @param method String value of 'bit' or 'prob' for ggseqlogo::geom_logo(), indicating plot method
#' @param label Plot title
#' @param description Plot description
#' @return Returns a gtable object consisting of read logoplot and depth barplot
#' 
#' @examples
#' make_logoplots(mat = mat, method = 'bits', label = 'tumor_sample', description = 'tumor_sample.fastq.gz')

make_logoplots <- function(mat, method, label = "some_generic_sample", description) {
    if (is.na(mat[1])) {
        logoplot <- ggplot() + annotate("text", x = 1, y = 1, label = "No Sequences") + 
            theme_logo() + theme(plot.margin = unit(c(0, 0, -1, 0), "lines"), plot.title = element_text(hjust = 0.5), 
            axis.text.y = element_blank(), axis.text.x = element_blank(), aspect.ratio = 0.1) + 
            ggtitle(label = paste(label, description, collapse = ": ")) + labs(x = NULL, 
            y = NULL)
        barplot <- ggplot() + annotate("text", x = 1, y = 1, label = "No Sequences") + 
            theme_logo() + theme(plot.margin = unit(c(-1, 0, 0, 0), "lines"), plot.title = element_text(hjust = 0.5), 
            axis.text.y = element_blank(), axis.text.x = element_blank(), aspect.ratio = 0.1) + 
            labs(x = NULL, y = NULL)
    } else {
        counts <- colSums(mat)
        df <- data.frame(bp_position = c(1:length(counts)), cov = counts)
        logoplot <- ggplot() + geom_logo(mat, method = method) + scale_x_continuous(breaks = seq(0, 
            ncol(mat), 10)) + theme_logo() + theme(plot.margin = unit(c(0, 0, 0, 
            0), "lines"), plot.title = element_text(hjust = 0.5), aspect.ratio = 0.1, 
            axis.text.y = element_blank(), axis.text.x = element_blank(), axis.title.x = element_blank(), 
            axis.ticks.x = element_blank()) + ggtitle(label = paste(label, description, 
            collapse = ": "), subtitle = paste(max(df$cov), "reads", collapse = " ")) + 
            coord_fixed(ratio = 4, ylim = c(0, 1.5), expand = TRUE) + labs(x = NULL, 
            y = NULL)
        barplot <- ggplot() + geom_bar(data = df, aes(x = bp_position, y = cov), 
            stat = "identity", width = 0.8) + scale_x_continuous(breaks = seq(0, 
            ncol(mat), 10)) + theme_logo() + theme(plot.margin = unit(c(0, 0, 0, 
            0), "lines"), aspect.ratio = 0.1, axis.text.y = element_blank(), plot.title = element_text(hjust = 0.5)) + 
            labs(x = "read position (bp)", y = NULL)
    }
    logoplot_grob <- ggplotGrob(logoplot)
    barplot_grob <- ggplotGrob(barplot)
    sub_plot <- rbind(logoplot_grob, barplot_grob, size = "last")
    return(sub_plot)
}

