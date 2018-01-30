library(tidyverse)

# mpg dataframe

# Use ggplot to plot mpg (engine size v fuel efficiency: 

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

# Graph shows, generally, greater engine size has lower efficiency
# geom_point() gives scatter plot


# Template for graphing:
# ggplot(data = <DATA>) +
# <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# Exercises 3.2.4
#1. Run ggplot(mpg = data)
ggplot(mpg = data)
# Don't see anything, ggplot not given anything to plot

#2. How many rows and columns in mpg?
# Print data set using ?mpg to find

#3. What does drv variable describe? 
?mpg
# drv variable takes f (front-wheel), r (rear-wheel), 4 (4wd)

#4. Make scatterplot of hwy v cyl
ggplot(data = mpg) +
  geom_point(mapping = aes(x = hwy, y = cyl))

ggplot(data = mpg, aes(x = hwy, y = cyl)) +
  geom_point()

#5. Scatterplot of class v drv?
ggplot(data = mpg, aes(x = class, y = drv)) +
  geom_point()
# Not a useful graph as both class and drv are factor variables (can't see overlap)


# Aesthetic mappings

# Add 3rd variable to plot, e.g. class for mpg (type of car), by mapping to an aesthetic
# Aesthetic is a visual property of the plot (e.g. size, shape, colour of point), has levels

# Map colours of points to class in plot of engine size/efficiency to give class
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = class))

# Map size of points to class, but not good because class is unordered, size is ordered
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, size = class))

# Map alpha aes to class, controls transparency or shape of points 
ggplot(data = mpg) + 
    geom_point(mapping = aes(x = displ, y = hwy, alpha = class))

ggplot(data = mpg) + 
    geom_point(mapping = aes(x = displ, y = hwy, shape = class))
# suv is missing - default is 6 shapes at a time (suv goes unplotted)

# Can set aesthetic properties of plot manually - outside of aes()
# Pick colour, size, shape of point
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

# Exercises 3.3.1
#1. What is wrong with 
ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, colour = "blue"))

# colour = "blue" is inside aes(), needs to be outside

#2. Which variables in mpg are categorical? 
# Print data frame, at top of each column, <chr> or "character" is categorical var

mpg

glimpse(mpg)

#3. Map continuous var to colour, size and shape
# Variable cty (city mi/gal) is continuous

ggplot(mpg, aes(x = displ, y = hwy, color = cty)) +
  geom_point()
# Colours are not discrete, graded spectrum

ggplot(mpg, aes(x = displ, y = hwy, size = cty)) +
  geom_point()
# Size of points vary with magnitude of cty

ggplot(mpg, aes(x = displ, y = hwy, shape = cty)) +
  geom_point()
# Continuous variable cannot be mapped to shape (error)

#4. Map same variable to multiple aesthetics? 
ggplot(mpg, aes(x = displ, y = hwy, color = hwy, size = displ)) +
  geom_point()
# hwy mapped to both y and colour of point, displ mapped to x and size

#5. Stroke aesthetic? 
ggplot(mtcars, aes(wt, mpg)) +
  geom_point(shape = 21, colour = "black", fill = "white", size = 5, stroke = 5)
# Stroke changes colour of border for some shapes

#6. What happens if map aes to something other than var name? 
# e.g. aes(colour = displ < 5)
ggplot(mpg, aes(x = displ, y = hwy, colour = displ <5)) +
  geom_point()
# Creates temporary variable, in this case, logical


# Facets
# Additional variable with aesthetics, split plot into facets (subplot)
# Facet plot by single variable with facet_wrap() - formula with ~

ggplot(mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

# Facet plot by two variables with facet_grid() - formula with two variables

ggplot(mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl)

# To prevent faceting in row or column, use . instead of var

ggplot(mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# Exercises 3.5.1 
#1. Facet on continuous variable? 
ggplot(mpg) +
  geom_point(mapping = aes(x = displ, hwy)) +
  facet_grid(. ~ cty)
# Converts continuous variable to factor and creates facets for all unique values

#2. Empty cells in plot with facet_grid(drv ~ cyl)? 
# Cells with no values for combination of drv and cyl
ggplot(mpg) +
  geom_point(mapping = aes(x = drv, y = cyl))
# Locations in plot with no points are the cells that have no values in grid

#3. What does . do? 
# . ignores dimension for faceting 

ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)
# plot facets by drv on y axis

ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)
# plot facets by cyl on x axis

#4. Dis/advantages to using faceting instead of colour?
ggplot(mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy)) + 
  facet_wrap(~ class, nrow = 2)

#5. nrow and ncol in ?facet_wrap
# Determines the number of rows/columns in grid 
# Required for facet_wrap, as single variable 
# Number of rows/columns for facet_grid determined by number of variables 

#6. Variable with more unique values in columns for facet_grid
#Easier to compare, as plot is landscape?


# Geometric objects
# geom is a geometrical object used to represent data 
# geom_point gives scatterplot, geom_smooth gives line graph
# Every geom takes a mapping argument, but not every aes works with every geom
# e.g. set size for point (not line), but set linetype for line (not point)

ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

ggplot(mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# Specify linetype for each unique value
ggplot(mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# Combine types of graphs
ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# Setting linetype of line graph draws separate line for each varible
# Separates according to different values of drivetrain (4, f, r)
ggplot(mpg) + 
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# Where plotting multiple geoms in a graph, pass mappings to ggplot instead
ggplot(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth()

# Where mappings are placed in geom function, treated as local mappings only
ggplot(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(colour = class)) +
  geom_smooth()

# Can specify local data argument for particular geom 
ggplot(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(colour = class)) +
  geom_smooth(data = filter(mpg, class == "subcompact"), se = FALSE)


# Exercises 3.6.1
#1. Geom to draw:
# i) line chart = geom_smooth
# ii) boxplot = geom_boxplot
# iii) histogram = geom_histogram
# iv) area chart = geom_area

#2. What does code look like?
ggplot(mpg, mapping = aes(x = displ, y = hwy, colour = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

# scatter plot, each drivetrain is different colour, plot displ v hwy
# also line plot

#3. What does show.legend = FALSE do? 
# Removes legend from plot

#4. What does se argument for geom_smooth() do?
# se displays confidence level around line

#5. Will the graphs look different? 
ggplot(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() + 
  geom_smooth()

ggplot() +
  geom_point(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_smooth(mpg, mapping = aes(x = displ, y = hwy))

# Graphs will be the same, 1st iteration reduces duplication in code

#6. Recreate code for the following graphs: 
ggplot(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(size = 5) +
  geom_smooth(size = 2, se = FALSE)

ggplot(mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth(mapping = aes(group = drv), se = FALSE)

ggplot(mpg, mapping = aes(x = displ, y = hwy, colour = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy) +
  geom_point(aes(color = drv)) +
  geom_smooth(aes(linetype = drv), se = FALSE)

ggplot(mpg, aes(x = displ, y = hwy, fill = drv)) +
  geom_point(colour = "white", shape = 21)


# Statistical Transformations
# Bar chart, plotting cut (diamonds) - vertical is count, but count is not a var?

ggplot(diamonds) +
  geom_bar(mapping = aes(cut))

# Scatterplots use raw values from data, bar charts calculate new values to plot 
# Algorithm to calculate new values is a "stat"

# Bar, histogram, freqpoly - bin data then plot bin counts
# Smoothers - fit model to data then plot prediction
# Boxplot - summary of distribution

# Can generally use stats and geoms interchangeably
# Every stat has default geom, every geom has default stat
ggplot(diamonds) +
  stat_count(mapping = aes(cut))

# May want to override default stat, e.g. change default stat of count for geom_bar()
# to identity

demo <- tribble(
  ~cut, ~freq,
  "Fair", 1610,
  "Good", 4906,
  "Very Good", 12082,
  "Premium", 13791,
  "Ideal", 21551
)

ggplot(demo) +
  geom_bar(mapping = aes(x = cut, y = freq), stat = "identity")

# Override default mapping from transformed variables to aesthetics
# e.g. bar chart of proportion rather than count
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, y =..prop.., group = 1))

# Draw attention to statistical transformation, use stat_summary()
ggplot(diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

# See ?stat_bin to see all stats in ggplot2

# Exercises 3.7.1
#1. Default geom associated with stat_summary()?
# Default geom is geom_pointrange()
# Default stat for geom_pointrange() is identity, so use geom_pointrange(stat = "summary")
ggplot(diamonds) +
  geom_pointrange(
    mapping = aes(x = cut, y = depth),
    stat = "summary"
  )
# But no summary function supplied, so default to mean_se() - provide functions
ggplot(diamonds) +
  geom_pointrange(
    mapping = aes(x = cut, y = depth),
    stat = "summary",
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

#2. What does geom_col() do, how is this different to geom_bar()
# Default stat of geom_col() is identity, i.e. expects that var already exists
# Default stat of geom_bar() is count, i.e. counts observationst to provide var

#3. Geoms and stats come in pairs - read documentation to find pairs

#4. What variable does stat_smooth() compute?
# Computes y (predicted value), ymin (lower pointwise CI around mean), 
# ymax (upper pointwise CI around mean), se (standard error)

#5. In proportion bar chart, need to set group = 1, why? Problem with following?
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop..))
ggplot(diamonds) + 
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop..))
# Proportions are calculated within each variable, all fill to 1
# What is intended is: 
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, fill = color, y = ..prop.., group = color))


# Position adjustments
# Colour bar chart using either colour aesthetic or fill
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, colour = cut))
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut))

# Map fill aesthetic to another variable, e.g. clarity, bars are stacked
# Each coloured rectangle represents a combination of cut and clarity
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))

# Stacking performed automatically by position adjustment specified by position
# If not stacked, then use "identity", "dodge" or "fill"

# position = "identity" - places object exactly where it falls on graph
# Not very useful for bar graphs, overlaps - make bars slightly transparent
# Set alpha to small value to make transparent
ggplot(diamonds, mapping = aes(x = cut, fill = clarity)) +
  geom_bar(alpha = 1/5, position = "identity")
ggplot(diamonds, mapping = aes(x = cut, colour = clarity)) +
  geom_bar(fill = NA, position = "identity")
# "identity" position adjustment more useful for 2D geoms

# position = "fill" - like stacking, makes each set of bars the same height
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "fill")

# position = "dodge" - places overlapping objects beside each other 
ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity), position = "dodge")

# position = "jitter" - for scatterplots, 
# e.g. in mpg, hwy v displ, values rounded so points appear on a grid, pts overlap
# overplotting - use jitter to add small amount of random noise to each point
ggplot(mpg) +
  geom_point(mapping = aes(x = displ, y = hwy), position = "jitter")


# Exercises 3.8.1
#1. Problem with plot?
ggplot(mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point()
# Overplotting because there are multiple observations for cty v hwy, use jitter
ggplot(mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point(position = "jitter")

#2. Parameters of geom_jitter() that control amount of jittering?
# width and height

#3. Compare/contrast geom_jitter() and geom_count()

#4. Default position adjustment for geom_boxplot()
# Default positino is "dodge"
ggplot(mpg, mapping = aes(x = drv, y = hwy, color = class)) +
  geom_boxplot()

ggplot(mpg, mapping = aes(x = drv, y = hwy, colour = class)) +
  geom_boxplot(position = "identity")


# Coordinate systems
# Default is Cartesian (x-y) system

# coord_flip() switches x and y axes, good for horizontal boxplots 
ggplot(mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

ggplot(mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip()

# coord_quickmap() sets correct aspect ratio for maps

# coord_polar() uses polar coordinates 
bar <- ggplot(diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = cut), 
    show.legend = FALSE, 
    width = 1
  ) +
  theme(aspect.ratio = 1) +
  labs(x = NULL, y = NULL)

bar + coord_flip()
bar + coord_polar()


# Exercises 3.9.1
#1. Turn stacked bar chart into pie chart
# Stacked bar chart with single category
ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar()

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar(width = 1) +
  coord_polar(theta = "y")

# theta = "y" means that angle of chart is y variable 
# Where theta = "y" is not specified, get bullseye chart

ggplot(mpg, aes(x = factor(1), fill = drv)) +
  geom_bar(width = 1) +
  coord_polar() 

# If multiple stacked bar chart, then coord_polar() converts to multi-donut chart
ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = clarity), position = "fill")

ggplot(diamonds) +
  geom_bar(aes(x = cut, fill = clarity), position = "fill") +
  coord_polar(theta = "y")

#2. What does labs do?
# labs modifies axis, legend, plot labels (add different labels to scales)
ggplot(mpg, aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip() +
  labs(y = "Highway MPG", x = "")

#3. Difference between coord_quickmap() and coord_map()?
# coord_map() uses 2D projection (transforms all geoms)
# coord_quickmap() uses uses quick approximation using lat/long as approximation

#4. What does plot say about relationship between city and highway mpg
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point() +
  geom_abline() +
  coord_fixed()

# coord_fixed() ensures abline is fixed at 45 degree angle, so that highway and city
# mileage can be compared if they were exactly the same

# If coord_fixed() not included, then line no longer at 45 degrees 
ggplot(mpg, aes(x = cty, y = hwy)) +
  geom_point() +
  geom_abline()


# Grammar of graphics 
# Template: 
ggplot(<DATA>) +
  <GEOM_FUNCTION>(
    mapping = aes(<MAPPINGS>), 
    stat = <STAT>, 
    position = <POSITION>,
  ) +
  <COORDINATE_FUNCTION> +
  <FACET_FUNCTION>
