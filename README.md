# Package: SoundClassifierR**

# Type:  Package

# Title:  Simple Sound Classification using PCA and kNN

# Version:  0.1.0

# Author:  Ravi Jani

# Maintainer:  Ravi Jani [rj270907@gmail.com](mailto:rj270907@gmail.com)

# Description:

SoundClassifierR provides a simple pipeline for classifying audio signals into categories such as human, animal, bird, and machine. It extracts basic features from .wav files, trains a classification model, and predicts the class of new audio inputs. The package is designed for educational purposes and demonstrates how signal processing and machine learning can be combined.

# License: MIT

# Encoding: UTF-8

# Imports: tuneR, seewave, class

# RoxygenNote: 7.3.3

# NeedsCompilation:** no

# Packaged: 2026-04-03 11:11:58 UTC; ravijani


############################################################
# SoundClassifierR Demo (Run step by step)
############################################################

# STEP 0: SET THE DIRECTORY
# In RStudio:
# Files tab → open folder "240486" → ⚙️ → Set As Working Directory(YOU KNOW IT BETTER THEN ME😁)



# -------------------------------
# STEP 1: INSTALL PACKAGE(🔨🔧)
# -------------------------------
cat("\nInstall package\n")

install.packages("SoundClassifierR_0.1.0.tar.gz",
                 repos = NULL,
                 type = "source")


# -------------------------------
# STEP 2: LOAD PACKAGE(🫣)
# -------------------------------
cat("\nLoad package\n")

library(SoundClassifierR)


# -------------------------------
# STEP 3: LOAD AUDIO(🎶🎶)
# -------------------------------
cat("\nLoad audio\n")

file_path <- "audio/machine1.wav"

if (!file.exists(file_path)) {
  stop("Audio file not found! Check 'audio/' folder.")
}

audio <- load_audio(file_path)


# -------------------------------
# STEP 4: PLOT SPECTROGRAM(🎨🎨)
# -------------------------------
cat("\nPlot spectrogram\n")

plot_spectrogram(file_path)


# -------------------------------
# STEP 5: EXTRACT FEATURES
# -------------------------------
cat("\nExtract features\n")

features <- extract_features(audio)


# -------------------------------
# STEP 6: TRAIN MODEL(🏋🏋)
# -------------------------------
cat("\nTrain model\n")

training_features <- rbind(
  features,
  features + rnorm(length(features), 0, 0.01)
)

labels <- c("Machine", "Noise")

model <- train_sound_model(training_features, labels)


# -------------------------------
# STEP 7: CLASSIFY AUDIO
# -------------------------------
cat("\nClassify audio\n")

result <- classify_sound(file_path, model)

cat("\nFinal Prediction:\n")
print(result)
# (🛐🛐)


############################################################
# END(👋👋)
############################################################
