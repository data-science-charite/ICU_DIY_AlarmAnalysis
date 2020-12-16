# Some alarms not assigned to groups so far, because they are too rare (ZVD Bereich?, ZVDs, ZVDm, etCO2, BIS, Ps, awAF) or were detected
# in data analyses after the one of the publication.

ventilator_alarms <<- c(
  "OPERATOR",
  "MINVOL",
  "MinVol",
  "FREQUENZ",
  "ALLG. ALARM",
  "PEEP-VERLUST",
  "DISKONNEKT. PAT",
  "DRUCK",
  "APNOE",
  "APNOE VENTILAT.",
  "DISKONNEKT.VENT",
  "GASVERSORGUNG",
  "PEEP",
  "CO2 TIEF/HOCH",
  "AFaw",
  "awP",
  "FIO2",
  "FIO2 TIEF/HOCH",
  "TV",
  "DRUCK TV-LIMIT",
  "TV NICHT KONST.",
  "VENT SCHLAUCH?",
  "SPO2 TIEF/HOCH",
  "FREQ",
  "HIGH RESP RATE",
  "APNEA",
  "LOW EXH MV",
  "EIN DRUCK UNT",
  "PROX D UNT",
  "HIGH EXH TV",
  "I TIME TOO LONG",
  "HIGH PEEP",
  "PROX DISC/OCCL",
  "FLOW SENSOR?"
)

NIBP <<- c("NBPm", "NBPs", "NBPd")

IBP <<- c(
  "ABPs",
  "ABPm",
  "ABPunterbrochn",
  "ABP Bereich?",
  "ABPd",
  "ARTs",
  "ARTm",
  "ARTd",
  "ARTunterbrochn",
  "ART Bereich?",
  "P Bereich?",
  "PAPs",
  "PAP Bereich?",
  "PAPunterbrochn",
  "UAP Bereich?",
  "UAPs"
)

EKG <<- c(
  "AF",
  "HF",
  "HF unregelmaessig",
  "Vent Fib/Tachy",
  "Asystolie",
  "xBrady",
  "VTachy",
  "xTachy",
  "AFIB",
  "VES-Paar",
  "Multiform VES",
  "QRS ausgelassen",
  "Apnoe",
  "Apnoe > 10min",
  "Vent ALARM",
  "Vent STANDBY",
  "Paroxysmale VT",
  "VES-Salve Hoch",
  "VES/min",
  "Ende:Unregelm.HF",
  "ST-I",
  "Pause"
)

TEMP <<- c("TKern", "THaut", "TBlut", "Temp")

intracranial_pressure <<- c("ICPm", "ICP Bereich?", "ICPs", "ICPd", "CPP")

pulse_oximetry <<- c("Desat", "Puls", "SpO2", "SpO2po", "SpO2r", "SpO2l")

tech_fail <<- c(
  "SL-Verbindg pruefn",
  "AkkErw Fehler",
  "AkkErw fehlt",
  "AkkErw schwach",
  "AkkErw leer",
  "Akku einlegen",
  "Akku leer",
  "Akku schwach",
  "Fehler Akku Erw.",
  "EKG Elektrdn ab",
  "Pat.-ID ueberpruef",
  "MSL-Verbindung?",
  "Fehler: Akku-Erw."
)

Thermodilution <<- c("kHI")

NOT_ASSIGNED <<- c(
  "IC1m",
  "IC1 Bereich??",
  "imCO2",
  "ICPd", "Trekt",
  "PT ANSCHL UNT",
  "VT NIED",
  "VT HOCH",
  "AUS MV NIED",
  "P unterbrochn",
  "T1",
  "Pm",
  "PT. DISCONNECT",
  "THirn",
  "ST Kombi II aVF",
  "Toeso",
  "ST-V",
  "Tvesik",
  "Vent PRÜFEN",
  "ST MCL",
  "Tnaso",
  "Manschtte hat Luft",
  "Pacer defekt",
  "ZVD Bereich?",
  "ZVDs",
  "ZVDm",
  "etCO2",
  "BIS",
  "Ps",
  "awAF"
)