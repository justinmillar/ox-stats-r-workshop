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
# Use the select() and filter() functions to answer the following questions

# Create a table with the song name, popularity, and danceability 





# How many songs are in the "r&b" genre?





# How many songs in the "rap" genre have a energy score above 0.95?




# 1.2 ----
# Use the "pipe" operator ( %>% ) to answer the following questions   


# 1.5 ----
# Which artist has the most entries on the list?

# Solutions -----

# Create a table with the song name, popularity, and danceability 
select(spotify, track_name, track_popularity, danceability)

# How many songs are in the "r&b" genre?
filter(spotify, playlist_genre == "r&b")

# How many songs in the "rap" genre have a energy score above 0.95?
nrow(filter(spotify, energy > 0.95 & playlist_genre == "rap"))

# Which artist has the most entries on the list?
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
#HINT: to make mutiple plots you can use facet_wrap(~playlist_genre)


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


#2.4 ---
# is there a relationship between danceability and popularity?

ggplot(spotify)+
  geom_smooth(mapping = aes(x = danceability, y = track_popularity))+
  labs(x = "Danceability", y = "Popularity on Spotify")+
  theme_classic()



# can you visualise it for each genre?
ggplot(spotify, mapping = aes(x = danceability, y = track_popularity,
                              color = playlist_genre))+
  geom_point(color = "light blue", alpha = 0.05)+
  geom_smooth()+
   labs(x = "Danceability", y = "Popularity on Spotify")+
  facet_wrap(~playlist_genre)+
  theme_bw()+
  theme(legend.position = "none")
