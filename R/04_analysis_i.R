# Clear workspace ---------------------------------------------------------
rm(list = ls())


# Load libraries ----------------------------------------------------------
library("tidyverse")
library("broom")


# Define functions --------------------------------------------------------
#source(file = "R/99_project_functions.R")


# Load data ---------------------------------------------------------------
my_data_clean_aug <- read_tsv(file = "data/03_my_data_clean_aug.tsv")


# Wrangle data ------------------------------------------------------------
set.seed(273849)
gravier_data_long_nested <- my_data_clean_aug %>%
  pivot_longer(!value, names_to = "gene", values_to = "log2_expr_level") %>%
  group_by(gene) %>%
  nest() %>%
  ungroup() %>%
  sample_n(100) %>%
  mutate(mdl = map(data, ~ glm(value ~ log2_expr_level, 
                               data = .x,
                               family = binomial(link = "logit")))) %>%
  mutate(mdl_tidy = map(mdl, ~tidy(.x, conf.int = TRUE))) %>%
  unnest(mdl_tidy) %>%
  filter(str_detect(term, "log2")) %>%
  mutate(identified_as = case_when(p.value < 0.05 ~ "Significant",
                                   TRUE ~ "Non-significant")) %>%
  mutate(neg_log10_p = -log10(p.value))

gravier_data_wide = my_data_clean_aug %>%
  select(value, pull(gravier_data_long_nested, gene))

# Visualise data ----------------------------------------------------------

pca = gravier_data_wide %>%
  select(!value) %>%
  prcomp(scale = TRUE)

pca %>%
  augment(gravier_data_wide) %>%
  mutate(value = factor(value)) %>%
  ggplot(aes(x = .fittedPC1,
             y = .fittedPC2,
             color = value)) + 
  geom_point(size = 2) + 
  theme_classic(base_family = "Avenir", base_size = 10) 
  theme(legend.position = "bottom")





# Write data --------------------------------------------------------------

write_tsv(x = gravier_data_wide,
            path = "data/04_gravier_data_wide.tsv")

ggsave(filename = "results/04_PCA_plot.png", width = 16, height = 9, dpi = 72)
