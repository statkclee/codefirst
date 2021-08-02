# 0. 팩키지 ------------
library(tidyverse)

# 1. 데이터 -----------
## 데이터 소스: https://www.kaggle.com/yersever/500-person-gender-height-weight-bodymassindex

bmi_dat <- read_csv("https://raw.githubusercontent.com/statkclee/author_carpentry_kr/gh-pages/data/500_Person_Gender_Height_Weight_Index.csv")

fs::dir_create("data")

bmi_dat %>% 
  write_csv("data/bmi_dat.csv")

