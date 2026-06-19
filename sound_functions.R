#' Load an audio file from disk
#'
#' This function reads a `.wav` audio file and converts it into a Wave object
#' that can be further processed. It is typically the first step in the
#' sound classification pipeline.
#'
#' @param file A character string specifying the path to the `.wav` file.
#'
#' @return A Wave object containing the audio signal.
#'
#' @details
#' The function uses \code{tuneR::readWave()} to load the file.
#' It also checks whether the file exists before attempting to read it.
#'
#' @examples
#' \dontrun{
#' audio <- load_audio("bird1.wav")
#' }
#'
#' @export
load_audio <- function(file) {
  
  if (!file.exists(file)) {
    stop("File does not exist")
  }
  
  audio <- tuneR::readWave(file)
  return(audio)
}



#' Extract spectral features from audio
#'
#' This function converts an audio signal into a set of numerical features
#' based on its frequency spectrum. These features are later used for
#' training and classification.
#'
#' The function is part of the sound classification pipeline.
#'
#' @param audio A Wave object returned by \code{load_audio()}.
#'
#' @return A numeric vector containing:
#' \itemize{
#'   \item Mean frequency
#'   \item Standard deviation of frequency
#'   \item Maximum frequency
#' }
#'
#' @details
#' The function computes the mean spectrum using
#' \code{seewave::meanspec()} and extracts summary statistics.
#'
#' Although simple, these features are sufficient for demonstrating
#' basic audio classification techniques.
#'
#' @examples
#' \dontrun{
#' audio <- load_audio("bird1.wav")
#' extract_features(audio)
#' }
#'
#' @export
extract_features <- function(audio) {
  
  if (!inherits(audio, "Wave")) {
    stop("Input must be a Wave object")
  }
  
  spec <- seewave::meanspec(audio, plot = FALSE)
  
  mean_freq <- mean(spec[,2])
  sd_freq   <- sd(spec[,2])
  max_freq  <- max(spec[,2])
  
  features <- c(mean_freq, sd_freq, max_freq)
  
  return(features)
}



#' Train a sound classification model
#'
#' This function builds a classification model using extracted features
#' and corresponding labels. It applies Principal Component Analysis (PCA)
#' to reduce dimensionality and prepares the data for classification.
#'
#' The function is a core component of the sound classification pipeline.
#'
#' @param feature_matrix A numeric matrix where each row represents
#' features extracted from an audio file.
#'
#' @param labels A character vector of class labels corresponding to
#' each row in the feature matrix.
#'
#' @return A list containing:
#' \itemize{
#'   \item PCA model
#'   \item Transformed training data
#'   \item Labels
#' }
#'
#' @details
#' The function removes constant features (zero variance),
#' applies PCA, and stores the transformed data.
#'
#' The resulting model can be used for classifying new audio samples.
#'
#' @examples
#' \dontrun{
#' model <- train_sound_model(train_matrix, labels)
#' }
#'
#' @export
train_sound_model <- function(feature_matrix, labels) {
  
  if (nrow(feature_matrix) != length(labels)) {
    stop("Mismatch between features and labels")
  }
  
  feature_matrix <- feature_matrix[, apply(feature_matrix, 2, var) != 0, drop = FALSE]
  
  pca <- prcomp(feature_matrix, scale = TRUE)
  
  list(
    pca = pca,
    train = pca$x,
    labels = labels,
    n_features = ncol(feature_matrix)
  )
}



#' Classify a sound file
#'
#' This function predicts the category of a `.wav` audio file using
#' a trained sound classification model.
#'
#' It is the final step in the sound classification pipeline.
#'
#' The classification is based on spectral features and PCA transformation,
#' followed by a nearest-neighbor comparison in the transformed space.
#'
#' @param file A character string specifying the path to a `.wav` file.
#'
#' @param model A trained model returned by \code{train_sound_model()}.
#'
#' @return A predicted class label.
#'
#' @details
#' The classification process involves:
#' \enumerate{
#'   \item Loading the audio file
#'   \item Extracting spectral features
#'   \item Transforming features using PCA
#'   \item Comparing with training data using Euclidean distance
#' }
#'
#' The predicted label corresponds to the closest training sample
#' in the PCA-transformed space.
#'
#' @examples
#' \dontrun{
#' classify_sound("bird1.wav", model)
#' }
#'
#' @export
classify_sound <- function(file, model) {
  
  if (!file.exists(file)) {
    stop("File does not exist")
  }
  
  audio <- load_audio(file)
  feat <- extract_features(audio)
  
  feat <- matrix(feat, nrow = 1)
  
  if (ncol(feat) != model$n_features) {
    stop("Feature mismatch: retrain model")
  }
  
  feat_pca <- predict(model$pca, feat)
  
  dists <- apply(model$train, 1, function(x) {
    sum((x - feat_pca)^2)
  })
  
  model$labels[which.min(dists)]
}



#' Plot spectrogram of an audio file
#'
#' This function visualizes the frequency content of an audio signal
#' over time using a spectrogram.
#'
#' @param file A character string specifying the path to the audio file.
#'
#' @return A spectrogram plot.
#'
#' @details
#' The spectrogram is generated using \code{seewave::spectro()}.
#' It shows how frequency components vary over time.
#'
#' @examples
#' \dontrun{
#' plot_spectrogram("bird1.wav")
#' }
#'
#' @export
plot_spectrogram <- function(file = NULL) {
  
  # if no file given → use built-in sample
  if (is.null(file)) {
    file <- system.file("extdata", "sample.wav", package = "SoundClassifierR")
  }
  
  audio <- load_audio(file)
  
  par(mar = c(4, 4, 2, 1))
  
  seewave::spectro(audio)
}


