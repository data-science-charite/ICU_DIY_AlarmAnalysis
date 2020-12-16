# DIY Analysis of ICU Alarm Data

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.4328371.svg)](https://doi.org/10.5281/zenodo.4328371)

**This repository accompanies the following Publication:**

> Poncette, A.S., Wunderlich, M.M., Spies, C., Heeren, P., Vorderwülbecke, G., Salgado, E., Kastrup, M., Feufel, M. and Balzer, F. (2020). *Patient Monitoring Alarms of an Intensive Care Unit: Observational Study with DIY Instructions* [Manuscript submitted for publication]. Department of Anesthesiology and Intensive Care Medicine, Charité – Universitätsmedizin Berlin, Corporate Member of Freie Universität Berlin, Humboldt-Universität zu Berlin, and Berlin Institute of Health, Berlin, Germany.

**The clinical audit logs** were manually collected from the patient monitoring system of a 21-bed intensive care unit (ICU)
from a large German hospital via USB stick from the central patient monitoring device three times during 2019 (in winter, summer and autumn).
The patient monitoring and alarm system used at the time of the study was the Philips IntelliVue patient monitoring system (MX800 software version M.00.03; MMS X2 software version H.15.41-M.00.04)

The data consists of the time, bed number, alarm type (i.e., parameter, device, alarm criticality) and alarm handling (e.g., threshold adjustments,
use of the pause function). In total, data span 93 calendar days. No actual patient identifying data elements were collected.
For further deidentification, dates were shifted into the future by a pseudo-random offset for all patients; the bed number was replaced by a pseudonym.
Day and night rhythm, weekends, the season and the bed characteristic (double room, single room) were not affected by this process.

We provide the fully annotated R scripts that we used to conduct the alarm data analysis to enable even beginners in R to do likewise.
Further explanations can be found in the results section of the accompanying publication and in the scripts.
The R-Markdown file can be used to create comprehensive alarm reports.

**To replicate the results** from the publication, simply clone this repository into your environment and run the R-Markdown file `AlarmAnalysis.Rmd`. If you would like to analyze and report your own Philips IntelliVue patient monitoring alarm log data, (1) run `DIY_Cleaning.R` with the filepath to your exported CSV-file. Minor tweaks on (e.g.) the alarm regex might be needed, so make sure to double check the exported data. (2) Run the `AlarmAnalysis.Rmd` with the file path to the cleaned data from step 1. Enter the necessary information requested in the code and adjust ggplot parameters as needed.
