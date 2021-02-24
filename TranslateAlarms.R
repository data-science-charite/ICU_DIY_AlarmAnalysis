
# ----- Translate German alarm names to English for plotting
library(plyr)
AlarmFreqColor$Alarm <- 
  revalue(AlarmFreqColor$Alarm, c("ABP Bereich?"="ABP range?", "ABPunterbrochn"="ABP interupted", "AF.high" = "RR.high", "AF.low" = "RR.low",
                                "*ALLG. ALARM" = "*GENERIC ALARM", "Apnoe" = "Apnea", "*APNOE" = "*APNEA", "Asystolie" = "Asystole", "*CO2 TIEF/HOCH" = "*CO2 LOW/HIGH",
                                "*DISKONNEKT. PAT" = "*DISCON.PAT", "*DISKONNEKT.VENT" = "*DISCON.VENT", "*DRUCK ZU HOCH" = "*PRESSURE HIGH", "EKG Elektrdn ab" = "ECG Lead off",
                                "HF.high" = "HR.high", "*FREQUENZ" = "*FREQUENCY",
                                "HF.low" = "HR.low", "*MINVOL ZU HOCH" = "MINVOL HIGH", "*MINVOL ZU TIEF" = "*MINVOL LOW", "*PEEP VERLUST" = "*PEEP LOSS",
                                "THaut" = "TSkin", "TKern" = "Tcore", "*DRUCK" = "*PRESSURE"))

AlarmFreq$Alarm <- 
  revalue(AlarmFreq$Alarm, c("ABP Bereich?"="ABP range?", "ABPunterbrochn"="ABP interupted", "AF.high" = "RR.high", "AF.low" = "RR.low",
                                "*ALLG. ALARM" = "*GENERIC ALARM", "Apnoe" = "Apnea", "*APNOE" = "*APNEA", "Asystolie" = "Asystole", "*CO2 TIEF/HOCH" = "*CO2 LOW/HIGH",
                                "*DISKONNEKT. PAT" = "*DISCON.PAT", "*DISKONNEKT.VENT" = "*DISCON.VENT", "*DRUCK ZU HOCH" = "*PRESSURE HIGH", "EKG Elektrdn ab" = "ECG Lead off",
                                "HF.high" = "HR.high", "*FREQUENZ" = "*FREQUENCY",
                                "HF.low" = "HR.low", "*MINVOL ZU HOCH" = "*MINVOL HIGH", "*MINVOL ZU TIEF" = "*MINVOL LOW", "*PEEP VERLUST" = "*PEEP LOSS",
                                "THaut" = "TSkin", "TKern" = "Tcore", "*DRUCK" = "*PRESSURE"))

detach("package:plyr", unload=TRUE)
