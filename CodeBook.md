

## Sections

The script contains 5 sections:

1. reading data

2. add `activity` and `subject` to data

3. merge and subseting average and standard
deviation data

4. replace numeric value with descriptive ones and create column names

5. creating new dataset with average values of measurements by each subject and activity



## 1. Reading data

codes:
```
features <- fread("./data/features.txt", sep = " ", stringsAsFactors = F, header = F)
test_df <- fread("./data/test/X_test.txt", sep = " ", stringsAsFactors = F, header = F)
train_df <- fread("./data/train/X_train.txt", sep = " ", stringsAsFactors = F, header = F)
test_activity <- readLines("./data/test/y_test.txt")
train_activity <- readLines("./data/train/y_train.txt")
subject_test <- fread("./data/test/subject_test.txt", stringsAsFactors = F, header = F)
subject_train <- fread("./data/train/subject_train.txt", stringsAsFactors = F, header = F)
```
`features`: will be used as column names.

`test_df`, `train_df`: raw data for testing and training respectively.

`test_activity`, `train_activity`: activity category represented by number.

`subject_test`, `subject_train`: subject category represented by number.




## 2. Add `activity` and `subject` to data

codes:
```
test_df <- mutate(test_df, activity = test_activity)
test_df <- mutate(test_df, subject = subject_test$V1)
train_df <- mutate(train_df, activity = train_activity)
train_df <- mutate(train_df, subject = subject_train$V1)
```

`activity` and `subject` columns are added to testing and training data using `mutate` function from `dplyr` package.

## 3. Merge and subseting average and standard deviation data

codes:
```
dt <- add_row(test_df,train_df)
dt <- select(dt, grep("mean|std", features$V2), activity, subject)

```
`add_row` function from `dplyr` package is used to vertically join test and training data, and in order to select mean and standard deviation measures only, `grep` function is used to filter out all measurements containing "*mean*" and "*std*".


## 4. Replace with descriptive ones and create column names

codes:
```
dt$activity <- gsub("1", "WALKING", dt$activity)
dt$activity <- gsub("2", "WALKING_UPSTAIRS", dt$activity)
dt$activity <- gsub("3", "WALKING_DOWNSTAIRS", dt$activity)
dt$activity <- gsub("4", "SITTING", dt$activity)
dt$activity <- gsub("5", "STANDING", dt$activity)
dt$activity <- gsub("6", "LAYING", dt$activity)
cnames <- unlist(unclass(features[grep("mean|std", features$V2),2])$V2)
colnames(dt) <- c(cnames, "activity", "subject")
```

`gsub` function is used to replace all the numeric value in `dt$activity` with descriptive values and column names for various measurements are extracted from `features`.

## 5. Creating new dataset with average values of measurements by each subject and activity

codes:
```
avg <- dt %>% 
        group_by(subject) %>% 
        group_by(activity) %>% 
        mutate_at(1:79,mean) %>% 
        distinct()%>%
        select(subject, activity, 1:79) %>%
        arrange(subject, activity)
```
The new dataset, `avg` is created from `dt` via various functions all from `dplyr` package: `group_by`, `mutate_at`, `distinct`, `select`and `arrange`.

The purpose of each functions are stated below:

`group_by`: taking `dt$activity` and `dt$subject` as factors for later calculations.

`mutate_at`: calculate mean values at multiple columns (1:79).

`distinct`: since the mean value will be generated for each row of the same category, dupilcated rows are removed with this fuction.

`select`: move the `dt$activity` and `dt$subject` column in front.

`arrange`: reorder rows in ascending order of *subject* and *activity*.

