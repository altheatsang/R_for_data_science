library(nycflights13)
library(tidyverse)

# Use nycflights::flights
# Tibble, shows only few rows, remainder can be viewed using ?flights

# Variable types: 
#   int = integers
#   dbl = doubles (real numbers)
#   chr = character strings or vectors
#   dttm = date-times
#   lgl = logical (TRUE/FALSE)
#   fctr = factors (represents categorical var with fixed variables)
#   date = dates

# 5.1.3 dplyr basics
# Functions for data manipulation:
#   filter() = pick observations by values
#   arrange() = reorder rows
#   select() = pick variables by name
#   mutate() = create new variables with functions of existing variables
#   summarise() = collapse many values into single summary 

# Each function used in conjunction with group_by() - changes scope of function from
# working on entire data set to operating on group-by-group

# Syntax is the same for all verbs:
# i) data frame
# ii) describe what to do with data frame
# iii) new data frame

# 5.2 Filter rows with filter()
# Subset observations based on values 

# Select all flights on 1 Jan:
filter(flights, month == 1, day ==1)

# Save results with <-
jan1 <- filter(flights, month == 1, day == 1)

# 5.2.1 Comparisons
# Select observations using comparison operators (>, >=, <, <=, !=, ==)

# Floating point numbers? 
# Following returns false:
sqrt(2) ^ 2 == 2
1/49 * 49 == 1

# Use near() to avoid this
near(sqrt(2) ^ 2, 2)
near(1 / 49 * 49, 1)

# 5.2.2 Logical Operators 
# Combine multiple arguments with filter(), returns results where every exp true
# Otherwise use Boolean operators (x, y, x & !y, y & !x, x & y, xor(x, y), x | y)

# Find flights that departed in Nov or Dec
filter(flights, month == 11 | month == 12)

# Use x %in% y, selects every row where x is a value in y
filter(flights, month %in% c(11, 12))

# De Morgan's law: !(x & y) same as !x | !y, !(x | y) same as !x & !y
filter(flights, !(arr_delay > 120 | dep_delay > 120))
filter(flights, arr_delay <= 120, dep_delay <= 120)

# Consider making variables, where filter() requires multipart expressions

# 5.2.3 Missing Values
# NA - missing values
# Missing values are contagious, i.e. operation with NA will give value of NA
# Use is.na() to determine if value is missing

# filter() only includes rows where condition is TRUE (excludes FALSE and NA)
# To preserve missing values, ask for them explicitly

df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
filter(df, is.na(x) | x > 1)


# 5.2.4 Exercises 
#1. Find flights where:
# i) arrival delay of two or more hours
filter(flights, arr_delay >= 120)

# ii) flew to HOU or IAH (Houston)
filter(flights, dest %in% c("IAH", "HOU"))

# iii) operated by UA, AA, DL
filter(flights, carrier %in% c("UA", "AA", "DL"))

# iv) departed in Jul, Aug, Sep 
filter(flights, between(month, 7, 9))

# v) arrived more than 2 hours late, but didn't leave late
filter(flights, arr_delay > 120, dep_delay <= 0)

# vi) delayed by at least an hour, made up over 30 min in flight 
filter(flights, !is.na(dep_delay), dep_delay >= 60, dep_delay - arr_delay > 30)

# vii) departed between midnight and 6 am 
filter(flights, between(dep_time, 0, 600))

#2. Use between() to filter values
# between(x, left, right) is the same as x >= left, x <= right 

#3. Flights with missing dep_time? Other missing variables?
filter(flights, is.na(dep_time))
# also missing arr_time, plane never left, i.e. cancelled flights

#4. Why is NA ^ 0 not missing? Why is NA | TRUE not missing? Why is FALSE & NA not missing?
NA ^ 0
# not missing, as x^0 = 1 for all values of x 

NA | TRUE
# doesn't matter whether missing value is TRUE or FALSE 

FALSE & NA
# anything and FALSE is always FALSE 


#5.3 Arrange rows with arrange()
# Changes order of rows by column names of data frame 
# If > 1 column name is given, each additional column will be used to break ties in values
# of preceding columns 

# Arrange rows by year, month then day
arrange(flights, year, month, day)

# Use desc() to re-order column by descending order
arrange(flights, desc(arr_delay))

# Missing values always sorted at the end 
df <- tibble(x = c(2, 5, NA))
arrange(df, x)
arrange(df, desc(x))


#5.3.1 Exercises 
#1. Use arrange() to sort all missing values to the start 
arrange(flights, desc(is.na(dep_time)))

#2. Sort flights to find most delayed flights, flights that left earliest 
arrange(flights, desc(dep_delay))
arrange(flights, dep_delay)

#3. Sort flights to find the fastest flights
# Assume fastest means shortest air time?
arrange(flights, air_time)

# If fastest flight is in relation to speed:
arrange(flights, desc(distance / air_time))

#4. Which flights travelled longest/shortest?
# Longest flights
arrange(flights, desc(distance))

# Shortest flights
arrange(flights, distance)


#5.4 Select columns with select()
# Select columns by name
select(flights, year, month, day)

# Select all columns between year and day (inclusive)
select(flights, year:day)

# Select all columns except for those between year and day (exclusive)
select(flights, -(year:day))

# Helper functions can be used with select()
# starts_with("abc") - matches names that begin with "abc"
# ends_with("xyz") - matches names that end with "xyz"
# contains("ijk") - matches names that contain "ijk"
# matches("(.)\\1") - selects variables that match a regular expression
# num_range("x", 1:3) - matches x1, x2 and x3

# select() can be used to rename variables, but not used very often (drops other vars)
# use rename(), which keeps other variables
rename(flights, tail_num = tailnum)

# use select() with everything() helper - move several variables to the front, keep the rest
select(flights, time_hour, air_time, everything())

# 5.4.1 Exercises
#1. Select dep_time, dep_delay, arr_time, arr_delay
select(flights, dep_time, dep_delay, arr_time, arr_delay)
select(flights, starts_with("dep_"), starts_with("arr_"))
select(flights, matches("^(dep|arr)_(time|delay)$"))

#2. What happens if name of variable is included multiple times in select() call?
select(flights, month, year, day, month)
# duplicates are ignored

#3. What does one_of() function do? Why helpful in conjunction with following:
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
# one_of() allows selection of variables with a vector rather than as unquoted var names
# useful, as vector can then be passe to select()
select(flights, one_of(vars))

#4. How do helpers deal with case by default? Can default be changed
select(flights, contains("TIME"))
# default is to ignore case, surprising since dplyr designed to be used where cases
# are not differentiated 
# to change default behaviour, use ignore.case = FALSE
select(flights, contains("TIME", ignore.case = FALSE))


# 5.5 Add new variables with mutate()
# Add new columns that are functions of existing columns 
# mutate() always adds new columns to the end of data set

# Create a smaller data set:
flights_sml <- select(flights,
      year:day,
      ends_with("delay"),
      distance,
      air_time
      )
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60
)

# Refer to columns just created 
mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
       )

# To keep new variables only, use transmute()
transmute(flights_sml,
          gain = arr_delay - dep_delay, 
          hours = air_time / 60,
          gain_per_hour = gain / hours
          )

# 5.5.1 Useful creation functions 
# Use mutate() with functions to create new variables 
# Fn must be vectorised (take vector of values as input, return vector with same no. values)

# Arithmetic functions: (+ - * / ^)
# In conjunction with aggregate fn: (x / sum(x) gives proportion, y / mean(y) gives difference from mean)
# Modular arithmetic (%/% - integer division, %% - remainder)

# e.g. x == y * (x %/% y) + (x %% y)
# e.g. break integers into pieces 
transmute(flights, 
          dep_time, 
          hour = dep_time %/% 100,
          minute = dep_time %% 100
          )

# Logarithms: log(), log2(), log10()

# Offsets: refer to leading or lagging values, lead() or lag(), compute running difference

# Cumulative and rolling aggregates: functions for running sums, products, mins, maxes, means
# cumsum(), cumprod(), cummin(), cummax(), cummean()

# Logical comparisons: <, >, <=, >=, !=

# Ranking: minrank() ranks smallest first, then use desc() to give reverse

# Exercises 5.5.2
#1. Convert dep_time, sched_dep_time to no. minutes since midnight
mutate(flights,
       dep_time_mins = ((dep_time %/% 100) * 60) + dep_time %% 100,
       sched_dep_time_mins = ((sched_dep_time %/% 100) * 60) + sched_dep_time %% 100) %>%
select(dep_time, dep_time_mins, sched_dep_time, sched_dep_time_mins)

# Can also define a function to convert to minutes: 
time2mins <- function(x) {
  x %/% 100 * 60 + x %% 100
}

mutate(flights,
       dep_time_mins = time2mins(dep_time),
       sched_dep_time_mins = time2mins(sched_dep_time)) %>%
select(dep_time, dep_time_mins, sched_dep_time, sched_dep_time_mins)

#2. Compare air_time with arr_time - dep_time.
# arr_time and dep_time may be in different timezones, air_time does not account for difference

mutate(flights,
       air_time2 = arr_time - dep_time,
       air_time_diff = air_time2 - arr_time) %>%
  filter(air_time_diff != 0) %>%
  select(air_time, air_time2, dep_time, arr_time, dest)

#3. Compare dep_time, sched_dep_time and dep_delay.
# Expect difference between dep_time and sched_dep_time to be same as dep_delay
mutate(flights,
       dep_delay2 = dep_time - sched_dep_time) %>%
  filter(dep_delay2 != dep_delay) %>%
  select(dep_time, sched_dep_time, dep_delay, dep_delay2)

# Need to convert to minutes 
mutate(flights,
       dep_delay2 = time2mins(dep_time) - time2mins(sched_dep_time)) %>%
  filter(dep_delay2 != dep_delay) %>%
  select(dep_time, sched_dep_time, dep_delay, dep_delay2)

# Still different, have not accounted for flights dep/arr on different days

#4. Find 10 most delayed flights using ranking function. 
#Consider how tied values are dealt with? Take minimum of any tied values. 
mutate(flights,
       dep_delay_rank = min_rank(-dep_delay)) %>%
  arrange(dep_delay_rank) %>%
  filter(dep_delay_rank <= 10)

#5. What does 1:3 + 1:10 return?
1:3 + 1:10

# When adding two vectors, recycle the shorter vector's values until both are the same
# length - warning given 

#6. Trigonometric funtions in R? 
# cos(x), sin(x), tan(x), acos(x), asin(x), atan(x)


# 5.6 Grouped summaries with summarise()

# summarise() collapses dataframe to single row

summarise(flights, delay = mean(dep_delay, na.rm = TRUE))
# gives single value of mean dep_delay

# Pair summarise() with group_by()

by_day <- group_by(flights, year, month, day)
summarise(by_day, delay = mean(dep_delay, na.rm = TRUE))

# 5.6.1 Combining multiple operations with pipe 
# Consider relationship between distance and avg delay for each location

by_dest <- group_by(flights, dest)
delay <- summarise (by_dest,
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
    )
delay <- filter(delay, count > 20, dest != 'HNL')
ggplot(delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

# Delays increase with distance up to ~750 miles, then decrease. As flights get longer
# there is the capacity to make up delay? 

# This required: i) group flights by dest, ii) summarise to find dist, delay, flights, 
# iii) filter to remove noise and HNL
# This requires that each intermediate df is named, even if it is not needed (slow!)

# Use the pipe: %>%
delays <- flights %>%
  group_by(dest) %>%
  summarise(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)
) %>%
filter(count > 20, dest != 'HNL')


# 5.6.2 Missing values 
# What happens if na.rm is not used?

flights %>% 
  group_by(year, month, day) %>%
  summarise(mean = mean(dep_delay))

# Aggregation functions obey the usual rule of missing values, i.e. if there is any 
# missing value in the input, then output will also be a missing value 

# All aggregation functions have an na.rm argument to remove missing values 

# In flights, where missing values represent cancelled flights, can remove cancelled flights 

not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(mean = mean(dep_delay))

# 5.6.3 Counts
# When using an aggregation function, consider including a count (n()) or count of
# non-missing values (sum(!is.na(x))) - check number of values considered 

delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay)
  )
ggplot(delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# Appears that some flights have a delay of over 5 hours - really?

# Consider scatterplot: 
delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarise(
    delay = mean(arr_delay, na.rm = TRUE), 
    n = n()
  )
ggplot(delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

# Greater variation in avg delay when few flights - variation decreases with increase
# in sample size

# Useful to filter out groups with smallest number of observations - see more of the 
# pattern, less of the extreme variation
delays %>%
  filter(n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

# Consider how average performance of batters in baseball is related to the number of
# times they bat - Lahman package
# Plot skill of batter (batting average, ba) against number of opportunities to hit
# (at bat, ab) 

batting <- as_tibble(Lahman::Batting)
batters <- batting %>%
  group_by(playerID) %>%
  summarise(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE)
  )
batters %>% 
  filter(ab > 100) %>%
  ggplot(aes(x = ab, y = ba)) +
  geom_point() +
  geom_smooth(se = FALSE)
# Variation in aggregate decreases with more data points
# Positive correlation between skill (ba) and opportunities (ba)

# Consider ranking - best batting avg may be luck, not skill
batters %>%
  arrange(desc(ba))

# 5.6.4 Useful summary functions
# Measures of location: mean(x), median(x)
# Find average delay 
not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(
    avg_delay1 = mean(arr_delay),
    avg_delay2 = mean(arr_delay[arr_delay > 0])
  )

# Measures of spread: sd(x), IQR(x), mad(x)
# Why is distance to some dests more variable than others?
not_cancelled %>%
  group_by(dest) %>%
  summarise(distance_sd = sd(distance)) %>%
  arrange(desc(distance_sd))

# Measures of rank: min(x), quantile(x, 0.25), max(x)
# Quantiles are a generalisation of median, quantile(x, 0.25), finds x > 25% of values
# When do first/last flights leave each day?

not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(
    first = min(dep_time),
    last = max(dep_time)
  )

# Measures of position: first(x), last(x), nth(x,2)
# Find first/last departure each day 

not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(
    first_dep = first(dep_time),
    last_dep = last(dep_time)
  )

# These functions complementary to filtering by rank - gives all obs

not_cancelled %>%
  group_by(year, month, day) %>%
  mutate(r = min_rank(desc(dep_time))) %>%
  filter(r, %in% range(r))

# Counts: n() takes no arguments and returns size of current group 
# sum(!is.na(x)) counts non-missing values
# n_distinct(x) counts number of distinct  values 

# Destinations with most carriers? 
not_cancelled %>% 
  group_by(dest) %>%
  summarise(carriers = n_distinct(carrier)) %>%
  arrange(desc(carriers))

# dplyr provides count() as helper
not_cancelled %>%
  count(dest)

# Provide an optional weight variable
# e.g. "count" total miles flown by a plane 
not_cancelled %>%
  count(tailnum, wt = distance)

# Counts/proportions of logical values: when used with numeric functions, TRUE is 1,
# FALSE is 0. sum(x) gives number of TRUE s in x, mean(x) gives proportion 

# Flights that left before 5 am? 
not_cancelled %>% 
  group_by(year, month, day) %>%
  summarise(n_early = sum(dep_time < 500))

# Proportion of flights delayed by more than 1 hr?
not_cancelled %>%
  group_by(year, month, day) %>%
  summarise(hour_prop = mean(arr_delay > 60))


# 5.6.5 Grouping by multiple variables 
# Group by multiple variables, each summary peels off one layer of grouping 

daily <- group_by(flights, year, month, day)

(per_day <- summarise(daily, flights = n()))
(per_month <- summarise(per_day, flights = sum(flights)))
(per_year <- summarise(per_month, flights = sum(flights)))

# These types of summaries ok for sums/counts, but not for rank-based statistics 
# e.g. sum of groupwise sums is overall sum, but median of groupwise median is not
# overall median

# 5.6.6 Ungrouping 
# Remove grouping and return to ungrouped data: use ungroup()

daily %>% 
  ungroup() %>%
  summarise(flights = n())

# 5.6.7 Exercises 
#1. Brainstorm ways to assess typical delay characteristics of a group of flights
# Which is more important: arrival delay or departure delay? Arrival delay

# Flight is 15 minutes early 50% of the time, 15 minutes late 50% of the time
flights %>%
  group_by(flight) %>%
  summarise(early_15_min = sum(arr_delay <= -15, na.rm = TRUE) / n(),
            late_15_min = sum(arr_delay >= 15, na.rm = TRUE) / n()) %>%
  filter(early_15_min == 0.5,
         late_15_min == 0.5)

# Flight is always 10 minutes late
flights %>%
  group_by(flight) %>%
  summarise(late_10 = sum(arr_delay == 10, na.rm = TRUE) / n()) %>%
  filter(late_10 == 1)

# Flight is 30 minutes early 50% of the time, 30 minutes late 50% of the time 
flights %>%
  group_by(flight) %>%
  summarise(early_30 = sum(arr_delay <= -30, na.rm = TRUE) / n(),
            late_30 = sum(arr_delay >= 30, na.rm = TRUE) / n()) %>%
  filter(early_30 == 0.5,
         late_30 == 0.5)

# Flight is on time 99% of the time, 2 hours late 1% of the time 
flights %>%
  group_by(flight) %>%
  summarise(on_time = sum(arr_delay == 0, na.rm = TRUE) / n(),
            late_2h = sum(arr_delay >= 120, na.rm = TRUE) / n()) %>%
  filter(on_time == 0.99,
         late_2h == 0.01)

#2. Approach that will give the same output as: not_cancelled %>% count(dest) and 
# not_cancelled %>% count(tailnum, wt = distance) without using count()

not_cancelled %>% 
  count(dest)
# Gives count of all flights to given destination

not_cancelled %>%
  group_by(dest) %>%
  summarise(n = n())
# Group flights by destination, then use summary function

not_cancelled %>% 
  count(tailnum, wt = distance)
# Gives count of all flights of given plane

not_cancelled %>%
  group_by(tailnum) %>%
  summarise(n = sum(distance, na.rm = TRUE))
# Group flights by plane first, then sum distance for each plane

#3. Definition of cancelled flights (is.na(dep_delay) | is.na(arr_delay)) is suboptimal.
# Why? Which is most important column?

# There are no flights that arrived that did not depart, so current definition is somewhat
# redundant since it also removes arr_delay separately. 
# dep_delay is most important, i.e. only dep_delay is required 

#4. Consider cancelled flights per day. Pattern? Proportion of cancelled flights related
# to average delay?

# Assume "per day" refers to numerical date of each month and group_by(day) is sufficient
# Otherwise, group_by(year, month, day)

flights %>%
  filter(is.na(dep_delay)) %>%
  count(day)

flights %>%
  group_by(day) %>%
  summarise(prop_cancelled = sum(is.na(dep_delay)) / n(),
            avg_delay = mean(dep_delay, na.rm = TRUE))

# Alternatively:
cancelled_delayed <- 
  flights %>%
  mutate(cancelled = (is.na(arr_delay) | is.na(dep_delay))) %>%
  group_by(year, month, day) %>%
  summarise(prop_cancel = mean(cancelled),
            avg_dep_delay = mean(dep_delay, na.rm = TRUE))

ggplot(cancelled_delayed, aes(x = avg_dep_delay, prop_cancel)) + 
  geom_point() + 
  geom_smooth()

#5. Carrier with worst delays? Disentangle effects of bad airports v bad carriers? 

# worst delays
flights %>%
  group_by(carrier) %>%
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(desc(mean_delay))

# bad airports v bad carriers 
flights %>%
  group_by(carrier, dest) %>%
  summarise(mean_delay = mean(arr_delay, na.rm = TRUE)) %>%
  group_by(carrier) %>%
  summarise(mean_delay_mad = mad(mean_delay, na.rm = TRUE)) %>%
  arrange(desc(mean_delay_mad))

# Calculate median absolute deviation (mad) of average delay by carrier and destination
# Higher values indicate greater spread in delays across destinations, i.e. more variation
# Lower values indicate similar delays (so less spread) across destinations
# Lower values do not mean that particular carrier was more "on time", just more consistent
# Compare this table to table of avg delay to disentangle airports/carriers

#6. What does sort argument to count() do? 
# sort will sort results of count() in descending order of n, use if arrange() is the
# next step after completing count (save a line of code)


#5.7 Grouped mutates (and filters) 
# Grouping most useful in conjunction with summarise()
# Convenient operations with mutate() and filter() 

# Find the worst members of each group
flights_sml %>%
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)

# Find all groups bigger than a threshold
popular_dests <- flights %>%
  group_by(dest) %>%
  filter(n() > 365)
popular_dests

# Standardise to compute per group metrics 
popular_dests %>%
  filter(arr_delay > 0) %>%
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>%
  select(year:day, dest, arr_delay, prop_delay)

# Grouped filter followed by grouped mutate, followed by ungrouped filter (fairly crude
# way to do things - no way of checking that manipulation is correct) 

# Functions that work most naturally in grouped mutates and filters are known as 
# "window functions" (v summary functions for summaries)

# 5.7.1 Exercises
#1. How do mutate/filtering functions change when combined with grouping? 

# Function is applied over each group, rather than whole dataframe 

#2. Which plane (tailnum) has the worst on-time record?
# Define "on-time record" as arrival delay, i.e. worst record is longest delay?

# Find the plane with longest average arrival delay

flights %>%
  group_by(tailnum) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ungroup() %>%
  filter(rank(desc(arr_delay)) <= 1)

#3. What time of day should you fly to avoid delays?

# Group by hour, calculate average arrival delay

flights %>%
  group_by(hour) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(arr_delay)

# Best to fly early in the day 

#4. For each destination, compute total minutes of delay. For each, compute 
# proportion of total for its destination. 

flights %>%
  filter(!is.na(arr_delay), arr_delay > 0) %>%
  group_by(dest) %>%
  mutate(total_delay = sum(arr_delay),
         prop_delay = arr_delay / sum(arr_delay))

# Filter out rows that do not have a delay, or negative delay (early)
# Group by destination, create new variable of total delay (sum of delays within each)
# Find proportion

#5. Delays typically correlated - once problem that caused delay is resolved, later flights
# are delayed to allow earlier flights to leave. Use lag() to explore how delay of flight
# is related to delay of immediately preceding flight.

# Group by day - avoid previous day's delays.
# Use departure delay.
# Remove missing values before and after calculating lag delay.

flights %>%
  group_by(year, month, day) %>%
  filter(!is.na(dep_delay)) %>%
  mutate(lag_delay = lag(dep_delay)) %>%
  filter(!is.na(lag_delay)) %>%
  ggplot(aes(x = dep_delay, y = lag_delay)) +
  geom_point() +
  geom_smooth()

#6. Consider each destination. Are there any flights that are suspiciously fast? 
# Compute air time of a flight relative to shortest flight to that destination.
# Which flights were most delayed in the air?

# Remove rows where there is no air time (i.e. no flight)
# Group by destination
# Find median air time (use this to compare all flights0 

flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest) %>%
  mutate(median_time = median(air_time),
         fast = (air_time - median_time) / median_time) %>%
  arrange(fast) %>%
  select(air_time, median_time, fast, dep_time, sched_dep_time, arr_time, sched_arr_time) %>%
  head(15)

# Largest value for "fast" gives flights that have shortest air time for destination.
# For some of the longer flights from NY, e.g. to ATL, GSP, BNA, may be a suspicious,
# since flight time is about half of median. Flights to BOS (closer to NY) may be ok.

# For flights most delayed in the air: 
# Calculate the difference in air time for a particular destination with the minium air
# time for the same destination, arrange

flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest) %>%
  mutate(air_time_diff = air_time - min(air_time)) %>%
  arrange(desc(air_time_diff)) %>%
  select(dest, year, month, day, carrier, flight, air_time, air_time_diff, dep_time, arr_time) %>%
  head()

#7. Find all destinations flown by at least 2 carriers, rank carriers.

# Group by destination, carrier
# Count carriers for each destination

flights %>%
  group_by(dest, carrier) %>%
  count(carrier) %>%
  group_by(carrier) %>%
  count(sort = TRUE)

# EV has the most destinations of all carriers

#8. For each plane, count the number of flights before the first delay greater than 1 hr.


