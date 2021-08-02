# 0. 환경설정 ---------------------------------------
library(tidyverse)
library(glue)

fs::dir_create("01_rmarkdown")

# 1. 보고서 만들기 ---------------------------------------
## 1.1. HTML 보고서 ---------------------------------------
rmarkdown::render("01_bmi_rmarkdown_html.Rmd", 
                  output_format="html_document",
                  output_file = glue::glue("01_bmi_rmarkdown.html"),
                  encoding = 'UTF-8', 
                  output_dir = "01_rmarkdown")

## 1.2. PDF 보고서 ---------------------------------------
rmarkdown::render("01_bmi_rmarkdown_pdf.Rmd", 
                  output_format="pdf_document",
                  output_file = glue::glue("01_bmi_rmarkdown.pdf"),
                  encoding = 'UTF-8', 
                  output_dir = "01_rmarkdown")

## 1.3. 워드 보고서 ---------------------------------------
rmarkdown::render("01_bmi_rmarkdown_word.Rmd", 
                  output_format="word_document",
                  output_file = glue::glue("01_bmi_rmarkdown.docx"),
                  encoding = 'UTF-8', 
                  output_dir = "01_rmarkdown")
