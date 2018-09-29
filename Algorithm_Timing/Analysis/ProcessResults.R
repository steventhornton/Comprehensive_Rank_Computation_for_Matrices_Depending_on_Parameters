library(dplyr)
library(ggplot2)
library(data.table)

theme_set(theme_light())

# Load descriptive data
df.descriptive <- read.csv("../../corpus-of-parametric-linear-systems/Maple/Descriptive.csv")

# Load all results data
results.algorithm.files <- list.files(path="../Algorithm/Results/", pattern="Results_corp_*", full.names=T, recursive=FALSE)
results.naive.files <- list.files(path="../Naive_Algorithm/Results/", pattern="Results_corp_*", full.names=T, recursive=FALSE)

corp_num_range <- 1:540

# Load results for improved implementation
df.fast <- lapply(results.algorithm.files, read.csv) %>%
  rbindlist() %>%
  select(c("corp_num", "iteration_num", "time_cpu", "time_real"))
df.fast <- CJ(corp_num = corp_num_range,
              iteration_num = 1:max(df.fast$iteration_num)) %>%
  merge(df.fast, by=c("corp_num", "iteration_num"), all.x=T, all.y=T)
df.fast[is.na(time_cpu), time_cpu := Inf]
df.fast[is.na(time_real), time_real := Inf]
df.fast[,time_cpu := pmin(time_cpu, 600)]
df.fast[,time_real := pmin(time_real, 600)]

# Load results for slow implementation
df.slow <- lapply(results.naive.files, read.csv) %>%
  rbindlist() %>%
  select(c("corp_num", "iteration_num", "time_cpu", "time_real"))
df.slow <- CJ(corp_num = corp_num_range,
              iteration_num = 1:max(df.slow$iteration_num)) %>%
  merge(df.slow, by=c("corp_num", "iteration_num"), all.x=T, all.y=T)
df.slow[is.na(time_cpu), time_cpu := Inf]
df.slow[is.na(time_real), time_real := Inf]
df.slow[,time_cpu := pmin(time_cpu, 600)]
df.slow[,time_real := pmin(time_real, 600)]

### Analysis
df.fast.summary <- df.fast %>%
  group_by(corp_num) %>%
  summarise(min.time.real = min(time_real)) %>%
  arrange(corp_num) %>%
  rename(fast.time = min.time.real)

df.slow.summary <- df.slow %>%
  group_by(corp_num) %>%
  summarise(min.time.real = min(time_real)) %>%
  arrange(corp_num) %>%
  rename(slow.time = min.time.real)

df.summary <- merge(df.fast.summary,
                    df.slow.summary,
                    by="corp_num",
                    all.x = T, all.y = T) %>%
  arrange(corp_num) %>%
  merge(df.descriptive, by="corp_num", all.x=T, all.y=T)

rm(df.descriptive,
   df.fast,
   df.slow,
   df.fast.summary,
   df.slow.summary,
   results.algorithm.files,
   results.naive.files,
   corp_num_range)

# How many examples contain > 0 parameters
# 495
df.summary %>%
  filter(number_of_parameters > 0) %>%
  nrow()

# How many of the examples timed out for both implementations
# 120
df.summary %>%
  filter(fast.time == 600 & slow.time == 600) %>%
  nrow()

# How many of the examples didn't time out for both implementations
# and have > 0 parameters
# 375
df.summary %>%
  filter(number_of_parameters > 0) %>%
  filter(!(fast.time == 600 & slow.time == 600)) %>%
  nrow()

# Our of the examples that didn't time out for both implementations,
# and had parameters, how many did the fast implementation beat the
# naive implementation?
# 372/375
df.summary %>%
  filter(!(fast.time == 600 & slow.time == 600)) %>%
  filter(number_of_parameters > 0) %>%
  summarise(fast.beat.naive = sum(fast.time < slow.time),
            total.example = n())

# Of the examples that timed out for the slow implementation,
# how many of the examples was the fast implementation able to
# complete
# 3
df.summary %>%
  filter(slow.time == 600) %>%
  filter(fast.time < 600) %>%
  nrow()

# Of the examples that timed out for the fast implementation,
# how many of the examples was the slow implementation able to
# complete
# 0
df.summary %>%
  filter(fast.time == 600) %>%
  filter(slow.time < 600) %>%
  nrow()

# Execution time by dimension
p1 <- df.summary %>%
  filter(number_of_parameters > 0) %>%
  select(c("matrix_dimension", "fast.time", "slow.time")) %>%
  filter(fast.time < 600) %>%
  filter(slow.time < 600) %>%
  reshape2::melt(id="matrix_dimension") %>%
  mutate(matrix_dimension = as.factor(matrix_dimension)) %>%
  mutate(variable = case_when(variable == "fast.time" ~ "Our Algorithm     ",
                              variable == "slow.time" ~ "Naive Algorithm")) %>%
  mutate(variable = factor(variable, levels = c("Our Algorithm     ", "Naive Algorithm"))) %>%
  ggplot(aes(x=matrix_dimension, y=value, color=variable)) +
  geom_boxplot(outlier.size = 0.3) +
  scale_y_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000),
                labels = c("0.01", "0.1", "1", "10", "100", "1000"),
                limits = c(0.01, 1000)) +
  scale_color_manual(values = c("#2c7db5", "#d03845")) +
  theme(legend.title=element_blank()) +
  xlab("Matrix Dimension") +
  ylab("Execution Time (s)") +
  theme(legend.position="bottom")
# ggsave("Time_vs_dimension.eps", device = "eps", width = 16, height = 12, units = "cm")

# Execution time by number of parameters
p2 <- df.summary %>%
  filter(number_of_parameters > 0) %>%
  select(c("number_of_parameters", "fast.time", "slow.time")) %>%
  filter(fast.time < 600) %>%
  filter(slow.time < 600) %>%
  reshape2::melt(id="number_of_parameters") %>%
  mutate(number_of_parameters = as.factor(number_of_parameters)) %>%
  mutate(variable = case_when(variable == "fast.time" ~ "Our Algorithm",
                              variable == "slow.time" ~ "Naive Algorithm")) %>%
  mutate(variable = factor(variable, levels = c("Our Algorithm", "Naive Algorithm"))) %>%
  ggplot(aes(x=number_of_parameters, y=value, color=variable)) +
  geom_boxplot(outlier.size = 0.3) +
  scale_y_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000),
                labels = c("0.01", "0.1", "1", "10", "100", "1000"),
                limits = c(0.01, 1000)) +
  scale_color_manual(values = c("#2c7db5", "#d03845")) +
  theme(legend.title=element_blank()) +
  xlab("Number of Parameters") +
  ylab("Execution Time (s)")
# ggsave("Time_vs_number_of_parameters.eps", device = "eps", width = 16, height = 12, units = "cm")

# Execution time by max total degree
p3 <- df.summary %>%
  filter(number_of_parameters > 0) %>%
  select(c("maximum_total_degree", "fast.time", "slow.time")) %>%
  filter(fast.time < 600) %>%
  filter(slow.time < 600) %>%
  reshape2::melt(id="maximum_total_degree") %>%
  mutate(maximum_total_degree = as.factor(maximum_total_degree)) %>%
  mutate(variable = case_when(variable == "fast.time" ~ "Our Algorithm",
                              variable == "slow.time" ~ "Naive Algorithm")) %>%
  mutate(variable = factor(variable, levels = c("Our Algorithm", "Naive Algorithm"))) %>%
  ggplot(aes(x=maximum_total_degree, y=value, color=variable)) +
  geom_boxplot(outlier.size = 0.3) +
  scale_y_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000),
                labels = c("0.01", "0.1", "1", "10", "100", "1000"),
                limits = c(0.01, 1000)) +
  scale_color_manual(values = c("#2c7db5", "#d03845")) +
  theme(legend.title=element_blank()) +
  xlab("Max Total Degree") +
  ylab("Execution Time (s)")
# ggsave("Time_vs_total_degree.eps", device = "eps", width = 16, height = 12, units = "cm")

# Execution time by number of symbolic entries
p4 <- df.summary %>%
  filter(number_of_parameters > 0) %>%
  select(c("number_of_symbolic_entries", "fast.time", "slow.time")) %>%
  filter(fast.time < 600) %>%
  filter(slow.time < 600) %>%
  reshape2::melt(id="number_of_symbolic_entries") %>%
  mutate(number_of_symbolic_entries = as.factor(number_of_symbolic_entries)) %>%
  mutate(variable = case_when(variable == "fast.time" ~ "Our Algorithm",
                              variable == "slow.time" ~ "Naive Algorithm")) %>%
  mutate(variable = factor(variable, levels = c("Our Algorithm", "Naive Algorithm"))) %>%
  ggplot(aes(x=number_of_symbolic_entries, y=value, color=variable)) +
  geom_boxplot(outlier.size = 0.3) +
  scale_y_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000),
                labels = c("0.01", "0.1", "1", "10", "100", "1000"),
                limits = c(0.01, 1000)) +
  scale_color_manual(values = c("#2c7db5", "#d03845")) +
  theme(legend.title=element_blank()) +
  xlab("Number of Symbolic Entries") +
  ylab("Execution Time (s)")
# ggsave("Time_vs_max_number_of_terms.eps", device = "eps", width = 16, height = 12, units = "cm")

# Execution time by number of zero entries
p5 <- df.summary %>%
  filter(number_of_parameters > 0) %>%
  select(c("number_of_zero_entries", "fast.time", "slow.time")) %>%
  filter(fast.time < 600) %>%
  filter(slow.time < 600) %>%
  reshape2::melt(id="number_of_zero_entries") %>%
  mutate(number_of_zero_entries = as.factor(number_of_zero_entries)) %>%
  mutate(variable = case_when(variable == "fast.time" ~ "Our Algorithm",
                              variable == "slow.time" ~ "Naive Algorithm")) %>%
  mutate(variable = factor(variable, levels = c("Our Algorithm", "Naive Algorithm"))) %>%
  ggplot(aes(x=number_of_zero_entries, y=value, color=variable)) +
  geom_boxplot(outlier.size = 0.3) +
  scale_y_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000),
                labels = c("0.01", "0.1", "1", "10", "100", "1000"),
                limits = c(0.01, 1000)) +
  scale_color_manual(values = c("#2c7db5", "#d03845")) +
  theme(legend.title=element_blank()) +
  xlab("Number of Zero Entries") +
  ylab("Execution Time (s)")

# Execution time by maximum number of terms
p6 <- df.summary %>%
  filter(number_of_parameters > 0) %>%
  select(c("maximum_number_of_terms", "fast.time", "slow.time")) %>%
  filter(fast.time < 600) %>%
  filter(slow.time < 600) %>%
  reshape2::melt(id="maximum_number_of_terms") %>%
  mutate(maximum_number_of_terms = as.factor(maximum_number_of_terms)) %>%
  mutate(variable = case_when(variable == "fast.time" ~ "Our Algorithm",
                              variable == "slow.time" ~ "Naive Algorithm")) %>%
  mutate(variable = factor(variable, levels = c("Our Algorithm", "Naive Algorithm"))) %>%
  ggplot(aes(x=maximum_number_of_terms, y=value, color=variable)) +
  geom_boxplot(outlier.size = 0.3) +
  scale_y_log10(breaks = c(0.01, 0.1, 1, 10, 100, 1000),
                labels = c("0.01", "0.1", "1", "10", "100", "1000"),
                limits = c(0.01, 1000)) +
  scale_color_manual(values = c("#2c7db5", "#d03845")) +
  theme(legend.title=element_blank()) +
  xlab("Maximum Number of Terms") +
  ylab("Execution Time (s)")


#extract legend
#https://github.com/hadley/ggplot2/wiki/Share-a-legend-between-two-ggplot2-graphs
g_legend <- function(a.gplot){
  tmp <- ggplot_gtable(ggplot_build(a.gplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)}

mylegend <- g_legend(p1)

library(gridExtra)

setEPS(width = 12,
       height = 8)
postscript("Improved_vs_Naive.eps")
grid.arrange(arrangeGrob(p1 + theme(legend.position="none"),
                         p2 + theme(legend.position="none"),
                         p3 + theme(legend.position="none"),
                         p4 + theme(legend.position="none"),
                         nrow=2,
                         ncol=2),
             mylegend, nrow=2, heights=c(10, 1))
dev.off()
