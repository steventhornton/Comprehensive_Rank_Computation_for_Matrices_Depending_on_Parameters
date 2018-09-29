library(dplyr)
library(ggplot2)

theme_set(theme_light())

df <- read.csv("results.csv")

df %>%
  mutate(time_ratio = time_A/time_A_transpose) %>%
  group_by(num_rows, num_cols, num_param) %>%
  summarise(time_ratio = mean(time_ratio)) %>%
  ggplot(aes(x = num_rows, y = num_cols, fill = time_ratio)) +
  geom_tile() +
  scale_fill_distiller(palette = "Spectral", limits = c(1, 5.5), name="Time Ratio") +
  xlab("n") +
  ylab("m") +
  coord_fixed()
ggsave("Transpose.eps", device = "eps", width = 12, height = 12, units="cm")
