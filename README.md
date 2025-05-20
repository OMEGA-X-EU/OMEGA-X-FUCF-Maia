# OMEGA-X-FUCF-Maia
Scripts developed by UMaia in the context of Omega-X Flexibility Use Case Family

## Summary
This repository shares a set of scripts setup in the pilot for Maia Municipality Flexibility use case in the context of Omega-X project ([www.omega-x.eu](www.omega-x.eu)).

Is this pilot, Maia Municipality provides data from two different settings, viz:

1. PTT - Secondary substation of "Torre do Lidador"
	This setup features a private secondary substation with direct grid power, where five downstream circuits are monitored in real-time at 20-second intervals. The data includes the latest triphasic current and voltage readings, active and apparent power, and energy consumption. The most recent data and further details are available here: [https://baze.cm-maia.pt/BaZe/PTTorre.htm](https://baze.cm-maia.pt/BaZe/PTTorre.htm);

   and

2. HVAC - HVAC and meteorological data from 'Forum' public library 
	This dataset encompasses a three-stage library HVAC system (internal temperatures, relative humidity, heat pump operation) alongside environmental meteorological conditions such as temperature, relative humidity, and solar radiation.

This repository shares a set of scripts (bash and python) that illustrates how the data was extracted from the data lake and made available to the Sovity data connector ([sovity.com](sovity.com)) used in the Omega-X project.

## Data sources and database tables

The data originates from a diverse array of sensors, including: i) a meteorological station (connected via hardwired Ethernet), ii) two power meter installations (also connected via hardwired Ethernet), and iii) temperature and relative humidity (HR) sensors utilizing LoRaWAN technology.

In line with the data lake architecture and data management practices, data, retaining its characteristic granularity, is stored in specific tables categorized by its data source family, as follows:

1. Data from the secondary substation (PTT) is stored in `` (every 20 secs)
2. Data from the meteorological station is stored in `baze21r` every 15 mins - for the sake of this study, we are considering tstamp, Temperature, solar radiation and relative humidity;
3. Data from the HVAC system is stored in `itgest24` (every 3 mins) - 
4. Data from the temperature / RH in the three floors of the Library is stored in `` (every )

## Data extraction and github repository update

All the process is managed at `root` crontab level as follows (cf [crontab.txt](crontab.txt)):
```bash 
# Daily updates in the context of Omega-X project 

# exports previous day of PTT - csv, ttl and zip formats
1 1 * * * source "/home/ppimenta/d4maia/Data exposure/PTTorre/PTTLidador_daybefore.sh" &> ~ppimenta/log_PTTLidador_daybefore.txt 

# exports Library internal temperature (three floors) and environmental meteorological conditions
3 1 * * * source "/home/ppimenta/d4maia/Data exposure/Library/Bibliotv24_daybefore.sh" &> ~ppimenta/log_Bib24_and_meteo.txt

# exports HVAC data (HVAC is exported as the whole series, not the 'previous day')
5 1 * * * source "/home/ppimenta/d4maia/Data exposure/Library/Forum24.sh" &> ~ppimenta/log_Forum24.txt 

# syncs and push new data to 
30 1 * * * source "/home/ppimenta/d4maia/Data exposure/ghub_daybefore.sh" &> ~ppimenta/log_ghub_sync_push.txt
```

## data extraction

Data extraction is performed by [PTTLidador_daybefore.sh](PTTLidador_daybefore.sh), [Bibliotv24_daybefore.sh](Bibliotv24_daybefore.sh) and [Forum24.sh](Forum24.sh).

Please note the additional step in [PTTLidador_daybefore.sh](PTTLidador_daybefore.sh) to prepare the data in turtle (ttl) format:

```bash
# Semantisaton
python3 Semantify_PTT_daybefore.py >> log_PTTorre_daybefore.txt

# zipping the ttl file in ttl.zip file in the destination folder `PTT_daybefore`
zip -j ./PTT_daybefore/AllDevs_$daybefore.ttl.zip   ./PTT_daybefore/AllDevs_$daybefore.ttl 

```
## semantisation

The semantisiaton of the PTT data is performed by a script [Semantify_PTT_daybefore.py](Semantify_PTT_daybefore.py) based on template provided by Fatma Zohra HANNOU (fatma-zohra.hannou@edf.fr).

## github repository updating

The final step is the syncronization of the repository and the pushing of the newly extracted data as detailed in [ghub_daybefore.sh](ghub_daybefore.sh)

## example of the execution of the last script

Next lines show an example of the run of the [ghub_daybefore.sh](ghub_daybefore.sh) script:
```
Github sync daybefore starting at   2025-05-19 01:30:21
=== git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   Library/Forum.zip

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	Library/Library_daybefore/BiblioTemp_2025-05-18.zip
	Library/Library_daybefore/Enviro_2025-05-18.zip

no changes added to commit (use "git add" and/or "git commit -a")
=== git pull
Already up to date.

=== git status
On branch master
Your branch is up to date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   Library/Forum.zip
	modified:   PTT_daybefore/AllDevs_daybefore.ttl.zip
	modified:   PTT_daybefore/AllDevs_daybefore.zip

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	Library/Library_daybefore/BiblioTemp_2025-05-18.zip
	Library/Library_daybefore/Enviro_2025-05-18.zip
	PTT_daybefore/AllDevs_2025-05-18.ttl.zip
	PTT_daybefore/AllDevs_2025-05-18.zip

no changes added to commit (use "git add" and/or "git commit -a")
=== git add .
=== git commit
[master 85bfef1a] :dizzy: updating data from 2025-05-18
 7 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 Library/Library_daybefore/BiblioTemp_2025-05-18.zip
 create mode 100644 Library/Library_daybefore/Enviro_2025-05-18.zip
 create mode 100644 PTT_daybefore/AllDevs_2025-05-18.ttl.zip
 create mode 100644 PTT_daybefore/AllDevs_2025-05-18.zip
 rewrite PTT_daybefore/AllDevs_daybefore.ttl.zip (98%)
 rewrite PTT_daybefore/AllDevs_daybefore.zip (98%)
=== git push
PPTorre daybefore ending at   2025-05-19 01:30:35
```

Pedro Pimenta, May 2025

