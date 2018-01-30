# 10. Tibbles

library(tidyverse)

# 10.2 Creating tibbles
# Coerce data frame as tibble using as_tibble()
as_tibble(iris)

# Create new tibble from individual vectors using tibble()
tibble(
  x = 1:5,
  y = 1,
  z = x^2 + y
)

# Tibbles do not change the type of input, e.g. never converts strings to factors

# Column names of tibbles can be non-valid R variables, i.e. non-syntactic (e.g. not
# a letter, or unusual character)
# Surround with ' to refer to these as variables

tb <- tibble(
  ':)' = "smile", 
  ' ' = "space",
  '2000' = "number"
 )
tb

# Create tibble with tribble(), i.e. transposed tibble,
# Column headings defined by formulas (i.e. start with ~), entries separated by commas
# Display small amounts of data 

tribble(
  ~x, ~y, ~z,
  #--/--/----
  "a", 2, 3.6,
  "b", 1, 8.5
)

# 10.3 Tibbles v data frames 
# Difference between tibble and data frame: printing and setting 

# 10.3.1 Printing
# Printing - tibble shows first 10 rows and only columns that fit on screen
# Columns in a tibble also report its type 

library(lubridate)

tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

# Tibbles used so as not to overwhelm console when printing large dfs
# Sometimes need more output than default display

# Use print() to explicitly print data frame, control rows (n), width of display
# width = Inf, displays all columns

nycflights13::flights %>%
  print(n = 10, width = Inf)

# Control default print behaviour by setting options: 
# options(tibble.print_max = n, tibble.print_min = m) - if > m rows, print n rows
# Use options(dplyr.print_min = Inf) to print all rows
# Use options(tibble.width = Inf) to print all columns 
# See package?tibble to see all options

package?tibble

# Use RStudio viewer to see complete datasheet

nycflights13::flights %>%
  View()

#10.3.2 Subsetting
# Extracting single variables: use [[ ]] to extract by name or position, $ to extract by name

df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

# Extract by name
df$x
# does the same as: 
df[["x"]]

# Extract by position
df[[1]]

# Need placeholder . if using in pipe

df %>% .$x
# or: 
df %>% .[["x"]]

#10.4 Interacting with older code 
# Older functions may not work with tibbles - convert to df with as.data.frame()

class(as.data.frame(tb))


# Exercises 10.5
# 1. How to tell if object is a tibble??
# Use class(), e.g. 
class(mtcars)
# returns "data.frame", so this is not a tibble

class(as_tibble(mtcars))
# returns "tbl_df" and "tbl" as well

#2. Compare/contrast operations on a data frame v tibble

df <- data.frame(abc = 1, xyz = "a")
df$x
df[, "xyz"]
df[, c("abc", "xyc")]

tbl <- as_tibble(df)
tbl$x
tbl[, "xyz"]
tbl[, c("abc", "xyz")]

# With $, dataframe will complete column (saves keystrokes, but care needed)
# With [, type of object returned differs on number of columns, returns df if > 1 col

#3. If name of variable is stored in an object, e.g. var <- "mpg":
# How do you extract name of reference from tibble? 

# Use df[[var]] - can't use df$var, as this would look for column named var.


#4. Practice referring to non-syntactic names from
annoying <- tibble(
  `1` = 1:10,
  `2` = `1` * 2 + rnorm(length(`1`))
)
#a. Extract variable called 1
annoying[["1"]]
annoying$'1'

#b. Plot scatterplot of 1 v 2
ggplot(annoying, aes(x = '1', y = '2')) +
  geom_point()

#c. Create new column '3', which is '2' divided by '1'
annoying[["3"]] <- annoying$'2' /  annoying$'1'
# or
annoying[["3"]] <- annoying[["2"]] / annoying[["2"]]

#d. Renaming columns to 'one', 'two' and 'three'
annoying <- rename(annoying, one = '1', two = '2', three = '3')
glimpse(annoying)

#5. What does tibble::enframe() do? When would you use it?
?tibble::enframe

# Converts named vectors to data frame with values 
enframe(c(a = 1, b = 2, c = 3))

#6. What option controls additional columns that are printed at footer of tibble?
# Print function for tibbles is print.tbl_df 
?print.tbl_df

# Use n_extra for numnber of extra columns to print 

print(nycflights13::flights, n_extra = 2)
