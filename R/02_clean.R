# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
my_data_x <- read_tsv(file = "data/01_gravier_x.tsv.gz")
my_data_y <- read_tsv(file = "data/01_gravier_y.tsv.gz")


# Wrangle data ------------------------------------------------------------
nr <- nrow(my_data_x)
my_data_clean <- cbind(my_data_x[1:nr,], my_data_y[1:nr,])

# Write data --------------------------------------------------------------
write_tsv(x = my_data_clean,
          path = "data/02_my_data_clean.tsv")


