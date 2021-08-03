# 0. 팩키지 ---------------
library(tidyverse)
library(caret)
library(doSNOW)

# 1. 데이터 ---------------

bmi_dat <- read_csv("https://raw.githubusercontent.com/statkclee/author_carpentry_kr/gh-pages/data/500_Person_Gender_Height_Weight_Index.csv")

bmi_df <- bmi_dat %>% 
  mutate(Index = factor(Index, levels = c(0,1,2,3,4,5), labels = c("극저체중", "저체중", "정상", "과체중", "비만", "고도비만")),
         Gender = factor(Gender, levels = c("Male", "Female")))


# 2. 데이터 전처리 ------
set.seed(777)

# 3. 예측모형 ------
## 3.1. 병렬처리 환경설정
num_cores <- parallel:::detectCores()

cl <- makeCluster(num_cores, type = "SOCK")
registerDoSNOW(cl)

## 3.2. 훈련 vs 검증/시험
train_test_index <- createDataPartition(bmi_df$Index, p = 0.7, list = FALSE)

train <- bmi_df[train_test_index, ]
test <- bmi_df[-train_test_index, ]

## 3.3. 모형 개발/검증 데이터셋 준비 ------
cv_folds <- createMultiFolds(train$Index, k = 10, times = 5)
cv_ctrl <- trainControl(method = "cv", number = 10,
                        index = cv_folds, 
                        verboseIter = TRUE,
                        classProbs=TRUE,
                        savePredictions=TRUE)
## 3.2. 예측모형 적용
### ranger
gc_ranger_model <- train(Index ~., train,
                         method = "ranger",
                         tuneLength = 7,
                         trControl = cv_ctrl)

gc_pred_class <- predict(gc_ranger_model, newdata = test, type="raw")

stopCluster(cl)

# 4. 예측모형 내보내기 ---------------
gc_ranger_model %>% 
  write_rds(glue::glue("{here::here()}/app_shiny/gc_ranger_model.rds"))


# 5. 예측모형 사용 ---------------

bmi_test_dat <- tribble(
  ~"Gender", ~"Height", ~"Weight",
  "Male", 149, 61,
  "Female",  172, 67
)

gc_ranger_model <- 
  read_rds("app_shiny/gc_ranger_model.rds")

predict(gc_ranger_model, newdata = bmi_test_dat, type="raw")

