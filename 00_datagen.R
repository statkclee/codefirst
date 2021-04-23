library(tidyverse)
library(timetk)

set.seed(20210422)

d_dates <- seq(as.Date('2018/01/01'), as.Date(Sys.Date()), by="day")

d_models <- c(rep("A", 5), rep("S", 3), rep("X", 2))

d_regions <- c("North America", "Latin America", "EMEA", "APAC")

sales <- tibble(
  date = sample(d_dates, 7000, replace = TRUE),
  model = sample(d_models, 7000, replace = TRUE),
  shipping = round(runif(7000, 25, 150), 2),
  region = sample(d_regions, 7000, replace = TRUE),
) %>% 
  mutate(price = case_when(model == "A" ~ 699,
                           model == "S" ~ 999,
                           model == "X" ~ 2499),
         cost = case_when(model == "A" ~ 543,
                          model == "S" ~ 804,
                          model == "X" ~ 2238),
         returning = case_when(model == "A" ~ sample(c(rep("yes", 1), rep("no", 20)), 7000, replace = TRUE),
                               model == "S" ~ sample(c(rep("yes", 1), rep("no", 2)), 7000, replace = TRUE),
                               model == "X" ~ sample(c(rep("yes", 3), rep("no", 1)), 7000, replace = TRUE))) %>% 
  arrange(date) %>% 
  mutate(id = row_number()) %>% 
  select(id, date, model, price, cost, shipping, region, returning)

write.csv(sales, "sales.csv", row.names = FALSE)