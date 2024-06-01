# README for Salary Prediction Project

## Project Overview
This project involves predicting employee salary levels using various features related to their job satisfaction, workload, experience, and role within the company. The goal is to classify whether an employee's salary is "high" or not, based on the given dataset.

## Dataset
The dataset used in this project (`ds_cp.csv`) includes the following columns:
- `satisfaction_level`: Employee satisfaction level (0-1)
- `number_project`: Number of projects assigned to the employee
- `average_montly_hours`: Average monthly working hours
- `exp_in_company`: Number of years the employee has worked at the company
- `role`: Role of the employee within the company
- `salary`: Salary level (categorical: "low", "medium", "high")

## Project Steps

### 1. Data Preprocessing
- **Read Data**: Load the dataset into R using `read.csv`.
- **Convert Salary to Binary**: The `salary` column is converted into a binary format where "high" is labeled as 1 and others as 0.
- **Oversampling and Undersampling**: To address class imbalance, both oversampling and undersampling techniques are applied using the `ROSE` package.
- **Convert Role to Numeric**: The `role` column is converted from a categorical variable to a numeric format.
- **Select Specific Columns**: Create a new dataframe with selected columns for model training and testing.

### 2. Data Splitting
- **Create Training and Testing Sets**: The dataset is split into training (70%) and testing (30%) sets using the `caret` package.

### 3. Model Training
- **Train SVM Model**: A Support Vector Machine (SVM) model with a linear kernel is trained using the training dataset. The model training includes cross-validation to optimize hyperparameters.

### 4. Evaluation
- The trained model is evaluated on the testing set to measure its performance.

## Required Libraries
The following R libraries are required for this project:
- `ROSE`
- `smotefamily`
- `caret`

To install these packages, you can run:
```R
install.packages(c("ROSE", "smotefamily", "caret"))
```

## Code Overview

### Load and Preprocess Data
```R
# Clear environment
rm(list = ls())

# Load libraries
library(ROSE)
library(smotefamily)
library(caret)

# Read dataset
data <- read.csv("ds_cp.csv")
head(data)
table(data$salary)

# Convert salary to binary
names(data) <- gsub(",", "", names(data))
data$salary_binary <- ifelse(data$salary == "high", 1, 0)
```

### Oversampling and Undersampling
```R
# Apply oversampling and undersampling
both <- ovun.sample(salary_binary ~ ., data = data, method = "both", p = 0.5, seed = 222)$data
table(both$salary)
both <- both$data
both$salary_binary <- ifelse(both$salary == "high", 1, 0)
```

### Convert Role to Numeric
```R
# Convert role to numeric
data$role <- as.factor(data$role)
data$role_numeric <- as.numeric(data$role)
```

### Create Dataframe with Selected Columns
```R
# Select specific columns
temp_data <- c("satisfaction_level", "number_project", "average_montly_hours", "exp_in_company", "role_numeric", "salary_binary")
data2 <- data.frame(matrix(nrow = nrow(data)))
colnames(data2) <- temp_data

for (col_name in temp_data) {
  data2[[col_name]] <- data[[col_name]]
}

# Remove the first column from data2
data2 <- data2[, -1]
head(data2)
```

### Split Data into Training and Testing Sets
```R
# Split the data
set.seed(1221)
index <- createDataPartition(data2$salary_binary, p = 0.7, list = FALSE)
training_data <- data2[index, ]
testing_data <- data2[-index, ]
anyNA(data2)
summary(data2)
```

### Train SVM Model
```R
# Train SVM model
training_data[["salary_binary"]] = factor(training_data[["salary_binary"]])
trlctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 3)

svm_linear <- train(salary_binary ~ ., data = training_data, method = "svmLinear",
                   trControl = trlctrl,
                   preProcess = c("centre", "scale"),
                   tuneLength = 10)
```

## Results and Evaluation
- Evaluate the model using the testing dataset.
- Check metrics such as accuracy, precision, recall, and F1-score to determine the model's performance

---

