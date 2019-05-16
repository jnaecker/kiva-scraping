## Kiva scraping

To get started, run `crontab cron-job-local.txt` if on my local machine, or `crontab cron-job-remote.txt` if on my server.

To download data from server, run `rsync -rchavzP --stats jnaecker@swallowtail.wesleyan.edu:~/kiva-scraping/data .`.