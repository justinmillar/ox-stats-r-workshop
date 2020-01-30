# StatML Workshop
# Introduction to Data Wrangling and Visualisation in R with the Tidyverse
# Oxford IT Services


#### 0. Getting Started ####

# Load tidyverse package
library(tidyverse)  # May require installation first

# Download data file into project
download.file(url = "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-21/spotify_songs.csv",
              destfile = "spotify-data.csv")

# Load datafile into R session
spotify <- read_csv("spotify-data.csv")

# Inspect data
spotify         # The data object has 32,833 observations (rows) and 23 fields (columns)
class(spotify)  # The object is a tidy dataframe called a "tibble"
names(spotify)  # Names for the columns

#### 1. DATA WRANGLING ####

#' The primary data manipulation package in tidyverse is called `dplyr`
#' (shortname for "data frame" and "pliers", like the tool). 
#' 
#' The functions in this package are used the write efficient code that is also
#' more readable to humans than base R code. Sometimes `dplyr` functions are called
#' "verbs", which can be a helpful way of envision the "wrangling" steps.
#' 
#' The first argument in each `dplyr` function is *always* the dataframe. Soon 
#' we'll see how to use this structure to string multiple steps together into a 
#' single manipulation pipeline.

# 1.1 Selecting columns, filtering rows ----

#' Use the select() function to select specific columns in the dataframe. Start 
#' with the dataframe object, than the desired, column(s). 
select(spotify, track_name)
select(spotify, track_name, track_artist, playlist_genre)

# dplyr can use quoted or unquoted names:
select(spotify, track_name, "track_album_name")

# You can also use the numeric index to select, however using the column name 
# will make your code more reproducible:
select(spotify, 2, 10)

# We can also change the name of columns within select()

select(spotify, song = track_name, artist = track_artist)

#' Use the filter() to select rows based on specific criteria. Remember to start 
#' with the object, then the selection criteria with base R notation:
filter(spotify, track_popularity  > 90)
filter(spotify, track_artist == "Ed Sheeran")

#' Filters can be based on multiple conditions, across columns. They can include 
#' the "and" (&), "or" (|), and matching operators (%in%):
filter(spotify, track_artist == "Avicii" & track_album_name == "Stories")
filter(spotify, playlist_genre == "pop" | playlist_genre == "r&b")
filter(spotify, track_artist %in% c("Billie Eilish", "Sam Smith", "Lady Gaga"))

# 1.2 Piping steps together ----

#' Often data wrangling involves multiple steps. The Tidyverse includes a special 
#' operator called a "pipe", which is written as %>%. 

#' The pipe works by sending output of one function into the first augment of 
#' the next function. Since the first argument in dyplr functions is always the 
#' dataframe object we can use pipes to string together wrangling steps. 
#' For example, here is how to show just the most popular songs and their 
#' artists:

select(spotify, track_name, track_artist, track_popularity) %>% 
  filter(track_popularity > 95)

#' Note that in the filter() step we did not putting in the put the 'spotify' 
#' object in, it was provided by the pipe. Another way to do this would be to 
#' start by piping the data frame object:

spotify %>% 
  select(track_name, track_artist, track_popularity) %>% 
  filter(track_popularity > 95)

#' This creates a human-readable script that shows the wrangling steps with 
#' dplyr's "verb" functions. 

# 1.3 Mutate new columns ----

#' The mutate() function is used to create new columns. For example, we can 
#' create a new column for the song duration in seconds:

spotify %>% 
  select(track_name, duration_ms) %>% 
  mutate(duration_s = duration_ms / 1000)

#' We can use the new column to make additional columns, but order matters.
#' This does not work:

spotify %>%
  select(track_name, duration_ms) %>%
  mutate(duration_min = duration_s / 60,
         duration_s = duration_ms / 1000)

# But this does:
spotify %>% 
  select(track_name, duration_ms) %>% 
  mutate(duration_s = duration_ms / 1000,
         duration_min = duration_s / 60)

#' The same is true for all functions in the pipe, if we remove a column with 
#' select, we can't then use it in a mutate:

spotify %>% 
  select(track_name) %>% 
  mutate(duration_s = duration_ms / 1000)

# If we don't want the old column we need another select():
spotify %>% 
  select(track_name, duration_ms) %>% 
  mutate(duration_s = duration_ms / 1000) %>% 
  select(-duration_ms)  

# 1.4 Separating and uniting columns ----

#' The separate() function can be used to split one column into multiple based 
#' on a particular character

spotify %>% 
  select(track_name, track_album_release_date) %>% 
  separate(col = track_album_release_date, 
           into = c("year", "month", "day"), 
           sep = "-")

#' The opposite of separate() is unite(), which can combine multiple columns 
#' into a single column:

spotify %>% 
  select(track_name, playlist_genre, playlist_subgenre) %>% 
  unite(col = "full_genre", playlist_genre, playlist_subgenre, 
        sep = " - ")

#' Note that these functions actually come from the `tidyr` package, which is 
#' also include in library(tidyverse).

# 1.5 Grouping and summarising ----

# Use the distinct() function to show each of the unique values in a column:

spotify %>% 
  distinct(playlist_subgenre)

# By default tibbles will only print the first 10 entries, but we can adjust 
# the number of rows using the print() function

spotify %>% 
  distinct(playlist_subgenre) %>% 
  print(n = Inf)

#' Sometimes you may want to aggregate data based on the different groups or 
#' types. First use the group_by() to organize the data based on the number of 
#' distinct values: 

spotify %>% 
  group_by(playlist_subgenre)

#' Notice that the table did not change, however the print out now starts that 
#' there are groups, based on the playlist_subgenre column, and how many. We can 
#' use the count() function to tally the number of observations in each group.

spotify %>% 
  group_by(playlist_subgenre) %>% 
  count()

#' Often we want to do more complex aggregations, for that we can use the 
#' summarise() (or summarize() for my fellow Americans!):

spotify %>% 
  group_by(genre = playlist_subgenre) %>% 
  summarise(n_tracks       = n(), 
            avg_popularity = mean(track_popularity), 
            top_popularity = max(track_popularity))

#' meidut a time. Also, use the arrange() function 
#' to order the table based on one or more columns. By default this will sort 
#' the table in ascending order, wrap the column name with desc() for descending 
#' order.

spotify %>% 
  filter(track_artist == "Drake") %>% 
  group_by(album = track_album_name, genre = playlist_genre) %>% 
  summarise(n_tracks       = n(),
            avg_popularity = mean(track_popularity), 
            top_popularity = max(track_popularity)) %>% 
  arrange(album, desc(n_tracks)) %>% 
  print(n = Inf)


#### 2. VISUALISATION ####

#' The tidyverse package for data visualization is `ggplot2`. The "gg" stands 
#' for "grammar of graphics", which define the core philosphy behind the package. 
#' This package is so popular that versions have been developed of many other 
#' programming languages. 
#' 
#' ggplot graphics are built step-by-step, layering elements, customizations, 
#' and theme piece-by-piece. 

# 2.1 Aesthetic and Geoms ----

#' The core function of `ggplot2` is `ggplot()` (shocking!). The first argument 
#' is, as always, our data (typically a data.frame or tibble).

ggplot(spotify)

#' It might seem like nothing happened, but if you look in the Plots window
#' you'll notice a "blank" screen with a grey box. 
#' Next we can add what we call "mapping" to the plot, this will be what your
#' x and y axis will be amongst other "aesthetics" you would like to feature
#' the argument usually is written as `mapping = aes()` where you input the features
#' in the aes() function which stands for "aestheatics"

ggplot(spotify, mapping = aes(x = playlist_genre, y = duration_ms))

#' still nothing! but now at least we can see a blank graph with x variable = playlist_genre
#' and y= duration_ms. 
#' As we mentioned, ggplot() is a layering process. So now we need to tell it what
#' to plot (i.e. type of plot). For our first try let's plot a boxplot.
#' Use geom_boxplot(). Note that to layer items you add them with a `+` sign.

ggplot(spotify, mapping = aes(x = playlist_genre, y = duration_ms))+
  geom_boxplot()


#' There are many types of plots available, usually they start with geom_
#' I would encourage you to try use another geom_ above. Perhaps a violin plot?
#' ggplot() is designed to be flexible, such that data can be directly put into
#' a geom_(). Here is an alternative way to write the same plot above.

ggplot()+
  geom_boxplot(spotify, mapping = aes(x = playlist_genre, y = duration_ms))
  
#' This can be useful when we want to overlay multiple datasets with different mappings.
#' you can also add other characterists to the plots - such as size and color

ggplot()+
  geom_boxplot(spotify, 
               mapping = aes(x = playlist_genre, y = duration_ms),
               color = "blue", size = 2)

#' or fill the inside
ggplot()+
  geom_boxplot(spotify, 
               mapping = aes(x = playlist_genre, y = duration_ms),
               fill = "green")

#' These characteristics can also vary based on columns in the database
ggplot()+
  geom_boxplot(spotify, 
               mapping = aes(x = playlist_genre, 
                             y = duration_ms,
                             fill = playlist_genre))
 
#' One note is that ggplot likes to have long formatted data. 
#' Because these belong to tidyverse you can pipe in data manipulations into ggplot


spotify %>%
  separate(col = track_album_release_date, 
           into = c("year", "month", "day"), 
           sep = "-") %>% #separate data to get a year value
  filter(year >= 1980 & !is.na(year)) %>% #only keep data after 1980
  mutate(duration_min = duration_ms/60000) %>%  #make a new variable for duration in minutes
  select(year, duration_min, playlist_genre) %>% 
  ggplot()+
  geom_point(aes(x=year, y = duration_min, color = playlist_genre), 
             alpha = 0.1)
  
#' You can also change general aesthetics of the plot such as labels,
#' background plot colour, the way the axis look. this is done by theme()

duration_year <- spotify %>%
  separate(col = track_album_release_date, 
           into = c("year", "month", "day"), 
           sep = "-") %>% #separate data to get a year value
  filter(year >= 1980 & !is.na(year)) %>% #only keep data after 1980
  mutate(duration_min = duration_ms/60000) %>%  #make a new variable for duration in minutes
  select(year, duration_min, playlist_genre)

ggplot(duration_year)+
  geom_point(aes(x=year, y = duration_min, color = playlist_genre), 
             alpha = 0.3)+
  labs(x = "Year", y = "Duration in minutes", color = "Genre")+  #add labels
  theme_classic()  #pre-set theme

#' there are many pre-set themes available for ggplot. But you can also customise
#' this additionally using the theme() function again
#' For example we may want the years on the x-axis to be rotated

ggplot(duration_year)+
  geom_point(aes(x=year, y = duration_min, color = playlist_genre), 
             alpha = 0.3)+
  labs(x = "Year", y = "Duration in minutes", color = "Genre")+  #add labels
  theme_classic()+  #pre-set theme
  theme(axis.text.x = element_text(angle = 90))

#'I urge you to keep trying to play around with the layers of ggplot. We have a
#'few exercises for you to practice what you've learned here. For those more advance
#'I would recommend taking a look at other tidytuesday examples and try to recreate them
#'
  