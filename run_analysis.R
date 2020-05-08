library(data.table)
library(dplyr)

#reading data
features <- fread("./data/features.txt", sep = " ", stringsAsFactors = F, header = F)
test_df <- fread("./data/test/X_test.txt", sep = " ", stringsAsFactors = F, header = F)
train_df <- fread("./data/train/X_train.txt", sep = " ", stringsAsFactors = F, header = F)
test_activity <- readLines("./data/test/y_test.txt")
train_activity <- readLines("./data/train/y_train.txt")
subject_test <- fread("./data/test/subject_test.txt", stringsAsFactors = F, header = F)
subject_train <- fread("./data/train/subject_train.txt", stringsAsFactors = F, header = F)

#add activity and subject column to data
test_df <- mutate(test_df, activity = test_activity)
test_df <- mutate(test_df, subject = subject_test$V1)
train_df <- mutate(train_df, activity = train_activity)
train_df <- mutate(train_df, subject = subject_train$V1)

#merging training and testing sets
dt <- add_row(test_df,train_df)

#subsetting those with "mean" and "std" inside
dt <- select(dt, grep("mean|std", features$V2), activity, subject)

#replace numbers with descriptive values
dt$activity <- gsub("1", "WALKING", dt$activity)
dt$activity <- gsub("2", "WALKING_UPSTAIRS", dt$activity)
dt$activity <- gsub("3", "WALKING_DOWNSTAIRS", dt$activity)
dt$activity <- gsub("4", "SITTING", dt$activity)
dt$activity <- gsub("5", "STANDING", dt$activity)
dt$activity <- gsub("6", "LAYING", dt$activity)

#use descriptive column names
cnames <- unlist(unclass(features[grep("mean|std", features$V2),2])$V2)
colnames(dt) <- c(cnames, "activity", "subject")

#creating new dataset with average values of measurements by each subject and activity
avg <- dt %>% 
        group_by(subject) %>% 
        group_by(activity) %>% 
        mutate_at(1:79,mean) %>% 
        distinct()%>%
        select(subject, activity, 1:79) %>%
        arrange(subject, activity)

#writing data
write.table(avg, file = "average_data.txt", row.name = F)
write.table(dt, file = "tidy_data.txt", row.name = F)
