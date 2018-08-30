#!/bin/bash
# look at loan matching status over time

# detect match or not in each html page
grep -R "matching-message" loans/* > loans_matches.txt
grep -R --files-without-match "matching-message" loans/* > loans_nomatches.txt

# print out timeline matched or not
cat loans_matches.txt loans_nomatches.txt | sort | sed 's/<div class="matching-message">/match on/' > loans_status_timeline.txt
cat loans_status_timeline.txt

# print out summary of ammount of time matched or not
cat loans_matches.txt loans_nomatches.txt | sort | sed 's/<div class="matching-message">/match on/' | sed 's/:/\//' | cut -d'/' -f2,4 | uniq -c > loans_status_summary.txt
cat loans_status_summary.txt

