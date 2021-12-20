#!/usr/bin/env bash


#==============================================================#
# File      :   db start
# Ctime     :   2021-12-2
# Mtime     :   2021-12-2
# Desc      :   vastbase G100  inspection script
# Path      :   start
# Depend    :   数据库启动脚本
# Author    :   Alice bat 
#==============================================================#
user=$1
data_path=$2
log_file=$3

su - ${user} -c "source /home/${user}/.Vastbase && vb_ctl start -D ${data_path} -l ${log_file}" >/dev/null
if [ $? == 0 ]
then
        echo "vastbase start:success"
else
        #打印最后20行日志
        tail -n 20 ${log_file}
        echo "数据库启动失败，详细请查看日志文件:${log_file}"
        echo "vastbase start:false"
fi
