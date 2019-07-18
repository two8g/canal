#!/bin/bash

current_path=`pwd`
case "`uname`" in
    Darwin)
        bin_abs_path=`cd $(dirname $0); pwd`
        ;;
    Linux)
        bin_abs_path=$(readlink -f $(dirname $0))
        ;;
    *)
        bin_abs_path=`cd $(dirname $0); pwd`
        ;;
esac
BASE=${bin_abs_path}

if [ "$1" = "base" ] ; then
    docker build --no-cache -t canal/osbase $BASE/base
else
    rm -rf $BASE/canal.*.tar.gz ;
    cd $BASE/../ && mvn clean package -Dmaven.test.skip -Denv=release
fi

if [ "$1" = "adapter" ] ; then
    cd $current_path/adapter;
    cp -r $BASE/image/ $current_path/adapter
    cp $BASE/../target/canal.adapter-*.tar.gz $current_path/adapter
    docker build -t canal/canal-adapter $current_path/adapter
    rm -f canal.adapter-*.tar.gz
    rm -rf image
else
    cd $current_path;
    cp $BASE/../target/canal.deployer-*.tar.gz $BASE/
    docker build --no-cache -t canal/canal-server $BASE/
    rm -f canal.deployer-*.tar.gz
fi
