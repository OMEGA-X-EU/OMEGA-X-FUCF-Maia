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
cd /home/ppimenta/d4maia/Data\ exposure/Library

# start logging the execution of the script
echo "Starting Forum24dump" > log_Forum24.txt


sql="use BAZE; select device, tstamp, valor_kWh as Consumption_kWh from itgest24 where device like '%Ativa%' order by tstamp, device into outfile 'Forum24.csv_' FIELDS TERMINATED BY ',';"

echo $(date '+%Y-%m-%d %H:%M') $sql >> log_Forum24.txt	

mysql  -uppimenta -p**password** -e"use BAZE; select device, tstamp, valor_kWh as Consumption_kWh from itgest24 where device like '%Ativa%' order by tstamp, device into outfile 'Forum24.csv_' FIELDS TERMINATED BY ','" 


mv /var/lib/mysql/BAZE/Forum24.csv_ ./Forum.csv_

cat ./headITGEST24.txt ./Forum.csv_ > Forum.csv
zip -uv Forum.zip Forum.csv >> log_Forum24.txt
chown -v ppimenta Forum.zip >> log_Forum24.txt

#rm ./Forum24.csv_
rm -fv Forum.csv_ >> log_Forum24.txt
rm -fv Forum.csv >> log_Forum24.txt

message='auto '$(date '+%Y-%m-%d %H:%M')''
echo "Ending by $message" >> log_Forum24.txt

