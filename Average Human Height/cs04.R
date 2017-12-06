library(tidyverse)
library(haven)
library(readxl)
library(downloader)
library(foreign)

download("https://byuistats.github.io/M335/data/heights/Height.xlsx", "heightXLSX.xlsx")

heightX <- read_excel("heightXLSX.xlsx", skip = 2)

heightX <- heightX %>%
  gather(key = "year", value = "height.cm", `1800`:`2011`) %>%
  separate(year, c("century", "decade"), sep = 2, remove = FALSE) %>%
  mutate(century = parse_number(century) + 1, 
         decade = parse_number(decade) %/% 10)

saveRDS(heightX, "worldwide_height.rds")

height1 <- read_dta("https://byuistats.github.io/M335/data/heights/germanconscr.dta")
height2 <- read_dta("https://byuistats.github.io/M335/data/heights/germanprison.dta")
height3 <- read.dbf("B6090.DBF")
height4 <- read_csv("https://github.com/hadley/r4ds/raw/master/data/heights.csv")
height5 <- read_sav("http://www.ssc.wisc.edu/nsfh/wave3/NSFH3%20Apr%202005%20release/main05022005.sav")

height1 <- height1 %>%
  mutate(birth_year = bdec,
         height.in = height / 2.54,
         height.cm = height,
         studyid = "GCON") %>%
  select(birth_year, height.in, height.cm, studyid)

height2 <- height2 %>%
  mutate(birth_year = bdec,
         height.in = height / 2.54,
         height.cm = height,
         studyid = "BCON") %>%
  select(birth_year, height.in, height.cm, studyid)

height3 <- height3 %>%
  mutate(birth_year = GEBJ,
         height.in = CMETER / 2.54,
         height.cm = CMETER,
         studyid = "GSOL") %>%
  select(birth_year, height.in, height.cm, studyid)

height4 <- height4 %>%
  mutate(birth_year = 1950,
         height.in = height,
         height.cm = height * 2.54,
         studyid = "WAGE") %>%
  select(birth_year, height.in, height.cm, studyid)

height5 <- height5 %>%
  mutate(birth_year = parse_number(paste("19",DOBY, sep="")),
         height.in = RT216F * 12 + RT216I,
         height.cm = height.in * 2.54,
         studyid = "NS") %>%
  select(birth_year, height.in, height.cm, studyid)

all_heights <- bind_rows(height1,
                         height2,
                         height3,
                         height4,
                         height5)

saveRDS(all_heights, "all_height_data.rds")

heightX %>%
  ggplot(aes(x = year, y = height.cm)) +
  geom_point() +
  geom_point(data = filter(heightX, Code == 276), color = "red") +
  scale_x_discrete(breaks = seq(1800, 2000, by = 10)) +
  labs(title = "Worldwide Height Estimates",
       y = "Height (cm)",
       x= "Year of Birth") +
  annotate("text", x = 190, y = 181, label = "Germany", color = "red") +
  theme_bw()

ggsave("worldwide_height.png", width = 10)

all_heights %>%
  filter(birth_year > 1700,
         height.cm > 155,
         height.cm < 272) %>%
  separate(birth_year, c("century", "decade"), sep = 2, remove = FALSE) %>%
  mutate(century = paste(parse_number(century) + 1, "th Century", sep = "")) %>%
  group_by(century, birth_year) %>%
  summarize(mean = mean(height.cm)) %>%
  ggplot(aes(x = birth_year, y = mean)) +
  facet_grid(. ~ century, scales = "free_x") +
  geom_point() +
  geom_smooth() +
  labs(title = "Average Height by Century",
       y = "Height (cm)",
       x = "Year of Birth") +
  theme_bw()

ggsave("average_height_century.png", width = 10)
