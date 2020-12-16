library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)

# --------------------------------------------- IMPORT AND PREPARE DATA -----------------------------------------------------------

# Importing the sample raw data
load("RawData.Rdata")

# to import your own raw log data use the code below
#
# data_raw <- read.csv("<YOUR_LOG_FILE_NAME>.CSV", sep = ",", stringsAsFactors = FALSE, encoding = "UTF-8") %>%
#   select(-Klinischer.Benutzer) %>%
#   rename(Zeit = Datum) %>%
#   arrange(Zeit) %>%
#   # change Zeit to POSIXct class objects
#   mutate(Zeit = as.POSIXct(Zeit, format = "%d.%m.%Y %H:%M:%S"))

# creating a new clean dataset
data_tbl <- data_raw %>%
  as_tibble() %>%
  # This only retains log entries associated with alarms
  filter(Bettname != "")

# If you are curious which entries have been deleted:
empty <- data_raw %>% filter(Bettname == "")
# see the actions that have been deleted:
empty <- tibble(unique(empty$Aktion))

data_tbl <- data_tbl %>%
  # Storing the Bed ID as a factor
  mutate(Bettname = as.factor(Bettname)) %>%
  # Extracting the true time an alarm was generated from the string
  mutate(TrueTime = ifelse(grepl("generiert", Aktion), sub("^(.*?) *generiert.* (.*?).$", "\\2", Aktion), NA)) %>%
  # adding the date to the time information
  mutate(Date_only = as.Date(format(Zeit))) %>% # there is a bug that converts some dates wrongly. format() helps. https://stackoverflow.com/questions/17098862/as-dateas-posixct-gives-the-wrong-date
  mutate(Date_only = ifelse(is.na(TrueTime), NA, paste0(Date_only, TrueTime))) %>%
  mutate(Date_only = as.POSIXct(Date_only)) %>%
  mutate(TrueTime = Date_only) %>%
  select(-Date_only) %>%
  # adding the log time where no true time is documented (eg terminated alarms)
  mutate(TrueTime = coalesce(TrueTime, Zeit)) %>% 
  # the TrueTime can differ by one day from the Zeit, which occurs if the true time of alarm generation lies right before midnight,
  # while the log was stored after midnight. TrueTime dates in these cases are adjusted. The lag is adjusted by substracting the difference
  # of one day.
  mutate(difftime = Zeit - TrueTime) %>% 
  mutate(TrueTime = ifelse(difftime <= -82800, TrueTime - days(1), TrueTime)) %>% 
  mutate(TrueTime = as_datetime(TrueTime, tz = "Europe/Berlin")) %>% 
  select(-difftime)


# --------------------------------------------- GENERATED VS TERMINATED ALARMS -----------------------------------------------------------

data_tbl <- data_tbl %>%
  mutate(Situation = ifelse(grepl("generiert", Aktion), "generiert",
    ifelse(grepl("beendet", Aktion) & !grepl("Alarm- oder Störungston wurde beendet.", Aktion), "beendet", NA)
  )) %>%
  # convert Situation to factor
  mutate(Situation = as.factor(Situation))

# --------------------------------------------- EXTRACTING THE ALARM CRITICALITY -----------------------------------------------------------

# Creates a column that indicates an alarm's criticality (red, yellow, blue)
data_tbl <- data_tbl %>%
  mutate(Alarmfarbe = case_when(
    str_detect(Aktion, "^[\\*!]{3}?") ~ "rot",
    str_detect(Aktion, "^[\\*!]{2}?") ~ "gelb",
    str_detect(Aktion, "^[\\*!]{1}?") ~ "gelb"
  )) %>%
  mutate(Alarmfarbe = ifelse((grepl("generiert", Situation) | grepl("beendet", Situation)) & is.na(Alarmfarbe), "blau", Alarmfarbe)) %>%
  # convert Alarmfarbe to factor
  mutate(Alarmfarbe = as.factor(Alarmfarbe))


# --------------------------------------------- EXTRACT ALARMS -----------------------------------------------------------

alarm_regex <- "^([\\*!]{1,3}\\s?)*(Apnoe > 10min|\\D+?.*?)(\\s*)(\\s-|\\s{1}beendet|\\s{1}generiert|\\s{1}\\d:|\\d{2,}|\\s\\d|\\d\\s\\s<|\\sNIED|\\sHOCH|\\sZU\\s)"

data_tbl <- data_tbl %>%
  mutate(Alarm = ifelse(!is.na(Alarmfarbe), str_match(Aktion, alarm_regex)[, 3], NA)) %>%
  # subsume equivalent alarms
  mutate(Alarm = ifelse(Alarm %in% c("SpO2l", "SpO2r", "SpO2po"), "SpO2", Alarm)) %>%
  mutate(Alarm = ifelse(Alarm == "ARTs", "ABPs", Alarm)) %>%
  mutate(Alarm = ifelse(Alarm == "ARTm", "ABPm", Alarm)) %>%
  mutate(Alarm = ifelse(Alarm == "ARTd", "ABPd", Alarm)) %>%
  # remove excess whitespaces
  mutate(Alarm = str_squish(Alarm)) %>%
  # replace umlauts
  mutate(Alarm = str_replace_all(Alarm, c("ü" = "ue", "ä" = "ae", "ö" = "oe", "ß" = "ss"))) %>%
  # convert Alarm to factor
  mutate(Alarm = as.factor(Alarm))

# --------------------------------------------- OVERVIEW OF EXTRACTED ALARMS -----------------------------------------------------------

# a table with all extracted alarm parameters
all_alarms <- data_tbl %>%
  select(Alarm) %>%
  filter(!is.na(Alarm)) %>%
  unique()

# --------------------------------------------- ASSINGINING ALARMS TO DEVICES -----------------------------------------------------------

# load device assignments from file Appendix_4_DeviceAssignments.R
source("Appendix_4_DeviceAssignments.R")

data_tbl <- data_tbl %>%
  mutate(Alarmgruppe = case_when(
    Alarm %in% ventilator_alarms ~ "Ventilator",
    Alarm %in% NIBP ~ "NIBP",
    Alarm %in% IBP ~ "IBP",
    Alarm %in% EKG ~ "ECG",
    Alarm %in% TEMP ~ "Temperature",
    Alarm %in% intracranial_pressure ~ "ICP",
    Alarm %in% pulse_oximetry ~ "SpO2",
    Alarm %in% tech_fail ~ "Technical failure",
    Alarm %in% Thermodilution ~ "Thermodilution",
    Alarm %in% NOT_ASSIGNED ~ "NOT_ASSIGNED"
  )) %>%
  mutate(Alarmgruppe = as.factor(Alarmgruppe))

# removing variables from the environment
rm(ventilator_alarms, NIBP, IBP, EKG, TEMP, intracranial_pressure, pulse_oximetry, tech_fail, Thermodilution, NOT_ASSIGNED)

# Overview
DeviceAssignments <- data_tbl %>%
  filter(Situation == "generiert") %>%
  select(Alarm, Alarmgruppe) %>%
  distinct() %>%
  arrange(Alarmgruppe)

# --------------------------------------------- DIRECTION OF THRESHOLD VIOLATION -----------------------------------------------------------

data_tbl <- data_tbl %>%
  mutate(Richtung = case_when(
    str_detect(Aktion, ">|\\sHOCH") & !str_detect(Aktion, "TIEF") ~ "überschritten",
    str_detect(Aktion, "<|\\sTIEF|NIEDRIG") & !str_detect(Aktion, "HOCH") ~ "unterschritten"
  )) %>%
  # convert Richtung to factor
  mutate(Richtung = as.factor(Richtung))


# --------------------------------------------- ALARMPAUSES -----------------------------------------------------------

data_tbl <- data_tbl %>%
  mutate(Alarmpause = case_when(
    grepl("Pause: Alle Alarme", Aktion) ~ "Pause Ein",
    grepl("Fortsetzen: Alle Alarme", Aktion) ~ "Pause Aus"
  )) %>%
  # convert Alarmpause to factor
  mutate(Alarmpause = factor(Alarmpause, c("Pause Ein", "Pause Aus")))


# --------------------------------------------- SINGLE VS DOUBLE BEDROOMS -----------------------------------------------------------

Single <- c("V1", "W1", "I1", "B1", "D1", "M1", "O1", "E1", "H1") # Enter the Single Bed IDs

data_tbl <- data_tbl %>%
  mutate(Bettenanzahl = ifelse(Bettname %in% Single,
    "Einbettzimmer",
    "Zweibettzimmer"
  )) %>%
  mutate(Bettenanzahl = as.factor(Bettenanzahl))


# --------------------------------------------- RESPONSE TIMES TO ALARMS -----------------------------------------------------------

# Apparently duplicated entries can occur. Eg "***DISKONNEKT. PAT" seems to be stored twice when it is generated or terminated.
# They same seems to occur with "Quittieren". These duplicates will be deleted.
# Shows duplicate rows:
# dupli.data_tbl <- data_tbl[duplicated(data_tbl) | duplicated(data_tbl, fromLast = TRUE),]

# deletes duplicates
data_tbl <- distinct(data_tbl, .keep_all = TRUE)

# the data will be split according to the bed in order to calculate the time difference between alarms of the same bed only
# Because only the true time of generated alarms is known, but not the the true time of terminated alarms, the log time ("Zeit") will be used to calculate time differences.
# Inspection of the time lag shows that alarms close together in time roughly have the same amount of lag and the lag time in general does not exceed 31s

data_tbl <- data_tbl %>%
  group_by(Bettname) %>%
  arrange(Alarm, Richtung, Alarmfarbe, Zeit) %>%
  mutate(Zeitdifferenz = as.numeric(Zeit - lag(Zeit), units = "secs")) %>%
  arrange(Zeit) %>% 
  mutate(Zeitdifferenz = ifelse(Situation == "generiert" | is.na(Situation), NA, Zeitdifferenz)) %>% 
  # There are negative values for the time difference if the alarm ends don't have a matching start. These values will be deleted.
  mutate(Zeitdifferenz = ifelse(Zeitdifferenz < 0, NA, Zeitdifferenz)) %>% 
  ungroup()


# --------------------------------------------- DURATION OF ALARM PAUSES -----------------------------------------------------------

data_tbl <- data_tbl %>% 
  # A temporary "dummypause"-column is created that does not differentiate between activated and terminated pauses.
  # this allows sorting by time and calculating the time differences between the activation and termination.
  mutate(DummyPause = ifelse(!is.na(Alarmpause), "Pause", NA)) %>% 
  mutate(DummyPause = as.factor(DummyPause)) %>% 
  # As with the alarm duration, this function sorts each bed according to the time of the log entry
  # so that each terminated pause is listed right below where it was generated.
  # It then calculates the time difference between the two entries.
  group_by(Bettname) %>%
  arrange(DummyPause, Zeit) %>%
  mutate(PausenDauer = as.numeric(Zeit - lag(Zeit), units = "secs")) %>%
  arrange(Zeit) %>% 
  # deleting meaningless time differences and those longer than 190s as the longest possible pause length is 180s.
  # The cut-off is 190s, because of the lag time of the time entry.
  mutate(PausenDauer = ifelse(Alarmpause == "Pause Ein", NA, PausenDauer)) %>%
  mutate(PausenDauer = ifelse(PausenDauer > 190 | PausenDauer < 0, NA, PausenDauer)) %>% 
  select(-DummyPause) %>% 
  ungroup()
  

# --------------------------------------------- INFORMATION ON ICU SHIFTS -----------------------------------------------------------

# Shift schedule used in this case:
# Morning: 6:36-14:42
# Afternoon: 14:06-22:24
# Night: 21:51-07:09

# Handover Morning Afternoon: 14:06 - 14:42
# Handover Afternoon Night: 21:51 - 22:24
# Handover Night Morning: 6:36 - 07:09

shift_early_start <- hm("07:09")
shift_early_end <- hm("14:06")
shift_late_start <- hm("14:42")
shift_late_end <- hm("21:51")
shift_night_start <- hm("22:24")
shift_night_end <- hm("06:36")

my_timezone <- "Europe/Berlin"

data_tbl <- data_tbl %>% 
  mutate(Schicht = case_when(
    # night shift
    TrueTime < force_tz(as.Date(TrueTime, tz = my_timezone) + shift_night_end, my_timezone) |
      TrueTime >= force_tz(as.Date(TrueTime, tz = my_timezone) + shift_night_start, my_timezone) ~ "Nacht",
    # transition night > early shift
    TrueTime < force_tz(as.Date(TrueTime, tz = my_timezone) + shift_early_start, my_timezone) &
      TrueTime >= force_tz(as.Date(TrueTime, tz = my_timezone) + shift_night_end, my_timezone) ~ "NachtFrüh",
    # early shift
    TrueTime < force_tz(as.Date(TrueTime, tz = my_timezone) + shift_early_end, my_timezone) &
      TrueTime >= force_tz(as.Date(TrueTime, tz = my_timezone) + shift_early_start, my_timezone) ~ "Früh",
    # transition early > late shift
    TrueTime < force_tz(as.Date(TrueTime, tz = my_timezone) + shift_late_start, my_timezone) &
      TrueTime >= force_tz(as.Date(TrueTime, tz = my_timezone) + shift_early_end, my_timezone) ~ "FrühSpät",
    # late shift
    TrueTime < force_tz(as.Date(TrueTime, tz = my_timezone) + shift_late_end, my_timezone) &
      TrueTime >= force_tz(as.Date(TrueTime, tz = my_timezone) + shift_late_start, my_timezone) ~ "Spät",
    # transition late > night
    TrueTime < force_tz(as.Date(TrueTime, tz = my_timezone) + shift_night_start, my_timezone) &
      TrueTime >= force_tz(as.Date(TrueTime, tz = my_timezone) + shift_late_end, my_timezone) ~ "SpätNacht"
  )) %>% 
  # sorting the levels of shift intuitively
  mutate(Schicht = factor(Schicht, c("Nacht", "NachtFrüh", "Früh", "FrühSpät", "Spät", "SpätNacht")))

# cleaning the environment
rm(
  shift_early_start, shift_early_end,
  shift_late_start, shift_late_end,
  shift_night_start, shift_night_end,
  my_timezone
)


# --------------------------------------------- EXPORT -----------------------------------------------------------

save(data_tbl, file = "CleanedData.Rdata")
