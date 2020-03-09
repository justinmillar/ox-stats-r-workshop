# StatML Workshop
# Introduction to Data Wrangling and Visualisation in R with the Tidyverse
# Oxford IT Services

#### Exercises ####

# Load tidyverse package
library(tidyverse)  # May require installation first

# Download data file into project
download.file(url = "https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-01-21/spotify_songs.csv",
              destfile = "spotify-data.csv")

# Load datafile into R session
spotify <- read_csv("spotify-data.csv")

#### Data Wrangling ####

# 1.1 ----
# Use the select() and filter() functions to answer the following questions:

# Create a table with the song name, popularity, and danceability 





# How many songs are in the "r&b" genre?





# How many songs in the "rap" genre have a energy score above 0.95?




# 1.2 ----
# Use the "pipe" operator ( %>% ) to answer the following questions:   

# Which songs on this list are by the artist "Drake", and what is their popularity?






# Which songs by "Drake" have a popularity above 80?







# Return a one column dataframe that is just songs by "Drake" with a populatity 
# above 80:





# 1.3 ----
# Use the mutate() function to create new variables and answer the following questions:

# Make a new column for track length per hour





# Create two columns for the number of minutes the remaining seconds



# 1.4 ----
# Create a new column that combines genre and sub-genre





# Make a column called "duration" which contains the track minutes and seconds 
# separated by a ":".






# 1.5 ----

# What is the mean and standard deviation of track popularity for each genre?





# Which artist have the most have the most entries on the list?





# Solutions -----

# 1.1 ----
# Create a table with the song name, popularity, and danceability 
select(spotify, track_name, track_popularity, danceability)

# How many songs are in the "r&b" genre?
filter(spotify, playlist_genre == "r&b")

# How many songs in the "rap" genre have a energy score above 0.95?
nrow(filter(spotify, energy > 0.95 & playlist_genre == "rap"))

# 1.2 ----
# Which songs on this list are by the artist "Drake", and what is their popularity?
spotify %>% 
  select(track_name, track_artist, track_popularity) %>% 
  filter(track_artist == "Drake")

# Which songs by "Drake" have a popularity above 80?
spotify %>% 
  select(track_name, track_artist, track_popularity) %>% 
  filter(track_artist == "Drake", track_popularity > 80)

# Return a one column dataframe that is just songs by "Drake" with a populatity 
# above 80:
spotify %>% 
  select(track_name, track_artist, track_popularity) %>% 
  filter(track_artist == "Drake", track_popularity > 80) %>% 
  distinct(track_name)

# 1.3 ----
# Make a new column for track length per hour
spotify %>% 
  select(track_name, duration_ms) %>% 
  mutate(duration_hr = duration_ms / (1000 * 60 * 60))

# Create two columns for the number of minutes the remaining seconds
# HINT: there are special operators for integer division and finding the modulus
spotify %>% 
  select(track_name, duration_ms) %>% 
  mutate(duration_s = duration_ms / 1000, 
         min = duration_s %/% 60, 
         sec = round(duration_s %% 60))

# 1.4 ----

# Create a new column that combines genre and sub-genre
spotify %>% 
  select(track_name, playlist_genre, playlist_subgenre) %>% 
  unite(col = "full_genre", playlist_genre, playlist_subgenre, 
        sep = " - ")

# Make a column called "duration" which contains the track minutes and seconds 
# separated by a ":".
# Bonus: use the ticyverse function str_pad() to add a leading 0!
spotify %>% 
  select(track_name, duration_ms) %>% 
  mutate(duration_s = duration_ms / 1000, 
         min = duration_s %/% 60, 
         sec = round(duration_s %% 60), 
         sec = str_pad(sec, 2, pad = "0")) %>%
  unite("duration", min, sec, sep = ":") %>% 
  select(-c(duration_s, duration_ms))


# 1.5 ----

# What is the mean and standard deviation of track popularity for each genre?
spotify %>% 
  group_by(playlist_genre) %>% 
  summarise(
    avg_rating = mean(track_popularity),
    sd_rating  = sd(track_popularity)
  )

# Which artist have the most have the most entries on the list?
spotify %>% 
  group_by(track_artist) %>% 
  count() %>% 
  arrange(desc(n))


#### Data Visualisation ####
# for this section we don't expect students to have the same plots
# get create with color, transparency (alpha), sizes and even themes!
# 2.1 ----
#create a plot to see the the danceability against playlist_genre
# what geom_ would be appropriate?



#create another plot to look at the danceability against energy
# what geom_ would be appropriate?




# 2.2 ----
#create a plot of the danceability against the energy for each playlist_genre
#HINT: to may mutiple plots you can use facet_wrap(~playlist_genre)


# 2.3 ----
#what is the distribution of danceability for each genre?
#HINT: you can use different colors to differientate genres too




#2.4 ----
# is there a trend between danceability and popularity?
# HINT: geom_smooth() can sometimes provide loess lines




# can you visualise it for each genre?




# Solutions -----
#Please note; these are simply examples of plots, but you can make
# whatever you choose as well

# 2.1 ----
# plot to see the the danceability against playlist_genre
ggplot(spotify)+
  geom_violin(mapping = aes(x = playlist_genre, y = danceability))+
  theme_classic()


#create another plot to look at the danceability against energy

ggplot(spotify)+
  geom_point(mapping = aes(x = energy, y = danceability,
                           color = playlist_genre), alpha = 0.3)+
  theme_classic()


#2.2 ----
# plot of the danceability against the energy for each playlist_genre
ggplot(spotify)+
  geom_point(mapping = aes(x = energy, y = danceability,
                           color = playlist_genre), alpha = 0.3)+
  facet_wrap(~playlist_genre)+
  theme_classic()

#2.3 ----
#what is the distribution of danceability for each genre?
#HINT: you can use different colors to differientate genres too

ggplot(spotify)+
  geom_density(mapping = aes(fill = playlist_genre, x = danceability), 
               alpha = 0.3)+
  theme_minimal()


#2.4 ----
# is there a trend between danceability and popularity?

ggplot(spotify)+
  geom_smooth(mapping = aes(x = danceability, y = track_popularity))+
  labs(x = "Danceability", y = "Popularity on Spotify")+
  theme_classic()



# can you visualise it for each genre?
ggplot(spotify, mapping = aes(x = danceability, y = track_popularity,
                              color = playlist_genre))+
  geom_point(alpha = 0.05)+
  geom_smooth()+
  labs(x = "Danceability", y = "Popularity on Spotify")+
  facet_wrap(~playlist_genre)+
  theme_bw()+
  theme(legend.position = "none")
