library(tidyverse)
library(directlabels)

deaths <- read_csv("full_data.csv", col_names = TRUE)

deaths %>%
  filter(!is.na(intent)) %>%
  group_by(intent, sex) %>%
  mutate(count = n()) %>%
  ggplot(aes(x = intent, 
             group = sex)) +
    geom_bar() +
    labs(title = "Intent Behind US Gun Deaths",
       y = "# of deaths",
       x = "Intent") +
    theme_bw()

ggsave("intent_basic.png", width = 8)

sex_vals <- list("M" = "Male", "F" = "Female")

sex_labeller <- function(variable, value) {
  return(sex_vals[value])
}

deaths %>%
  mutate(count_var = race,
         month_abb = month.abb[deaths$month]) %>%
  group_by(count_var, month_abb) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = month_abb, y = count,
             color = count_var,
             group = count_var)) +
    geom_point() +
    geom_line() +
    scale_x_discrete(labels = month.abb) +
  scale_y_continuous(breaks = seq(0,6000, by = 1000)) +
    labs(title = "US Gun Deaths by Race",
         y = "# of Deaths",
         x = "Month",
         color = "Race") +
    theme_bw()

ggsave("deaths-by-race.png", width = 10)

deaths %>%
  mutate(count_var = intent,
         month_abb = month.abb[deaths$month]) %>%
  filter(!is.na(intent)) %>%
  group_by(count_var, month_abb) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = month_abb, y = count,
             color = count_var,
             group = count_var)) +
  geom_point() +
  geom_line() +
  scale_x_discrete(labels = month.abb) +
  scale_y_continuous(breaks = seq(0,6000, by = 1000)) +
  labs(title = "US Gun Deaths by Intent",
       y = "# of Deaths",
       x = "Month",
       color = "Intent") +
  theme_bw()

ggsave("deaths-by-intent.png", width = 8)

  