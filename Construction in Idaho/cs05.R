library(tidyverse)
library(stringr)
library(forcats)

joined_data <- buildings::buildings0809 %>%
  left_join(buildings::climate_zone_fips, by = c("FIPS.county", 
                                                 "FIPS.state"))

not_restaurants <- c("development","Food preperation center", "Food Services center","bakery","Grocery","conceession","Cafeteria", "lunchroom","school","facility"," hall ")
standalone_retail <- c("Wine","Spirits","Liquor","Convenience","drugstore","Flying J", "Rite Aid ","walgreens ","Love's Travel ")
full_service_type <- c("Ristorante","mexican","pizza ","steakhouse"," grill ","buffet","tavern"," bar ","waffle","italian","steak house")
quick_service_type <- c("coffee"," java "," Donut ","Doughnut"," burger ","Ice Cream ","custard ","sandwich ","fast food "," bagel ")
quick_service_names <- buildings::restaurants$Restaurant[buildings::restaurants$Type %in% c("coffee","Ice Cream","Fast Food")]
full_service_names <- buildings::restaurants$Restaurant[buildings::restaurants$Type %in% c("Pizza","Casual Dining","Fast Casual")]

subgrouped <- joined_data %>%
  filter(Type == "Food_Beverage_Service") %>%
  mutate(ProjectTitle = str_trim(str_to_lower(ProjectTitle))) %>%
  mutate(subgroup = case_when(
    str_detect(ProjectTitle, 
               str_c(str_trim(str_to_lower(not_restaurants)),
               collapse = "|")) ~ "not_restaurant",
    str_detect(ProjectTitle, 
               str_c(str_trim(str_to_lower(standalone_retail)),
               collapse = "|")) ~ "standalone_retail",
    str_detect(ProjectTitle, 
               str_c(str_trim(str_to_lower(full_service_type)), 
               collapse = "|")) ~ "Full Service Restaurant",
    str_detect(ProjectTitle,
               str_c(str_trim(str_to_lower(full_service_names)), 
               collapse = "|")) ~ "Full Service Restaurant",
    str_detect(ProjectTitle, 
               str_c(str_trim(str_to_lower(quick_service_type)), 
               collapse = "|")) ~ "Quick Service Restaurant",
    str_detect(ProjectTitle, 
               str_c(str_trim(str_to_lower(quick_service_names)), 
               collapse = "|")) ~ "Quick Service Restaurant"
  )) %>%
  mutate(subgroup = if_else(is.na(subgroup), 
                            if_else(SqFt >= 4000, "Full Service Restaurant", "Quick Service Restaurant"), 
                            subgroup)) %>%
  mutate(build_type = case_when(
    str_detect(ProjectTitle, "alteration") ~ "Alteration",
    str_detect(ProjectTitle, "addition") ~ "Addition",
    str_detect(ProjectTitle, "renov") ~ "Alteration",
    !(str_detect(ProjectTitle, paste(c("alteration", "addition"), collapse = "|"))) ~ "New"
    ))

subgrouped %>%
  filter(subgroup %in% c("Full Service Restaurant", "Quick Service Restaurant")) %>%
  group_by(subgroup, County.x, Year) %>%
  mutate(count = n()) %>%
  ggplot(aes(x = (County.x %>% fct_infreq()), y = count, fill = subgroup)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_grid(. ~ Year) +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Full-Service vs Quick Service by County and Year",
       x = "County",
       y = "Number of Projects") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 55, vjust = 1, hjust=1))

joined_data %>%
  mutate(cType = ifelse(Type == "Food_Beverage_Service", "Restaurant", "Other Commercial")) %>%
  group_by(cType, Year) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = Year, y = count, fill = cType)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Restaurant vs Other Commerical Construction",
       y = "Number of Construction Projects",
       fill = "Project Type") +
  theme_bw()

joined_data %>%
  filter(County.x == "ADA, ID") %>%
  mutate(cType = ifelse(Type == "Food_Beverage_Service", "Restaurant", "Other Commercial")) %>%
  group_by(cType, Year) %>%
  summarise(count = n()) %>%
  ggplot(aes(x = Year, y = count, fill = cType)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Ada County Restaurant vs Other Commerical Construction",
       y = "Number of Construction Projects",
       fill = "Project Type") +
  theme_bw()
