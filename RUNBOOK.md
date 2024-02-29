# Runbook: Common tasks and commands


## Upload and process a CSV of enrollment data
First, get a CSV in the right format. The first two lines might look like:
```
Email,School 1,Career 1,School 2,Career 2,School 3,Career 3,Ug Social Class Long Desc,Coterm UG Group Ind,Coterm GR Group Ind,SUNet ID
glikbarg@stanford.edu,School of Engineering,Graduate,,,,,-,N,Y,glikbarg
```
Now, run `heroku exec` to open a shell on the running dyno. 
Navigate to `/import` in your browser, and upload your .csv file. It will save a copy to `storage/<file>.csv`
Once you hit upload, check it's there: `ls storage/` in the dyno shell

Now, to run rake tasks, we need to get a copy of the rails ENV:
```
set -a
source <(cat /proc/$(pgrep -f "rails server")/environ | strings)
```
This pulls the env from the rails server and applies it to your ssh shell
Now, install the new data:
```
/bin/bash -l -c "bin/rake import:enrollment_data\['storage/<file>.csv'\]"
```
This should spin for a bit, output messages about edge-case users with odd enrollment status, and conclude `Imported 16962 user records!`