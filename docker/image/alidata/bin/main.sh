#!/bin/bash


# Add local admin
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${UID:-1000}
GROUP_ID=${GID:-1000}

# check if a old fluent user exists and delete it
cat /etc/passwd | grep admin
if [ $? -eq 0 ]; then
    userdel admin
fi

cat /etc/group | awk -F ':' '{print $1}' | grep admin
if [ $? -eq 0 ]; then
    groupdel admin
fi

echo "Starting with UID : $USER_ID"
useradd -u $USER_ID -o -c "" -m admin
echo "Starting with GID : GROUP_ID"
groupadd -g $GROUP_ID -o admin
export HOME=/home/admin
chown -R admin:admin /home/admin

[ -n "${DOCKER_DEPLOY_TYPE}" ] || DOCKER_DEPLOY_TYPE="VM"
echo "DOCKER_DEPLOY_TYPE=${DOCKER_DEPLOY_TYPE}"

# run init scripts
for e in $(ls /alidata/init/*) ; do
	[ -x "${e}" ] || continue
	echo "==> INIT $e"
	$e
	echo "==> EXIT CODE: $?"
done

echo "==> INIT DEFAULT"
service sshd start
service crond start

#echo "check hostname -i: `hostname -i`"
#hti_num=`hostname -i|awk '{print NF}'`
#if [ $hti_num -gt 1 ];then
#    echo "hostname -i result error:`hostname -i`"
#    exit 120
#fi

echo "==> INIT DONE"
echo "==> RUN ${*}"

exec /usr/local/bin/gosu admin "$@"