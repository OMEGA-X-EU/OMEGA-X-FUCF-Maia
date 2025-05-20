#!/bin/bash

################################################################################################################
# Description: This bash script syncs the github private repo https://github.com/pedroccpimenta/OmegaX-Maia
#              and pushes the newly created files *daybefore*.
#
# Execution Context: Designed to be run by the root user, typically via crontab.
#
# Managed by: Pedro Pimenta
# Contact: ppimenta@cm-maia.pt / ppimenta@ipmaia.pt
# Last Updated: 2025-05-05
################################################################################################################


daybefore=$(date -d "yesterday" +"%Y-%m-%d")

# Log start
echo "PPTorre daybefore starting at  " $(date '+%Y-%m-%d %H:%M:%S')   > log_github_daybefore.txt

# Log actual status of the repository
echo "=== git status" >> log_github_daybefore.txt
git status >> log_github_daybefore.txt

# pull any change
echo "=== git pull" >> log_github_daybefore.txt
git pull >> log_github_daybefore.txt

# Log actual status of the repository
echo "=== git status" >> log_github_daybefore.txt
git status >> log_github_daybefore.txt

# Add new files just extracted
echo "=== git add ." >> log_github_daybefore.txt
git add . >>  log_github_daybefore.txt

# commit new files
echo "=== git commit" >> log_github_daybefore.txt
git commit -m ":dizzy: updating data from $daybefore" >> log_github_daybefore.txt

# push changes to github
echo "=== git push" >> log_github_daybefore.txt
git push >> log_github_daybefore.txt

#  log the end of the script
echo "PPTorre daybefore ending at  " $(date '+%Y-%m-%d %H:%M:%S')   >> log_github_daybefore.txt
