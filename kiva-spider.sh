#!/bin/bash

# variables
DATADIR=data
LOGFILE=logfile.log


# make folder to store loan data if does not exist
if [ ! -d "$DATADIR" ]; then
	mkdir $DATADIR
fi

# make place to store logs if does not exist
if [ ! -f "$LOGFILE" ]; then
	touch $LOGFILE
fi

echo "Starting to download at $(date +%Y-%m-%d\ %H:%M:%S)..." >> $LOGFILE 2>&1

# pull in the JSON and save with timestamp as filename
curl \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"query": "{lend {loans(filters: {status: fundRaising}, limit:1000) {values { id isMatchable status fundraisingDate plannedExpirationDate loanAmount loanFundraisingInfo {fundedAmount} sector {id} borrowerCount}}}}"}' \
    -o "$DATADIR/$(date +%Y-%m-%d-%H-%M-%S).json" \
    https://api.kivaws.org/graphql

echo "Download completed at $(date +%Y-%m-%d\ %H:%M:%S)" >> $LOGFILE 2>&1