#!/bin/bash

###############################################################################
# Description: This bash script extracts and packs Library data to be shared 
#              in the context of Omega-X project.
#
# Execution Context: Designed to be run by the root user, typically via crontab.
#
# Managed by: Pedro Pimenta
# Contact: ppimenta@cm-maia.pt / ppimenta@ipmaia.pt
# Last Updated: 2025-05-05
###############################################################################

# setting the right folder for data processing
cd "/home/ppimenta/d4maia/Data exposure/Library"

# setting the YYYY-MM-DD value of the 'previous day'
daybefore=$(date -d "yesterday" +"%Y-%m-%d")

# start logging the execution of the script
echo "Library - daybefore - extraction starting at  " $(date '+%Y-%m-%d %H:%M:%S') > log_Biblio_daybefore.txt

# removing any *.csv_ (csv_ extension is used to mark a temporary work file)
rm -f /var/lib/mysql-files/*.csv_ >> log_Biblio_daybefore.txt

# export Temperature and relative humidity (HR) from the three floors of the Library
mysql -e "use BAZE;select created as tstamp, device, Temp as Temp_C, humidade as HR_PC  from FLora 
where device like 'DLHT52%' and created like '$daybefore%' order by tstamp  
INTO OUTFILE '/var/lib/mysql-files/BiblioTemp_$daybefore.csv_' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n';" -uppimenta -p**password** >> log_Biblio.txt

# adding the title row to the exported values and output to the full formatted .csv file
cat ./headBiblioTemp.txt /var/lib/mysql-files/BiblioTemp_$daybefore.csv_ > ./BiblioTemp_$daybefore.csv

# zipping the csv file 
zip -v BiblioTemp_$daybefore.zip BiblioTemp_$daybefore.csv >> log_Biblio_daybefore.txt

# updating the ownership of file
chown -v ppimenta BiblioTemp_$daybefore.zip >> log_Biblio_daybefore.txt

# removing temporary files
rm -fv BiblioTemp_$daybefore.csv >> log_Biblio_daybefore.txt
rm -fv /var/lib/mysql-files/BiblioTemp_$daybefore.csv_ >> log_Biblio_daybefore.txt

# export meteorological environmental - Temperature, relative humidity and solar radiation - variables 
mysql -e "use BAZE;select data as tstamp, temp as Temp_C, humidade as HR_PC, radiacao as Rad_W_m2 from baze21r
where fonte='Itecons'
and data like  '$daybefore%' order by tstamp
INTO OUTFILE '/var/lib/mysql-files/Enviro_$daybefore.csv_' FIELDS TERMINATED BY ',' LINES TERMINATED BY '\r\n';" -uppimenta -p**password**

# adding the title row to the exported values and output to the full formatted .csv file
cat ./headEnviro.txt /var/lib/mysql-files/Enviro_$daybefore.csv_ > ./Enviro_$daybefore.csv

# zipping the csv file 
zip -v Enviro_$daybefore.zip Enviro_$daybefore.csv >> log_Biblio_daybefore.txt

# updating the ownership of file
chown -v ppimenta Enviro_$daybefore.zip >> log_Biblio_daybefore.txt

# removing temporary files 
rm -fv Enviro_$daybefore.csv >> log_Biblio_daybefore.txt
rm -fv /var/lib/mysql-files/Enviro_$daybefore.csv_ >> log_Biblio_daybefore.txt

# logging 
echo "Biblio24 daybefore extraction ended at  " $(date '+%Y-%m-%d %H:%M:%S')   >> log_Biblio_daybefore.txt
