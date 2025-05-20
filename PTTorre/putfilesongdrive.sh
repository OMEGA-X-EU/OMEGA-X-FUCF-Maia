#!/bin/bash


daybefore=$(date -d "yesterday" +"%Y-%m-%d")

cd "/home/ppimenta/d4maia/Data exposure/PTTorre/"

python3 Semantify_PTT_daybefore.py >> log_PTTorre_daybefore.txt

zip -j ./PTT_daybefore/AllDevs_$daybefore.ttl.zip   ./PTT_daybefore/AllDevs_$daybefore.ttl 


python3 putfilesongdrive.py >> log_PTTorre_daybefore.txt

cd "/home/ppimenta/d4maia/Data exposure/Library"

python3 putfilesongdrive.py >> log_Library_daybefore.txt
