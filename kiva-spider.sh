#!/bin/bash

# make folder to store loan data if does not exist
if [ ! -d "loans" ]; then
	mkdir loans
fi

# make folder to store log files if does not exist
if [ ! -d "logs" ]; then
	mkdir logs
fi

# start a log file
LOGFILE=logs/$(date +%Y-%m-%d-%H-%M-%S).log

echo "Starting to download at $(date +%Y-%m-%d\ %H:%M:%S)..." >> $LOGFILE 2>&1

# for each loan in loan-list-txt
while read LOAN; do

  echo ${LOAN} >> $LOGFILE 2>&1

  # make directory for that loan
  if [ ! -d "loans/${LOAN}" ]; then
  	mkdir loans/$LOAN
  fi

  # pull in the HTML for that loan and save with timestamp as filename
  curl -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36" -s https://www.kiva.org/lend/${LOAN} -o "loans/${LOAN}/$(date +%Y-%m-%d-%H-%M-%S).html"

  # wait before doing next curl to avoid getting blocked
  sleep 30


done < loan-list.txt # note the loan-list.txt is slurped here

echo "Download completed at $(date +%Y-%m-%d\ %H:%M:%S)" >> $LOGFILE 2>&1