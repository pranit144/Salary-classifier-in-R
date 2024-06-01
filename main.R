rm(list = ls())
#required libraries 
library(ROSE)
library(smotefamily)
library(caret)

data<- read.csv("ds_cp.csv")
head(data)
table(data$salary)

#converting salary column values in binary values
names(data) <- gsub(",", "", names(data))
data$salary_binary <- ifelse(data$salary == "high", 1, 0)

#---------------------------------------------------------#
#oversampling & under sampling#
both <- ovun.sample(salary_binary ~ ., data = data, method = "both", p = 0.5, seed = 222)$data
table(both$salary)
both <- both$data
both$salary_binary <- ifelse(both$salary == "high", 1, 0)

#--------------------------------------------------------#
#converting role column in numeric#
data$role<- as.factor(data$role)
data$role_numeric<- as.numeric(data$role)

#selecting specific coloumn to split the dataset for training & testing
# Step 1: Select specific columns and create a new dataframe
# Create an empty dataframe data2 with the same number of rows as data
temp_data <- c("satisfaction_level" , "number_project", "average_montly_hours","exp_in_company","role_numeric","salary_binary") 
data2 <- data.frame(matrix(nrow = nrow(data)))

# Set the column names for data2
colnames(data2) <- temp_data

# Loop through the columns and move them from data to data2
for (col_name in temp_data) {
  data2[[col_name]] <- data[[col_name]]
}

# Remove the first column from data2
data2 <- data2[, -1]

head(data2)

# Step 2: Split the new dataframe into training and testing sets
set.seed(1221)

index <- createDataPartition(data2$salary_binary, p = 0.7, list = FALSE)

training_data <- data2[index, ]
testing_data <- data2[-index, ]

anyNA(data2)
summary(data2)

training_data[["salary_binary"]]= factor(training_data[["salary_binary"]])

trlctrl<- trainControl(method ="repeatedcv",number = 10, repeats = 3)  

svm_linear<- train(salary_binary~.,data= training_data,method="svmLinear",
                   trControl=trlctrl,
                   preProcess=c("centre","scale"),
                   tuneLength= 10)
