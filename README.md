# Introduction

This repository contains the files for the Getting and Cleaning Data Course Project

The contents are:
* **run_analysis.R**: R script file containing a single function (run_analysis) that performs all required steps and generates the tidy dataset
* **CodeBook.md**: the codebook describing the generated dataset and the steps to obtain the values presented
* **README.md**: this file, describing the repository contents
* **tidyDataset.txt**: the resulting tidy dataset

# Instructions

After sourcing the script, simply call run_analysis() (without arguments)

The function will perform the following steps:
* Attempt to load the dplyr package, if it isn't available it will stop and present an error to the user (it won't install the package on its own so the user can decide what to do)
* Check if the folder "UCI HAR Dataset" exists in the working directory. If not, it will download the zip file containing the dataset, unzip it, and then delete the zip file
* Perform steps 1-5 as stated in the assignment, writing the resulting tidy dataframe to tidyDataset.txt in the working directory and also returning a tibble (dplyr tbl_df) as the function value