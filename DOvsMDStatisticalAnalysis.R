# First get all the census tracts from Maricopa County
library(zipcodeR)
library(tidyverse)

## Find the zipcodes for the state of Arizona
Zipcodes.AZ <- search_state("AZ")
names(Zipcodes.AZ)[names(Zipcodes.AZ) == 'zipcode'] <- 'Zipcode'

Test <- reverse_zipcode('85608')

## Select zipcode, major_city, population, population_density,
## median_home_value,

Zipcodes.AZ <- Zipcodes.AZ %>%
  select(Zipcode, major_city, population, population_density, median_home_value, median_household_income)
Zipcodes.AZ <- na.omit(Zipcodes.AZ)

Zipcodes.AZ <- Zipcodes.AZ %>%
  drop_na(population)


## Load Lien's Data
Research_MD.raw <- read_csv("Research - MD.csv")
Research_DO.raw <- read_csv("Research - DO.csv")

names(Research_MD)[names(Research_MD) == 'Practice Zipcode'] <- 'Zipcode'
names(Research_DO)[names(Research_DO) == 'Practice Zipcode'] <- 'Zipcode'

## Statistical Design

## Count the number of rows that have a value = NA for Practice Zipcode
## MD Calculations

NSampleNAMD <- Research_MD %>%
  select(Zipcode) %>%
  summarise_all(~sum(is.na(.)))

## DO Calculations
NSampleNADO <- Research_DO %>%
  select('Zipcode') %>%
  summarise_all(~sum(is.na(.)))

## Filter for only physicians w/ practicing address in Arizona
## Delete all rows with NA values. Make sure all zipcode entries do not include the - and anything after it

Research_DO <- subset(Research_DO, (!is.na(Research_DO[,7])))
Research_DO <- Research_DO %>%
  filter(`Practice State` == 'AZ')
Research_DO <- Research_DO %>%
  mutate(Zipcode = gsub("\\-.*","", Zipcode))

Research_MD <- subset(Research_MD, (!is.na(Research_MD[,7])))
Research_MD  <- Research_MD  %>%
  filter(`Practice State` == 'AZ')
Research_MD  <- Research_MD %>%
  mutate(Zipcode = gsub("\\-.*","", Zipcode))

## Adding the corresponding physician's practice zipcode income to the table

AZ.ZipcodeByIncome <- Zipcodes.AZ %>%
  select(Zipcode, median_household_income, population_density)

Research_DO <- merge(Research_DO, AZ.ZipcodeByIncome,by = "Zipcode")
Research_MD <- merge(Research_MD, AZ.ZipcodeByIncome,by = "Zipcode")

## Drop people who report their zipcode is an adress with no people
## who live there

Research_MD <- Research_MD %>% drop_na(median_household_income)
Research_DO <- Research_DO %>% drop_na(median_household_income)


Avg.HouseholdIncome <- c(mean(Research_MD$median_household_income), mean(Research_DO$median_household_income))
Avg.HouseholdIncome <- format(round(Avg.HouseholdIncome, 0), nsmall = 0)

Median.HouseholdIncome <- c(median(Research_MD$median_household_income),median(Research_DO$median_household_income) )


Avg.PopulationDensity <- c(mean(Research_MD$population_density), mean(Research_DO$population_density))
Avg.PopulationDensity <- format(round(Avg.PopulationDensity, 0), nsmall = 0)


Median.PopulationDensity <- c(median(Research_MD$population_density), median(Research_DO$population_density))

NSampleDOSize <- nrow(Research_DO.raw)
PercentageOfTotalDOSampled <- (nrow(Research_DO)) / NSampleDOSize  * 100
PercentageOfTotalDOSampled <- format(round(PercentageOfTotalDOSampled, 1), nsmall = 1)

NSampleMDSize <- nrow(Research_MD.raw)
PercentageOfTotalMDSampled <- (nrow(Research_MD)) / NSampleMDSize * 100
PercentageOfTotalMDSampled <- format(round(PercentageOfTotalMDSampled, 1), nsmall = 1)

MDs <- c(NSampleMDSize, PercentageOfTotalMDSampled)
DOs <- c(NSampleDOSize, PercentageOfTotalDOSampled)
NSummaryStats <- data.frame(MDs, DOs)
NSummaryStats <- rbind(NSummaryStats, Avg.HouseholdIncome)
NSummaryStats <- rbind(NSummaryStats, Median.HouseholdIncome)
NSummaryStats <- rbind(NSummaryStats, Avg.PopulationDensity)
NSummaryStats <- rbind(NSummaryStats, Median.PopulationDensity)
row.names(NSummaryStats) <- c('N Sample Size', '% of Total Eligible Arizona Degree Holders', "Avg. Income", "Median Income", "Avg. Population Density", "Median Population Density")

## Finding the frequency of MDs and DOs per zipcode

MDFrequencyTable <- table(Research_MD$Zipcode)
DOFrequencyTable <-table(Research_DO$Zipcode)
MDFrequencyTable <- as.data.frame(MDFrequencyTable)
DOFrequencyTable <- as.data.frame(DOFrequencyTable)
names(MDFrequencyTable)[names(MDFrequencyTable) == 'Var1'] <- 'Zipcode'
names(DOFrequencyTable)[names(DOFrequencyTable) == 'Var1'] <- 'Zipcode'


## Replace after %in% w/ what data you want the missing zipcodes to be filled
## in with values of 0

names(MDFrequencyTable)[names(MDFrequencyTable) == 'Freq'] <- 'MDFreq'
names(DOFrequencyTable)[names(DOFrequencyTable) == 'Freq'] <- 'DOFreq'


Missing.Zipcodes <- Zipcodes.AZ %>% 
  filter(!Zipcode %in% MDFrequencyTable$Zipcode) %>% 
  mutate(MDFreq = 0) %>%
  select(Zipcode, MDFreq)

Missing.Zipcodes <- bind_rows(Missing.Zipcodes, MDFrequencyTable)

## 1. Add the total 380 Frequency values to their corresponding zipcode in 
## order of poorest zipcodes to richest zipcodes in the state of Arizona'
## 2. Order the zipcodes in MissingZipcodes from richest to poorest in the
## newly created frequency table before adding it to the overall table

Table <- Zipcodes.AZ

Table <- merge(Missing.Zipcodes, Table, by = "Zipcode")
Table <- Table[order(Table$median_household_income),]
Table.Finished <- Table %>% drop_na(median_household_income)

## reset order of the dataframe
row.names(Table) <- NULL

## save the table results for further analysis in the future
write_csv(Table, "Results.csv")

## GGplot
## plot the 4 separate graphs. Add a trend line and transfer the trend line from the MD to the DO

NSampleMDSize <- sum(Table$MDFreq)
NSampleDOSize <- sum(Table$DOFreq)

## MD Frequency vs Median Household Income
ggplot(data = Table.Finished, mapping = aes(x = median_household_income, y = ((MDFreq / NSampleMDSize) * 100))) +
  geom_point(color = "#FF4A4A") + geom_smooth(method = "lm", color = "#764AF1", se=F) + xlab("Median Household Income Per Zipcode") + ylab("Percentage of MD Physicians in a Particular Zipcode") +
  theme(panel.background = element_rect(fill = '#F5E8E4', color = "#F5C7A9"), panel.grid.major = element_blank(), axis.line = element_line(colour = "black"))

## DO Frequency vs Median Household Income w/ MD linear regression line for comparison
ggplot(data = Table, mapping = aes(x = median_household_income, y = ((DOFreq / NSampleDOSize) * 100))) + geom_smooth(data = Table, mapping = aes(x = median_household_income, y = (MDFreq / NSampleMDSize * 100)), method = "lm", color = "#764AF1", linetype="dashed", se=F) +
  geom_point(color = "#FF4A4A") + geom_smooth(data = Table, mapping = aes(x = median_household_income, y = (DOFreq / NSampleDOSize * 100)), method = "lm", se=F) + xlab("Median Household Income Per Zipcode") + ylab("Percentage of DO Physicians in a Particular Zipcode") +
  theme(panel.background = element_rect(fill = '#F5E8E4', color = "#F5C7A9"), panel.grid.major = element_blank(), axis.line = element_line(colour = "black"))

## MD Frequency vs Population Per Zipcode
ggplot(data = Table.Finished, mapping = aes(x = population, y = ((MDFreq / NSampleMDSize) * 100))) +
  geom_point(color = "#FF4A4A") + geom_smooth(method = "lm", color = "#764AF1", se=F) + xlab("Population Per Zipcode") + ylab("Percentage of MD Physicians in a Particular Zipcode") +
  theme(panel.background = element_rect(fill = '#F5E8E4', color = "#F5C7A9"), panel.grid.major = element_blank(), axis.line = element_line(colour = "black"))

## DO Frequency vs Population Per Zipcode w/ MD linear regression line for comparison
ggplot(data = Table, mapping = aes(x = population, y = ((DOFreq / NSampleDOSize) * 100))) + geom_smooth(data = Table, mapping = aes(x = population, y = (MDFreq / NSampleMDSize * 100)), method = "lm", color = "#764AF1", linetype="dashed", se=F) +
  geom_point(color = "#FF4A4A") + geom_smooth(data = Table, mapping = aes(x = population, y = (DOFreq / NSampleDOSize * 100)), method = "lm", se=F) + xlab("Population Per Zipcode") + ylab("Percentage of DO Physicians in a Particular Zipcode") +
  theme(panel.background = element_rect(fill = '#F5E8E4', color = "#F5C7A9"), panel.grid.major = element_blank(), axis.line = element_line(colour = "black"))

# Map the data on a map of Arizona and visualize it that way
## Convert a practice address into what census tract it is in

## Add 3 new columns to the Zipcode Table
Zipcodes.Maricopa %>% 
  add_column(new_col =NA)

## Append the newly produce get
for (x in 1:length(Zipcodes.Maricopa$Zipcodes)) {
  Zipcode.Maricopa.appendascolumns(get_tracts(x))
}




