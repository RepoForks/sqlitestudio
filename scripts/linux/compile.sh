#!/bin/bash

if [ "$1" == "" ]; then
    QMAKE=`which qmake`
    if [ "$QMAKE" == "" ]; then
	echo "Cannot find qmake"
	exit 1
    else
	read -p "Is this correct qmake (y/N) $QMAKE : " yn
	case $yn in
	    [Yy]* ) ;;
	    * ) echo "Please pass path to correct qmake as argument to this script."; exit;;
	esac
    fi
else
    QMAKE=$1
fi

cdir=`pwd`
cpu_cores=`grep -c ^processor /proc/cpuinfo`
absolute_path=`realpath $0`
this_dir=`dirname $absolute_path`
this_dir=`dirname $this_dir`
parent_dir=`dirname $this_dir`

read -p "Number of CPU cores to use for compiling (hit enter to use $cpu_cores): " new_cpu_cores
case $new_cpu_cores in
    "" ) ;;
    * ) cpu_cores=$new_cpu_cores ;;
esac

if [ -d $parent_dir/output ]; then
	read -p "Directory $parent_dir/output already exists. The script will delete and recreate it. Is that okay? (y/N) : " yn
	case $yn in
	    [Yy]* ) rm -rf $parent_dir/output ;;
	    * ) echo "Aborted."; exit;;
	esac
fi

cd $parent_dir
mkdir output output/build output/build/Plugins

cd output/build
$QMAKE CONFIG+=portable ../../SQLiteStudio3
make -j $cpu_cores

cd Plugins
$QMAKE CONFIG+=portable ../../../Plugins
make -j $cpu_cores

cd $cdir
