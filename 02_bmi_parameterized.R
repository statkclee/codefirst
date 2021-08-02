# 0. 환경설정 ---------------------------------------
library(tidyverse)
library(glue)

fs::dir_create("02_parameterized")

# 1. 성별 ---------------------------------------
genders <- c("Male", "Female")

# 2. 남녀별 보고서 만들기 ---------------------------------------
for(gender in genders) {
  rmarkdown::render("02_bmi_parameterized.Rmd", 
                    output_format="html_document",
                    params = list(gender = gender),
                    output_file = glue::glue("02_bmi_parameterized_{gender}.html"),
                    encoding = 'UTF-8', 
                    output_dir = "02_parameterized")
}
