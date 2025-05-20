#!/bin/bash

###############################################################################
# Description: This bash script extracts and packs PTT data to be shared in the
#              context of Omega-X project.
#
# Execution Context: Designed to be run by the root user, typically via crontab.
#
# Managed by: Pedro Pimenta
# Contact: ppimenta@cm-maia.pt / ppimenta@ipmaia.pt
# Last Updated: 2025-05-05
###############################################################################

# setting the right folder for data processing
cd "/home/ppimenta/d4maia/Data exposure/PTTorre/"

# list of device names to be extracted
bte=(   'InformÃ¡tica' 
        'Master'  'ParqueInterior'  'ParqueExterior'
        'TorreLidador'
        'PaÃ§osConcelho'
   )

# start logging the execution of the script
echo "PPTorre extraction starting at  " $(date '+%Y-%m-%d %H:%M:%S')   > log_PTTorre_daybefore.txt

# removing any *.csv_ (csv_ extension is used to mark a temporary work file)
rm -f /var/lib/mysql-files/*.csv_  >> log_Biblio_daybefore.txt

# setting the YYYY-MM-DD value of the 'previous day'
daybefore=$(date -d "yesterday" +"%Y-%m-%d")

# logging the date under extraction
echo "Yesterday's date was: $daybefore"

# building the sql command to extract data for all the devices in the PTT family
sqlcmd="use BAZE;select device,tstamp,dstamp,CurrL1,CurrL2,CurrL3,ActPow,AppPow,ReacPow, Energy,VolL1,VolL2,VolL3, THDUL1,THDUL2,THDUL3,THDIL1,THDIL2,THDIL3,cosphi from PTTorre  
where tstamp like '$daybefore%' order by tstamp  INTO OUTFILE '/var/lib/mysql-files/AllDevs$daybefore.csv_' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n';"

#logging the sql command to be used
echo "cmd $sqlcmd"
echo " "

# issuing the command to mysqldump the values
echo **password** | mysql -e "use BAZE;select device,tstamp,dstamp, CurrL1,CurrL2,CurrL3,ActPow,AppPow,ReacPow, Energy,VolL1,VolL2,VolL3, 
THDUL1,THDUL2,THDUL3,THDIL1,THDIL2,THDIL3,cosphi from PTTorre  where tstamp like '$daybefore%' order by tstamp  
INTO OUTFILE '/var/lib/mysql-files/AllDevs_$daybefore.csv_' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n';" -uppimenta -**password** 
echo " "

# adding the title row to the exported values and output to the full formatted .csv file
cat ./headPTTMaster.txt /var/lib/mysql-files/AllDevs_$daybefore.csv_ > ./PTT_daybefore/AllDevs_$daybefore.csv 

# zipping the csv file in the destination folder `PTT_daybefore`
zip -j ./PTT_daybefore/AllDevs_$daybefore.zip   ./PTT_daybefore/AllDevs_$daybefore.csv 

# Semantisaton
python3 Semantify_PTT_daybefore.py >> log_PTTorre_daybefore.txt

# zipping the ttl file in ttl.zip file in the destination folder `PTT_daybefore`
zip -j ./PTT_daybefore/AllDevs_$daybefore.ttl.zip   ./PTT_daybefore/AllDevs_$daybefore.ttl 

# removing temporary files 
rm -f /var/lib/mysql-files/AllDevs_$daybefore.csv_ 

# updating the ownership of destination folder / recursive to all files
chown -R ppimenta  PTT_daybefore 

# logging 
echo "PTT extraction ended at  " $(date '+%Y-%m-%d %H:%M:%S')   >>  log_PTTorre_daybefore.txt
