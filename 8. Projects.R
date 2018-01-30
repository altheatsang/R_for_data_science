# Store calculations in code, not in environment

# Use Ctrl + Shift + F10 to restart RStudio
# Use Ctrl + Shift + S to rerun current script

# Use projects in RStudio 

library (tidyverse) 
ggplot(diamonds, aes(carat, price) +
       geom_hex()
ggsave("diamonds.pdf")

write_csv(diamonds, "diamonds.csv") 

# Create pdf and csv from Rstudio, also the R script 

