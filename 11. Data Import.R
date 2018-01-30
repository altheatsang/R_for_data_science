#11.1 Introduction
# Learn how to read plain-text rectangular files into R

library(tidyverse)

#11.2 Getting started 
# read_csv() reads comma delimited files
# read_csv2() reads semicolon separated files (i.e. where , is decimal point)
# read_tsv() reads tab delimited files 
# read_delim() reads files with any delimiter 

# read_fwf() reads fixed width files 
# fwf_widths() specify fields by their widths
# fwf_positions() specify fields by their positions 

# read_table() reads a common variation of fixed width files where columns separated by 
# white space 

# read_log() reads Apache style log files (consider webreadr)

# Above functions have similar syntax
?read_csv

heights <- read_csv("heights.csv")

# Can also supply an inline csv file

read_csv("a, b, c
         1, 2, 3
         4, 5, 6")

# In both cases above, read_csv() uses first line of data for column names 
# May want to modify this behaviour 

# If there are lines of metadata at the top of file, skip these with skip = n
# Of use comment = "#" to drop all lines that start with #

read_csv("The first line of metadata
         the second line of metadata
         x, y, z, 
         1, 2, 3", skip = 2)

read_csv("# Comment to be skipped
         x, y, z, 
         1, 2, 3", comment = "#")

# Data might not have column names, use col_names = FALSE to tell read_csv() not to treat
# the first row as headings, but label sequentially as X1 to Xn
read_csv("1, 2, 3\n4, 5, 6", col_names = FALSE)

# Use \n to add new line

# Or use col_names = c() as character vector to pass column names
read_csv("1, 2, 3\n4, 5, 6", col_names = c("x", "y", "z"))

# Can use na to specify which value is used to represent missing values in file
read_csv("a, b, c\n1, 2, .", na = ".")


#11.2.2 Exercises
#1. What function should be used to read a file where fields separated by "|"?

read_delim(file, delim = "|")

#2. Apart from file, skip and comment, what other arguments are common to read_csv() and
# read_tsv()?

union(names(formals(read_csv)), names(formals(read_tsv)))

# Also: col_names, col_types, locale, na, quote_da, quote, trim_ws, n_max, guess_max, progress

#3. What are the most important arguments to read_fwf()?

# col_positions(), tells function where data columns begin and end

#4. Sometimes strings in a csv file contain commas - should be surrounded by a quoting 
# character like ' or ". Convention assumes quoting character will be ", use read_delim()
# to change. What arguments would be needed to specify to read the following into a df?

"x, y\n1, 'a, b'"

x <- "x, y\n1, 'a,b'"
read_delim(x, ",", quote = "'")

#5. What is wrong with the following? 

read_csv("a,b\n1,2,3\n4,5,6")
# Parsing failures - only two columns specified, but there are three columns
# Last column is dropped

read_csv("a,b,c\n1,2\n1,2,3,4")
# Three columns specified, but rows have 2 or 4 values (i.e. do not match)
# Row 2 has two values, last value is designated as missing
# Row 3 has 4 values, last value is dropped

read_csv("a,b\n\"1")

read_csv("a,b\n1,2\na,b")
# a and b are treated as non-character vectors since they contain non-numeric strings 
# May have been intended that columns are 1, 2 and a, b

read_csv("a;b\n1;3")
# Values separated by ; rather than , - use read_csv2() instead

# 11.3 Parsing a vector 
# parse_*() functions take a character vector and return a more specialised vector, such
# as a logical, integer or date

str(parse_logical(c("TRUE", "FALSE", "NA")))
str(parse_integer(c("1", "2", "3")))
str(parse_date(c("2010-01-01", "1975-04-24")))

# parse_*() functions are uniform, first argument is character vector to parse,
# na argument specifies which strings should be treated as missing 

parse_integer(c("1", "231", ".", "456"), na = ".")
# returns 1 231 NA 456

x <- parse_integer(c("123", "345", "abc", "123.45"))
# When parsing fails, warning received 

x
# Failures missing in output 

# If there are many failures, use problems() to get complete set
# This returns a tibble, can then use dplyr to manipulate
problems(x)

# Using parsers requires that the way they deal with different inputs is understood
# Generally, they return parsed but unevaluated expressions in a list

#1. parse_logical()  
#2. parse_integer()
#3. parse_double() - strict numeric parser
#4. parse_number() - flexible numeric parser
#5. parse_character()
#6. parse_factor() - creates factors, used to represent categorical values with fixed values
#7. parse_datetime() 
#8. parse_date()
#9. parse_time()

#11.3.1 Numbers
# Difficulties with numbers include:
# i) different ways of writing numbers, e.g. decimal point is . or ,
# ii) numbers can be surrounded by other characters, e.g. $ or %
# iii) numbers often contain grouping symbols that differ, e.g. 1,000,000

# i) readr has a "locale" that specifies parsing options
# Important to define character used for decimal point 
# Can override default value of . by creating new locale and using decimal_mark argument

parse_double("1.23")
parse_double("1,23", locale = locale(decimal_mark = ","))

# ii) parse_number() ignores non-numeric characters before and after number
# Useful for currencies and percentages, can extract numbers embedded in text 

parse_number("$100")
parse_number("20%")
parse_number("It cost #123.45")

# iii) Addressed by combination of parse_number and locale, as parse_number() will ignore
# the grouping mark 

parse_number("$123,456,789")
parse_number("123.456.789", locale = locale(grouping_mark = "."))
parse_number("123'456'789", locale = locale(grouping_mark = "'"))


# 11.3.2 Strings 
# parse_character() should theoretically just return its input, but it doesn't 
# Consider how strings are represented
# In R, use charToRaw() to get underlying representation of a string 

charToRaw("Althea")

# Each letter represented by hexadecimal number, encoding in ASCII

# readr assumes UTF-8 encoding 
x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"

# These will not read properly - need to specify encoding using parse_character()

parse_character(x1, locale = locale(encoding = "Latin1"))
parse_character(x2, locale = locale(encoding = "Shift-JIS"))

# Often, encoding is not included in the documentation, use guess_encoding() in readr
# First argument can be to a path or file, or raw vector 
guess_encoding(charToRaw(x1)) 
guess_encoding(charToRaw(x2))


# 11.3.3 Factors
# R uses factors to represent categorical values with a known set of possible values 

# Give parse_factor() a vector of known levels to generate a warning whenever an
# unexpected value is present

fruit <- c("apple", "banana")
parse_factor(c("apple", "banana", "bananana"), levels = fruit)

# If there are many problematic entries, often easier to leave as character vectors and 
# use tools in strings/factors to clean up


# 11.3.4 Dates, date-times, times
# Pick between three parsers that return: 
# date (number of days since 1970-01-01)
# date-time (number of seconds since midnight 1970-01-01)
# time (number of seconds since midnight)

# parse_datetime() expects an ISO8601 date-time (year, month, day, hour, minute, second)
parse_datetime("2010-10-01T2010")
parse_datetime("20130823")
# where time is omitted, will be set to midnight 

# parse_date() expects a four digit year , - or /, month, - or /, day
parse_date("2008-05-12")

# parse_time() expects hour, :, minutes, and optionally, :, seconds, and optionally, am/pm
library(hms)
parse_time("01:10am")
parse_time("20:19:34")

# Alternatively, can supply own date-time format, using individual parts
# Year: %Y (4 digits), %y (2 digits: 00-69 for 2000-2069, 70-99 for 1970-1999)
# Month: %m (2 digits), %b(abbreviated, e.g. Jan), %B (full name, e.g. January)
# Day: %d (2 digits), %e (optional leading space)
# Time: %H (0-23 hour), %I (0-12 hour, with am/pm), %p (am/pm), %M (minutes),
# %S (integer seconds), %OS (real seconds), %Z (time zone, as name), %z (as offset from UTC)

# Non-digits: %. (skips one non-digit character), %* (skips any number of non-digits)

parse_date("01/02/15", "%m/%d/%y")
parse_date("01/02/15", "%d/%m/%y")
parse_date("01/02/15", "%y/%m/%d")

# If using %b or %B with non-English month names, need to set lang() argument to locale()
# List of built-in languages in date_names_langs()

date_names_langs()

parse_date("1 januar 2017", "%d %B %Y", locale = locale("de"))


# 11.3.5 Exercises
#1. What are the most important arguments to locale()?
?locale
# Date/time formats, time zone, number formatting (decimal/grouping mark), encoding

#2. What if decimal_mark and grouping_mark are set to the same character? 
locale(decimal_mark = ".", grouping_mark = ".")
# This gives an error - must be different 

# What happens to default for grouping_mark if decimal_mark = ","?
locale(decimal_mark = ",")
# grouping_mark is then set to "."

# What happens to default for decimal_mark if grouping_mark = "."?
locale(grouping_mark = ".")
# decimal_mark is then set to ","

#3. What do date_format and time_format do to locale()?
?readr
?locale
# Provide date and time formats 

#4. Create new locale object that encapsulates settings of your choice. 
?date_names_lang

locale("en", decimal_mark = ".")

#5. Difference between read_csv() and read_csv2()?
# read_csv() reads comma delimited files
# read_csv2() reads semicolon delimited files

#6. What are most common encodings in Europe? Asia? 
# Europe - UTF-8, ASCII, ISO8859-1, also separate encodings for other languages, ISO 
# and Windows encoding standards
# Asia - also have ISO and Windows encoding standards, but major Asian languages have
# their own encodings 

#7. Generate correct formate string to parse each of the following
d1 <- "January 1, 2010"
parse_date(d1, "%B %d, %Y")

d2 <- "2015-Mar-07"
parse_date(d2, "%Y-%b-%d")

d3 <- "06-Jun-2017"
parse_date(d3, "%d-%b-%Y")

d4 <- c("August 19 (2015)", "July 1 (2015)")
parse_date(d4, "%B %d (%Y)")

d5 <- "12/30/14" # Dec 30, 2014
parse_date(d5, "%m/%d/%y")

t1 <- "1705"
parse_time(t1, "%H%M")

t2 <- "11:15:10.12 PM"
parse_time(t2, "%I:%M:%OS", locale = locale(decimal_mark = "."))

?parse_time
?locale

# Stuck here

# 11.4 Parsing a file 
# readr automatically guesses type of each column
# default can be overriden 

# 11.4.1. Strategy
# readr guesses by considering the first 1000 rows and heuristically figures it out 
# This can be emulated by using a character vector with:
# i) guess_parser() - returns readr's best guess
# ii) parse_guess() - uses guess to parse column 

guess_parser("2010-10-01")
# returns "date"

guess_parser("15:01")
# returns "time"

guess_parser(c("TRUE", "FALSE"))
# returns "logical"

guess_parser(c("1", "3", "5"))
# returns "integer"

guess_parser(c("123,456,789"))
# returns "number"

str(parse_guess("2010-10-01"))
# returns "Date[1:1], format: "2010-10-01"

# Heuristic tries each of the following until a match is found: 
# logical: "F", "T", "FALSE", "TRUE" only
# integer: only numeric characters and -
# double: only valid doubles, including numbers in scientific notation
# number: contains valid doubles with grouping mark inside
# time: matches default time_format()
# date: matches default date_format()
# date_time: any ISO8601 date
# if none of the above, then stays as vector of strings 

# 11.4.2 Problems 
# May not work for larger files

# First 1000 rows may be a special case, readr may guess a type that is not sufficiently 
# general, e.g. column of doubles but first 1000 rows only contains integers

# Column may have many missing values. If first 1000 rows contain only NA, readr will 
# guess as character vector

challenge <- read_csv(readr_example("challenge.csv"))

# Provides column specification generated by looking at first 1000 rows
# Also first five parsing failures 
# Pull out problems() to explore in more depth 

problems(challenge)
# Appears that there are problems parsing column x - trailing characters
# after integer - suggests that a double parser is needed 

# Copy/paste column into original call
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_integer(),
    y = col_character()
    )
  )

# Then fix the x column to be a double
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_character()
  )
)

# Check that problem has been fixed (yes it has)
problems(challenge)

# Look at last few rows - has date stored as character vector
tail(challenge)

# Fix by specifying that y is a date column 
challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

tail(challenge)

# Every parse_xyz() function has a corresponding col_xyz() function
# Use parse_xys() when data is in a character vector in R already
# Use col_xyz() when you want to tell readr how to load the data

# Supply col_types based on readout provided by readr, ensures consistent 
# and reproducible data import script 
# If default types are relied upon, readr will continue to use even if data
# changes 
# Use stop_for_problems() that will return an error and stop script if there
# are any parsing problems 


# 11.4.3 Other strategies
# Sometimes need to consider more than 1000 rows of data

# In previous example, if just one more line was considered, then would 
# have been parsed in one attempt

challenge2 <- read_csv(readr_example("challenge.csv"), guess_max = 1001)
# Returns correct column types 
challenge2

# Alternatively, read in all columns as chraacter vectors
challenge2 <- read_csv(readr_example("challenge.csv"),
  col_types = cols(.default = col_character())
  )
challenge2

# Used in conjunction with type_convert(), which applies parsing heuristics 
# to the character columns in dataframe

df <- tribble(
  ~x, ~y,
  "1", "1.21",
  "2", "2.32", 
  "3", "4.56"
)
df
# Column types are chr
type_convert(df)
# Columns converted accordingly 

# If reading a very large file, may want to set n_max() to a smallish number

# If there are many parsing problems, sometimes easier to read in a 
# character vector of lines with read_lines(), or even a character vector
# of length 1 with read_file()


# 11.5 Writing to a file 
# readr has two useful functions for writing data back to disk: 
# write_csv() and write_tsv()
# Both increase chances of output file being read back correctly by:
# always encoding strings in UTF-8, saving dates/times in ISO8601

# To export csv file to Excel, use write_excel_csv()
# This writes a special character ("byte order mark") that tells Excel that
# UTF-8 encoding is used 

# The most important arguments are x (dataframe to save) and path(location
# to save)
# Can specify how missing values are written with na, can append existing file

write_csv(challenge, "challenge.csv")
# Type information lost when saved to csv 

challenge
write_csv(challenge, "challenge-2.csv")
read_csv("challenge-2.csv")

# This makes csv's unreliable for caching interim results - need to recreate
# the column specification each time data loaded in

# Two alternatives: 

# i) write_rds() and read_rds() - unform wrappers around base functions of 
# readRDS() and saveRDS() (stores data in R's custom binary function - RDS)
write_rds(challenge, "challenge.csv")
read_rds("challenge.csv")

# feather package implements a fast binary file format that can be shared 
# across programming languages 
install.packages("feather")
library(feather)
write_feather(challenge, "challenge.feather")
read_feather("challenge.feather")

# feather tends to be faster than RDS and is usable outside R


# 11.6 Other types of data
# In addition to tidyverse packages: 

# Rectangular data can be read by
# haven (SPSS, Strata, SAS files)
# readxl (reads Excel files, .xls and .xlsx)
# DBI (run SQL queries again database and return dataframe, with database
# specific backend)

# Hierarchical data can be read by
# jsonlite (for json)
# xml2 (for XML)