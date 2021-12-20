#!/usr/bin/env bash

#==============================================================#
# File      :   install
# Ctime     :   2021-11-30
# Mtime     :   2021-11-30
# Desc      :   vastbase G100  inspection script
# Path      :   install
# Depend    :   .pgpass
# Author    :   Alice bat 
#==============================================================#


##安装目录
os_home=$1
vb_home=$2
vb_data=$3
db_port=$4 
db_user=$5

#Path 
if [[ ! -d ${os_home}/soft ]]
then
    echo "`date '+%Y-%m-%d %H:%M:%S '` ERROR: The dir_backup is not exist"
	exit 1
else 
    echo "`date '+%Y-%m-%d %H:%M:%S '` succeed: The dir_backup is  exist"
    ls ${os_home}/soft/*gz  
    if [[ $? -eq 0  ]]
    then
        echo  "`date '+%Y-%m-%d %H:%M:%S '`   The install packages is exist"
    else
        echo "`date '+%Y-%m-%d %H:%M:%S '` ERROR The install packages not exist"
        exit 2
    fi
fi 
cd ${os_home}/soft
if [[ ! -d ${os_home}/soft/vastbase-installer ]]
then
    rm -rf ${os_home}/soft/vastbase-installer
fi
tar -xf ${os_home}/soft/*.tar.gz 
cd ${os_home}/soft/vastbase-installer
tar -xf  *.tar.gz

if [[ ! -d  ${vb_home} ]]
then
    echo "`date '+%Y-%m-%d %H:%M:%S '` ERROR: The install home  is not exist mkdir dir"
    mkdir ${vb_home}
fi 

tar -xf *.tar.bz2 -C  ${vb_home}

echo  "export PGPORT=${db_port}
export PGUSER=${db_user}
export PGDATA=${vb_data}
export GAUSSHOME=${vb_home}
export LD_LIBRARY_PATH=${vb_home}/lib:${vb_home}/jre/lib/amd64:${vb_home}/jre/lib/amd64/server:$LD_LIBRARY_PATH
export PATH=${vb_home}/om/script/gspylib/pssh/bin:${vb_home}/om/script:${vb_home}/bin:/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin
export PGENCRYPTIONKEY=1qaz!QAZ
export OM_GPHOME=${vb_home}/om
export LD_LIBRARY_PATH=${vb_home}/lib:$LD_LIBRARY_PATH
export PYTHONPATH=${vb_home}/lib
export OM_GAUSS_VERSION=2.0.0
export OM_PGHOST=${vb_data}/tmp
export OM_GAUSSLOG=${vb_data}/tmp
export OM_GAUSS_ENV=2
export OM_GS_CLUSTER_NAME=dbCluster
" > ${os_home}/.Vastbase

echo "source /home/vastbase/.Vastbase" >>${os_home}/.bashrc

source ${os_home}/.bashrc

if  [[ ! -d  ${vb_data} ]]
then
    rm -rf ${vb_data}
fi 
${vb_home}/bin/vb_initdb -D ${vb_data} --nodename='vdb' -E UTF-8 --locale=en_US.UTF-8 