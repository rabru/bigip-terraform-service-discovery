#!/bin/bash

exec 2>/dev/null

echo "`date +"%T"` - Block until BIG-IP is ready"
# CHECK IF BIGIP IS READY
CNT=0
while true
do
  STATUS=$(curl -k -u $1:$2 --connect-timeout 6 -X GET https://$3/mgmt/tm/sys/ready/stats | sed -e 's/,/\n/g' | grep -c yes)
  if [[ $STATUS == 3 ]]; then
    echo "`date +"%T"` - Got all Services up. BIGIP is Ready!"
    break
  elif [ $CNT -le 18 ]; then
    echo "`date +"%T"` - BIG-IP not ready yet..."
    CNT=$[$CNT+1]
  else
    echo "`date +"%T"` - GIVE UP..."
    break
  fi
  sleep 10
done

