install.packages("tidyverse")
install.packages("dplyr")
install.packages("ggplot2")
install.packages("lubridate")
install.packages("modeest")
library(tidyverse)
library(dplyr)
library(ggplot2)
library(lubridate)
library(readxl)
library(modeest)

tripdata2301 <- read.csv("202301-divvy-tripdata.csv")
tripdata2212 <- read.csv("202212-divvy-tripdata.csv")
tripdata2211 <- read.csv("202211-divvy-tripdata.csv")
tripdata2210 <- read.csv("202210-divvy-tripdata.csv")
tripdata2209 <- read.csv("202209-divvy-publictripdata.csv")
tripdata2208 <- read.csv("202208-divvy-tripdata.csv")
tripdata2207 <- read.csv("202207-divvy-tripdata.csv")
tripdata2206 <- read.csv("202206-divvy-tripdata.csv")
tripdata2205 <- read.csv("202205-divvy-tripdata.csv")
tripdata2204 <- read.csv("202204-divvy-tripdata.csv")
tripdata2203 <- read.csv("202203-divvy-tripdata.csv")
tripdata2202 <- read.csv("202202-divvy-tripdata.csv")
tripdata2201 <- read.csv("202201-divvy-tripdata.csv")

tripdata <- bind_rows(
  tripdata2301, 
  tripdata2212, 
  tripdata2211, 
  tripdata2210, 
  tripdata2209, 
  tripdata2208, 
  tripdata2207, 
  tripdata2206, 
  tripdata2205, 
  tripdata2204, 
  tripdata2203, 
  tripdata2202,
  tripdata2201)

tripdata$date <- as.Date(tripdata$started_at)
tripdata$month <- format(as.Date(tripdata$date), "%m")
tripdata$day <- format(as.Date(tripdata$date), "%d")
tripdata$year <- format(as.Date(tripdata$date), "%Y")
tripdata$day_of_week <- format(as.Date(tripdata$date), "%A")

str(tripdata)

#remove any unnecessary columns (erroneous ride_length, latitude/longitude fields)
tripdata <- tripdata %>% 
  select(-c(start_lat, start_lng, end_lat, end_lng))

#length calculation and create a column
tripdata$ride_length <- as.numeric(difftime(tripdata$ended_at,tripdata$started_at))

class(tripdata$ride_length)

#remove na rows
tripdata_no_na <- drop_na(tripdata)

#Removing bad data
#Remove negative ride length and quality check rows
tripdata_1 <- tripdata[!(tripdata$start_station_name == "HQ QR" | tripdata$ride_length<0),]

#stat
summary(tripdata)
str(tripdata)

head(tripdata)
tripdata$member_casual
summary(tripdata_1$ride_length)/60

# STEP 4: CONDUCT DESCRIPTIVE ANALYSIS
#Analyze
#Descriptive analysis on ride_length(all figures in seconds)
#straight average(total ride length/rides)
mean(tripdata_1$ride_length)
#midpoint number in the ascending array of ride lengths
median(tripdata_1$ride_length)
#longest ride
max(tripdata_1$ride_length)
#shortest ride
min(tripdata_1$ride_length)

#Condense the four lines above to one line using summary() on the specific attribute
summary(tripdata_1$ride_length)

## Compare Members vs. Casual Riders
aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual, FUN = mean)
aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual, FUN = median)
aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual, FUN = max)
aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual, FUN = min)

#See the average ride time by each day for members vs casual users
aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual + tripdata_1$day_of_week, FUN = mean)

#Notice that the days of the week are out of order. To fix it,
tripdata_1$day_of_week <- ordered(tripdata_1$day_of_week, levels = c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

#Now, let's run the average ride time by each day for membersvs casual users
aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual + tripdata_1$day_of_week, FUN = mean)

#Analyze ridership data by type and weekday
#Creates weekday field using wday()
tripdata_1 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  #groups by usertype and weekday
  group_by(member_casual, weekday) %>% 
  #calculates the number of rides and average duration
  summarise(number_of_rides=n(),
            #calculates the average duration
            average_duration = mean(ride_length)) %>% 
  #sorts
  arrange(member_casual,weekday)


#Visualize the number of rides by rider type
tripdata_1 %>% 
  mutate(weekday = wday(started_at, label = TRUE)) %>% 
  group_by(member_casual,weekday) %>% 
  summarise(num_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>% 
  ggplot(aes(x=weekday, y=num_of_rides, fill=member_casual))+
  geom_col(position = "dodge")

#Create a visualization for average duration
tripdata_1 %>% 
  mutate(weekday = wday(started_at,label = TRUE)) %>% 
  group_by(member_casual, weekday) %>% 
  summarise(number_of_rides = n()
            ,average_duration = mean(ride_length)) %>% 
  arrange(member_casual, weekday) %>% 
  ggplot(aes(x=weekday, y=average_duration, fill=member_casual))+
  geom_col(position = "dodge")

# STEP 5: EXPORT SUMMARY FILE FOR FURTHER ANALYSIS
# Create a csv file that we will visualize in Excel, Tableau, or my presentation software
# N.B.: This file location is for a Mac. If you are working on a PC, change the file location accordingly (most likely "C:\Users\YOUR_USERNAME\Desktop\...") to export the data. You can read more here: https://datatofish.com/export-dataframe-to-csv-in-r/
counts <- aggregate(tripdata_1$ride_length ~ tripdata_1$member_casual + tripdata_1$day_of_week, FUN = mean)
write.csv(counts, file = '~/Desktop/counts.csv')

write.csv(tripdata_1, file = '~/Desktop/tripdata_1.csv')

