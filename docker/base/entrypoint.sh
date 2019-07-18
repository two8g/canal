#!/bin/bash

# Add local admin
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

# check if a old fluent user exists and delete it
cat /etc/passwd | grep admin
if [ $? -eq 0 ]; then
    deluser admin
fi

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m admin
export HOME=/home/admin

exec /usr/local/bin/gosu admin "$@"