library(tidyverse)

# 7.2 Questions
# There are no set rules for EDA, but there are some that are more useful: 

#1. What type of variation occurs within the variables?
#2. What type of covariation occurs between variables? 

# Variable: quantity, quality or property that can be measured

# Value: state of a variable when measured (may change)

# Observation: set of measurements made under similar conditions, contains several values
# each associated with a different variable 

# Tabular data: set of values, each associated with a variable and an observation
# (data is tidy, if each value in its own cell - most is not)

# 7.3 Variation 
# Tendency of values of a variable to change from measurement to measurement 

# 7.3.1 Visualising distributions 
# Categorical variable: takes only one of possible discrete values (consider using a bar chart)

ggplot(diamonds) +
  geom_bar(aes(x = cut))

# Plot cut of diamonds, only has 5 possible values 
# Height of bars displays number of observations for particular x value
# Can compute values manually with dplyr::count()

diamonds %>% 
  count(cut)

# Continuous variable: takes one of an infinite set of values (consider using a histogram)

ggplot(diamonds) +
  geom_histogram(aes(x = carat), binwidth = 0.5)

# Plot carat value of diamonds, can take any numerical value 
# Width of each bin is 0.5 carats (histogram divides x-axis into equally spaced bins)
# Explore variety of binwidths 
# Can compute values manually with dplyr::count and ggplot::cut_width()

diamonds %>%
  count(cut_width(carat, 0.5))

smaller <- diamonds %>%
  filter(carat < 3)
ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.1)

# Take only diamonds smaller than 3 carats, plots histogram with smaller binwidth of 0.1

# Use geom_freqploy() to overlay multiple histograms - uses lines for polygons

ggplot(smaller, aes(x = carat, colour = cut)) +
  geom_freqpoly(binwidth = 0.1)

# 7.3.2 Typical values 
# Which values are the most common? Why?
# Which values are rare? Why?
# Are there any unusual patterns? What might explain these?

ggplot(smaller, aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

# Why are there more diamonds at whole carats and common fractions than otherwise?
# Why are there more diamonds slightly to the right of each peak than to the left?
# Why are there no diamonds bigger 3 carats?

# Clusters of similar values suggest that subgroups exist:
# How are observations within each cluster similar to each other?
# How are observations in separate clusters similar to each other?
# Why might existence of clusters be misleading? 

# 7.3.3 Unusual values
# Outliers are data points that don't seem to fit the pattern
# Some may be data entry errors, some may be significant
# Where there is a lot of data, may be difficult to see outliers

ggplot(diamonds) +
  geom_histogram(aes(x = y), binwidth = 0.5)
# Histogram extends out to 60 on x-axis, but there appears to be no values
# There are too many values in the common bins - rare bins are short 
# Need to zoom in on parts of the x-axis - use coord_cartesian()

ggplot(diamonds) + 
  geom_histogram(aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0, 50))
# Unusual values ~0, ~30 and ~60 - select these with dplyr

unusual <- diamonds %>%
  filter(y < 3 | y > 20) %>%
  select(price, x, y, z) %>%
  arrange(y)
unusual
# Some entries have a y dimension of 0 mm - incorrect values 
# Some entries have a y dimension of 31.8 mm and 58.9 mm, yet do not cost much (?)
# These are probably all incorrect values

# 7.3.4 Exercises
#1. Explore distribution of x, y and z in diamomnds.

# Plot each dimension as a histogram:
ggplot(diamonds, aes(x)) +
  geom_histogram()

ggplot(diamonds, aes(y)) +
  geom_histogram()

ggplot(diamonds, aes(z)) +
  geom_histogram()

# But this only allows for a single variable to be considered

# Alternatively, reshape dataset so that variables can be used as facets:
  diamonds %>%
  mutate(id = row_number()) %>%
  select(x, y, z, id) %>%
  gather(variable, value, -id) %>%
  ggplot(aes(x = value)) +
  geom_density() +
  geom_rug() +
  facet_grid(variable ~ .)

# gather(data, key = "key", value = "value", ...)
# gather() takes multiple columns and collapses into key-value pairs
# Use gather() when there are columns that are not variables 

# Each is right-skewed - most diamonds are small, few large
# There is an outlier in each (see rug!)
# All three distributions have a bimodality (is there a threshold?)

#2. Explore distribution of price - consider binwidth, try range of values
ggplot(diamonds, aes(price)) +
  geom_histogram(binwidth = 10, center = 0)

# Limit to price < 2500
ggplot(filter(diamonds, price < 2500), aes(price)) +
  geom_histogram(binwidth = 10, center = 0)

# No diamonds at $1500
# Slight spike just before $5000

#3. How many diamonds are 0.99 carat? How many are 1 carat? Why? 
diamonds %>%
  filter(carat >= 0.99, carat <= 1) %>%
  count(carat)

# There are approximately 70 times more 1 carat diamonds than 0.99 carat diamonds
# Rounding? 1 carat diamonds may be more desirable. 
# Consider the number of diamonds in each carat range - is there an abnormally low number 
# of 0.99 carat diamonds and an abnormally high number of 1 carat diamonds? 

diamonds %>%
  filter(carat >= 0.9, carat <= 1.1) %>%
  count(carat) %>%
  print(n = 30)

#4. Compare and contrast coord_cartesian() and xlim() or ylim() when zooming in on a
# histogram. What happens if binwidth is not set? 

# coord_cartesian() zooms in on area specified - calculation of histogram unaffected
# xlim() and ylim() drop anything outside of the limits, then calculates histogram

ggplot(diamonds) +
  geom_histogram(aes(x = price)) + 
  coord_cartesian(xlim = c(100, 5000), ylim = c(0, 3000))

ggplot(diamonds) +
  geom_histogram(aes(x = price)) +
  xlim(100, 5000) +
  ylim(0, 3000)


# 7.4 Missing values 
# Where there are unusual values: drop entire row with unusual values or replace values with
# missing values

# Replace unusual values by using mutate() to replace with a modified copy
# Use ifelse() function to replace unusual values with NA

diamonds2 <- diamonds %>%
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

# ifelse(test, yes, no)

ggplot(diamonds2, aes(x = x, y = y)) +
  geom_point()
# returns warning that missing values removed, suppress by setting na.rm = TRUE

ggplot(diamonds2, aes(x = x, y = y)) +
  geom_point(na.rm = TRUE)

# To understand what makes observations with missing values different to observations with
# recorded values:

# In flights, missing values in dep_time indicate that flight was cancelled - compare
# departure time for cancelled and non-cancelled flights.
# Create new variable with is.na()

nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(aes(sched_dep_time)) +
    geom_freqpoly(aes(colour = cancelled), binwidth = 1/4)

# Plot not ideal as there are many more non-cancelled flights than cancelled flights.

# 7.4.1 Exercises
#1. What happens to missing values in a histogram? Bar chart? 
# In a histogram, missing values are removed, warning showed

ggplot(diamonds2, aes(x = y)) +
  geom_histogram()

# In a bar chart, NA values treated as separate category. x aesthetic in geom_bar should
# be discrete (categorical) variable, missing values are another category.

diamonds %>% 
  mutate(cut = if_else(runif(n()) < 0.1, NA_character_, as.character(cut))) %>%
  ggplot() +
  geom_bar(aes(x = cut))

# In a histogram, x aesthetic variable needs to be numeric, stat_bin groups observations
# by ranges into bins. Since NA has no numeric value, they cannot be placed in a bin and
# are dropped.

#2. What does na.rm = TRUE do in mean() and sum()?
# Removes NA values from vector prior to calculating mean and sum

mean(c(0, 1, 2, NA), na.rm = TRUE)
# mean is 1

sum(c(0, 1, 2, NA), na.rm = TRUE)
# sum is 3

# 7.5 Covariation
# Variation describes behaviour within a variable.

# Covariation describes behaviour bewteen variables, i.e. tendency of two or more
# variables to vary together in a related way. 
# Visualise the relationship between two or more variables 

# 7.5.1 Categorical and continuous variable 
# Explore distribution of a continuous variable broken down by a categorical variable.
# Default appearance of geom_freqpoly() not that useful as comparison because height
# is given by count - if one group much smaller, hard to see difference in shape.

# Consider how price of diamond varies with quality. 
ggplot(diamonds, aes(x = price)) +
  geom_freqpoly(aes(colour = cut), binwidth = 500)

# Hard to see the difference since counts differ so much.

ggplot(diamonds) +
  geom_bar(aes(x = cut))
# Displays count - but hard to compare

# Display density (standardised count, area under polygon is 1) 

ggplot(diamonds, aes(x = price, y = ..density..)) +
  geom_freqpoly(aes(colour = cut), binwidth = 500)

# Diamonds considered "fair" (i.e. lowest quality) have the highest average price
# Still difficult to interpret

# Boxplots show IQR and median, can see spread, whether distribution is symmetric about
# median or skewed. 
# Points more than 1.5 times IQR from edge of box are plotted (outliers). Whisker from 
# box to furthest non-outlier. 

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_boxplot()

# Can see more on this plot - supports counterintuitive finding that better quality 
# diamonds are cheaper on average. 
# Cut is already ordered - may want to reorder otherwise, using reorder() function.

# Consider class variable in the mpg dataset - compare highway mileage across classes".
ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()

# Make it easier to see trend by reordering class based on median of hwy.
ggplot(mpg) +
  geom_boxplot(aes(x = reorder(class, hwy, FUN = median), y = hwy))

# With long variable names, boxplot may work better if flipped, use coord_flip()
ggplot(mpg) +
  geom_boxplot(aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  coord_flip()

# 7.5.1.1 Exercises 
#1. Improve visualisation of departure times of cancelled v non-cancelled flights

# Originally: 
nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(aes(sched_dep_time)) +
  geom_freqpoly(aes(colour = cancelled), binwidth = 1/4)

# This is a frequency plot - consider using a boxplot? 

nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>%
  ggplot(aes(sched_dep_time)) +
  geom_boxplot(aes(x = cancelled, y = sched_dep_time))

#2. What variable in diamonds is most important for predicting the price of a diamond?
# How is that variable correlated with cut? Why does the combination of those two 
# relationships lead to lower quality diamonds being more expensive? 

ggplot(diamonds, aes(x = carat, y = price)) +
  geom_point() +
  geom_smooth()
# Appears to be some correlation between carat and price

ggplot(diamonds, aes(x = depth, y = price)) +
  geom_point() +
  geom_smooth()
# Not sure about this one

ggplot(diamonds, aes(x = clarity, y = price)) +
  geom_boxplot()
# Not sure about this one either

ggplot(diamonds) +
  geom_point(aes(x = x, y = price) +
  geom_point(aes(x = y, y = price) +
  geom_point(aes(x = z, y = price)
# How do you make each one a different colour?? 

# From the above, it looks like carat is the most important for measuring price

#3. Install ggstance package, create a horizontal boxplot. How does this compare to using
# coordflip()?

library(ggstance)

# Above, considering the highway mileage of different classes of vehicles in mpg:
ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot()

# With reordered class, by median:
ggplot(mpg, aes(x = reorder(class, hwy, FN = median), y = hwy)) +
  geom_boxplot()

# Now using boxploth() for horizontal boxplot, need to swap hwy/class axes, reorder:
ggplot(mpg, aes(x = hwy, y = class)) +
  geom_boxploth()

ggplot(mpg, aes(x = hwy, y = reorder(class, hwy, FN = median))) +
  geom_boxploth()
  
#4. Boxplots prohibit large number of outlying values - use a letter value plot. 
# Install lvplot package, use geom_lv() to display price v cut. 

install.packages("lvplot")
library(lvplot)

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_lv()

#5. Compare geom_violin() and facetted geom_histogram() and coloured geom_freqpoly().
# Compare cut and price in diamonds

ggplot(diamonds, aes(x = price, y = ..density..)) +
  geom_freqpoly(aes(colour = cut), binwidth = 500)
# overlapping lines make it difficult to compare, but can see rough distribution at a 
# glance 

ggplot(diamonds, aes(x = price)) +
  geom_histogram() +
  facet_wrap(~ cut, ncol = 1, scales = "free_y")
# use facet_wrap(), ncol specifies numnber of columns, scales specifies type of scale

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_violin()

ggplot(diamonds, aes(x = cut, y = price)) +
  geom_violin() +
  coord_flip()

#6. Where dataset is small, sometimes useful to use geom_jitter() to see relationship
# between continuous and categorical variable. Use ggbeeswarm package. 

install.packages("ggbeeswarm")
library("ggbeeswarm")

# Compare highway mileage and class of vehicle from mpg

ggplot(mpg) +
  geom_quasirandom(aes(x = reorder(class, hwy, FN = median), y = hwy))

# Use additional method argument (tukey, smiley, frowney, quasirandom, pseudorandom)
ggplot(mpg) +
  geom_quasirandom(aes(x = reorder(class, hwy, FN = median), y = hwy), method = "smiley")

ggplot(mpg) +
  geom_beeswarm(aes(x = reorder(class, hwy, FN = median), y = hwy))


# 7.5.2 Two categorical variables 
# To visualise the relationship between categorical variables, count the number of 
# observations for each combination. Use geom_count() built into ggplot2.

ggplot(diamonds) + 
  geom_count(aes(x = cut, y = color))

# Size of dot displays number of observations.

# Alternatively, use dplyr:
diamonds %>%
  count(color, cut)

# Visualise with geom_tile() and fill with aes:
diamonds %>%
  count(color, cut) %>%
  ggplot(aes(x = color, cut)) +
  geom_tile(aes(fill = n))


# 7.5.2.1 Exercises
#1. Rescale count dataset above to more clearly show distribution?
# Can create a new variable that shows the proportion of each cut within a colour
# Use grouped mutate
# Need more colours? Use viridis package

install.packages("viridis")
library(viridis)

diamonds %>%
  count(color, cut) %>%
  group_by(color) %>%
  mutate(prop = n / sum(n)) %>%
  ggplot(aes(x = color, y = cut)) +
  geom_tile(aes(fill = prop)) +
  scale_fill_viridis(limits = c(0, 1))

# Or use other palette? 

#2. Use geom_tile() with dplyr to explore how flight delays vary by destination and
# month of year. 

# Group flights by month and destination, summarise dep_delay, plot

flights %>%
  group_by(month, dest) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = factor(month), y = dest, fill = dep_delay)) +
    geom_tile()+
    labs(x = "Month", y = "Destination", fill = "Departure Delay")

# Quite difficult to read! Maybe filter out some destinations first? Also break down into
# particular months? Remove missing values? Better colours? 

library(forcats)
flights %>%
  group_by(month, dest) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  group_by(dest) %>%
  filter(n() == 12) %>%
  ungroup() %>%
  mutate(dest = fct_reorder(dest, dep_delay)) %>%
  ggplot(aes(x = factor(month), y = dest, fill = dep_delay)) +
  geom_tile() +
  scale_fill_viridis() +
  labs(x = "Month", y = "Destination", fill = "Departure Delay")

# Filter out those without regular flights, improve colour scheme
# fct_reorder() comes from forcats package 

#3. Why is it better to use aes(x = color, y = cut) rather than aes(x = cut, y = color)
# in the above? 

# Best to use variable with longer labels on y-axis to prevent overlap. 


# 7.5.3 Two continuous variables
# Scatterplot with geom_point() to visualise covariation.

ggplot(diamonds) +
  geom_point(aes(x = carat, y = price))
# Appears to be an exponential-like relationship between carat and price

# May be less useful for larger datasets (overlap)

# Use alpha aesthetic to add transparency
ggplot(diamonds) +
  geom_point(aes(x = carat, y = price), alpha = 1 / 100)

# Use bins in one or two dimensions, geom_bin2d() or geom_hex() 
install.packages("hexbin")
library(hexbin)

ggplot(smaller) +
  geom_bin2d(aes(x = carat, y = price))

ggplot(smaller) +
  geom_hex(aes(x = carat, y = price))

# Bin one continuous variable such that it acts like a categorical variable 

ggplot(smaller, aes(x = carat, y = price)) +
  geom_boxplot(aes(group = cut_width(carat, 0.1)))
# Bin carat and display boxplot for each bin
# Use cut_width(x, width) to divide variable into x bins of specified width

# Use var_width() to make the width of the boxplot proportional to the number of values
ggplot(smaller, aes(x = carat, y = price)) +
  geom_boxplot(aes(group = cut_width(carat, 0.1)), varwidth = TRUE)

# Display approximately the same number of points in each bin, use cut_number()
ggplot(smaller, aes(x = carat, y =price)) +
  geom_boxplot(aes(group = cut_number(carat, 20)))

# 7.5.3.1 Exercises 
#1. Instead of summarising the conditional distribution with a boxplot, use a frequency
# polygon. 

ggplot(diamonds, aes(x = price, colour = cut_width(carat, 0.3))) +
  geom_freqpoly()
# Number in each bin may not be equal. Distribution is right-skewed.

ggplot(diamonds, aes(x = price, y = ..density.., colour = cut_width(carat, 0.3))) +
  geom_freqpoly()
# Plot density instead of counts will make distributions comparable. Bins with few 
# observations still hard to interpret. 

ggplot(diamonds, aes(x = price, colour = cut_number(carat, 10))) +
  geom_freqpoly()

#2. Visualise the distribution of carat, partitioned by price. 
# Partition price into 10 bins with same number of observations. 

ggplot(diamonds, aes(x = cut_number(price, 10), y = carat)) +
  geom_boxplot()

# Use coord_flip()
ggplot(diamonds, aes(x = cut_number(price, 10), y = carat)) +
  geom_boxplot() +
  coord_flip() +
  xlab("price")

# Consider partitioning into bins of $2000, width determined by number of observations. 
# Use boundary = 0 to ensure first bin goes from $0 - 2000
ggplot(diamonds, aes(x = cut_width(price, 2000, boundary = 0), y = carat)) +
  geom_boxplot() + 
  coord_flip() +
  xlab("price")

#3. How does price of very large diamonds compare to small diamonds? 
# From last plot, price of large diamonds varies much more than small diamonds

#4. Visualise combined distribution of cut, carat and price. 
ggplot(diamonds, aes(x = cut_number(carat, 5), y = price, color = cut)) +
  geom_boxplot()

ggplot(diamonds, aes(x = cut, y = price, colour = cut_number(carat, 5))) +
  geom_boxplot()


#7.6 Patterns and models
# If a systematic relationship exists between two variables, it will appear as a pattern
# in the data. 

# Is the pattern coincidence?
# Can the relationship that is implied by the data be described?
# How strong is the relationship implied by the pattern?
# What other variables might affect the relationship?
# Does relationship change if subgroups of data are considered?

# Consider the eruption length and wait times for eruptions of Old Faithful
ggplot(faithful) +
  geom_point(aes(x = eruptions, y = waiting))

# Longer wait times are associated with longer eruptions. 
# Clusters of data

# Patterns are useful, as they reveal covariation.
# If two variables covary, can use values of one variable to make better predictions 
# about values of the second. 
# If covariation is due to a causal relationship (i.e. special case of covariance), then
# can use value of one variable to control value of second variable.

# Models are used to extract patterns from data. 
# In diamonds, relationship between cut and price difficult to understand, since cut and
# carat, and carat and price, are tightly related. 
# Use a model to remove the very strong relationship between carat and price, in order to
# further explore subtleties. 

# Predict price from carat, compute residuals. Residuals give price of diamonds, once 
# effect of carat has been removed. 
library(modelr)

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>%
  add_residuals(mod) %>%
  mutate(resid = exp(resid))

ggplot(diamonds2) +
  geom_point(aes(x = carat, y = resid))
# Can see that the relationship between carat and price is as expected, i.e. larger
# diamonds are more expensive

# Now plot cut and residuals:
ggplot(diamonds2) +
  geom_boxplot(aes(x = cut, y = resid))
# Better quality diamonds are more expensive

# modelr package 


# 7.7 ggplot2 calls
ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_freqpoly(binwidth = 0.25)
# same as
ggplot(faithful, aes(x = eruptions)) +
  geom_freqpoly(binwidth = 0.25)

# Need to use + with ggplot, instead of %>%
