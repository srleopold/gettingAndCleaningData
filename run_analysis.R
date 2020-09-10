run_analysis <- function(){

    #verify if dplyr is installed, if not request the user to install dplyr first
    
    if(!require("dplyr")){
        stop("Dplyr library missing. Please install dplyr and try again")
    }
    
    #Download and unpack the dataset if missing
        
    if(!file.exists("UCI HAR Dataset")){
        message("Dataset folder missing in working directory. Downloading...")
        download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","data.zip",method="curl")
        if(!file.exists("data.zip")){
            stop("Download failed! Please retry later.")
        }
        message("Download successful! unzipping")
        unzip("data.zip")
        if(!file.exists("UCI HAR Dataset")){
            stop("Unzip failed! Please retry later.")
        }
        message("Unzip successful! Performing cleanup...")
        file.remove("data.zip")
    } else{
        message("Dataset folder present in working directory, skipping download.")
    }
    
    #Generate paths in an OS-independent way
    
    path_train_subject <- file.path("UCI HAR Dataset","train","subject_train.txt")
    path_train_data <- file.path("UCI HAR Dataset","train","X_train.txt")
    path_train_labels <- file.path("UCI HAR Dataset","train","y_train.txt")
    path_test_subject <- file.path("UCI HAR Dataset","test","subject_test.txt")
    path_test_data <- file.path("UCI HAR Dataset","test","X_test.txt")
    path_test_labels <- file.path("UCI HAR Dataset","test","y_test.txt")
    
    path_features <- file.path("UCI HAR Dataset","features.txt")
    path_activity_labels <- file.path("UCI HAR Dataset","activity_labels.txt")
    
    #read data and generate a merged dataset (assignment step 1)
    
    train_subjects <- read.table(path_train_subject)
    train_data <- read.table(path_train_data)
    train_labels <- read.table(path_train_labels)
    
    trainDataset <- cbind(train_subjects,train_data,train_labels)

    test_subjects <- read.table(path_test_subject)
    test_data <- read.table(path_test_data)
    test_labels <- read.table(path_test_labels)
    
    testDataset <- cbind(test_subjects,test_data,test_labels)
    
    #this is the resulting complete dataset
    
    completeDataset<- rbind(trainDataset,testDataset)
    
    #extract the mean and SD of each measurement (ssignment step 2)
    
    #note that the mean and SD indices are incremented 1 from the indices in
    #the original dataset (as numbered in the features.txt).
    #This is done because completeDataset contains the subjectid column before
    #the data columns
    
    featureNames <- read.table(path_features)
    
    #checking for the ( after mean makes sure we ignore the meanFreq values and
    #the angle() calculations in the end of the dataset
    columnindices <- grep("mean\\(|std\\(",featureNames[,2])+1
    
    #taking note of the number of columns to refer to it in other parts of the script
    numberOfColumns <- length(columnindices) + 2 
    
    subsettedDataset <- completeDataset[,c(1, columnindices,563)]
    
    #setting descriptive activity labels (assignment step 3)
    #these have been taken from activity_labels.txt but changed to be lowecase
    #and not having underscores, to make them simpler to reference
    #will also convert the column type to factors as it makes more sense for
    #the activity variable (this works as the labels are provided in the same
    #order as it was defined in the activity_labels.txt file, that is, 
    #the first label is the one corresponding to value 1 - walking, and so on)
    
    datasetDescriptiveActivityNames <- subsettedDataset
    activtyLabels <- read.table(path_activity_labels)
    labelsVector <- tolower(activtyLabels[,2])
    labelsVector <- sub("_","",labelsVector)
    
    #numberOfColumns is the number of columns in the dataset, and can be used 
    #to refer to the last column (that in this dataset is the activities column)
    datasetDescriptiveActivityNames[,numberOfColumns] <- factor(datasetDescriptiveActivityNames[,numberOfColumns],labels=labelsVector)
    
    #setting appropriate variable (column) names (assignment step 4)
    #we already have the original column names loaded in the featureNames variable
    #we assign it here shifting the indices again to have the original indices
    
    columnindices<-columnindices-1
    columnNames <- featureNames[columnindices,2]
    
    #simplify column names to make them easier to reference
    
    columnNames <- gsub("-|\\(|\\)","",columnNames)
    columnNames <- tolower(columnNames)
    
    datasetAppropriateNames <- datasetDescriptiveActivityNames
    names(datasetAppropriateNames) <- c("subjectid",columnNames,"activity")
    datasetAppropriateNames
    
    #generate the tidy dataset with the average of each variable (assignment step 5)
    #this section uses the dplyr library to improve code readability
    
    datasetTidyAverages <- datasetAppropriateNames %>% group_by(activity,subjectid) %>% summarise_all(mean)
    
    #write the dataset to a file
    
    write.table(datasetTidyAverages,"tidyDataset.txt",row.name=FALSE)
    
    #return the final, tidy dataset
    datasetTidyAverages
}