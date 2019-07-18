#!/bin/bash


# Add local admin
# Either use the LOCAL_USER_ID if passed in at runtime or
# fallback

USER_ID=${LOCAL_USER_ID:-9001}

# check if a old fluent user exists and delete it
cat /etc/passwd | grep admin
if [ $? -eq 0 ]; then
    userdel admin
fi

echo "Starting with UID : $USER_ID"
useradd --shell /bin/bash -u $USER_ID -o -c "" -m admin
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