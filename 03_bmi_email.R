# 0. 환경설정 ---------------------------------------
library(tidyverse)
library(glue)
library(blastula)

fs::dir_create("03_email")

# 1. 전자우편 만들기 ---------------------------------------

bmi_email <- render_email('03_bmi_email.Rmd')

bmi_email

bmi_email %>%
  smtp_send(
    to = "steve.jobs@gmail.com",
    from = "victor@r2bit.com",
    subject = "한국 R 컨퍼런스 후원 테스트",
    credentials = creds_key("rconf")
  )


