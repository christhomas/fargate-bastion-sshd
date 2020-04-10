#!/bin/sh

export JSON_KEYS=$(echo ${PUBLIC_KEYS} | base64 -d)

echo -e "\nProcessing Keys from Environment"
for key in $(echo "${JSON_KEYS}" | jq -r '.[]'); do
  echo $key | base64 -d >> ~/.ssh/authorized_keys
done

echo -e "\nShowing all keys"
cat ~/.ssh/authorized_keys

echo -e "\nExecuting command '$@'"
exec $@
