#!/bin/bash

#==============================================================#
# File      :   vastbase_g100_backup
# Ctime     :   2021-12-29
# Mtime     :   2021-12-29
# Desc      :   vastbase G100   back up script
# Path      :   vastbase_g100_backup.sh
#Description: 	backup db
# Author    :   Alicebat 
#==============================================================#

#==============================================================#
# const
#==============================================================#
# Aliceauto version string
#version: V1.0



# =====================================================================
# 描述本脚本为备份脚本主要模块包括：
#  1.收集备份策略
#  2.设置备份脚本
#  3.制定定时任务
#======================================================================


#==============================================================#
# environment
#==============================================================#
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|">>back_info_`date +%Y-%m-%d`.log
echo "|                      收集备份策略                        |">>back_info_`date +%Y-%m-%d`.log
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|">>back_info_`date +%Y-%m-%d`.log

#请将如下变量按照对应环境设置，可有两种方式输入：1：手动输入 2：交互输入
#备份目录
back_home='/bes/non_vb_backup/'
#备份实例名
back_instance='non_vastdatabackup'
#备份数据目录
back_data='/data/vastdata/'
#备份用户
back_user='backup'
#备份用户密码
back_pass='Vbase@admin'
#备份数据库端口
db_port_back='15432'
#备份数据库名
db_database='vastbase'
#如果远程备份请输入：
#远程备份IP
IP_back='10.195.26.12'

#远程备份OS用户
os_back='vastbase'
#远程安装目录
home_back='/home/vastbase/local/vastbase/bin/'




#==============================================================#
#                             Usage                            #
#==============================================================#

function help() {
	cat <<-'EOF'
脚本适配环境：
	    OS：CentOS7.4  openEuler 20.03 (LTS)
		数据库：V2.2.5
		执行分为本地和远程
		本地执行
			1. 全备  ./vastbase_g100_backup.sh local  full
			2. 增量  ./vastbase_g100_backup.sh local  ptrack
		远程执行
			1. 全备  ./vastbase_g100_backup.sh ssh  full
			2. 增量  ./vastbase_g100_backup.sh ssh  ptrack
	EOF
}


function ssh() {
	cat <<-'EOF'
vb_probackup 远程备份需要备份服务器设置ssh 免密
		ssh-keygen 
		ssh-copy-id 10.105.25.11
		ssh-copy-id 10.105.25.12
		ssh-copy-id 10.105.25.13
	EOF
}

#初始化备份
#vb_probackup init -B /bes/non_vb_backup/
#添加实例
#vb_probackup add-instance -B /bes/non_vb_backup/ -D /data/vastdata/ --instance=non_vastdatabackup --remote-host=10.195.26.12 --remote-port=22 --remote-proto=ssh --remote-path=/home/vastbase/local/vastbase/bin --remote-user=vastbase
#设置全局保留策略
#vb_probackup set-config  -B  $back_home --instance=${back_instance} --retention-redundancy=4 --retention-window=30


#本地全备
back_local_full(){
	echo "执行本地全备：date +%Y-%m-%d-%H-%M-%S " >>back_info_`date +%Y-%m-%d`.log
	vb_probackup backup -B $back_home --instance=${back_instance} -b f -D ${back_data} -U $back_user -W  $back_pass -d ${db_database}>> back_info_`date +%Y-%m-%d`.log 2>&1

}

#本地增量
back_local_ptrack(){
	echo "执行本地增量：date +%Y-%m-%d-%H-%M-%S " >>back_info_`date +%Y-%m-%d`.log
	vb_probackup backup -B $back_home  --instance=${back_instance} -b PTRACK -D ${back_data}   -U $back_user -W  $back_pass -d ${db_database}>> back_info_`date +%Y-%m-%d`.log 2>&1
}

#远程全备
back_ssh_full(){
	echo "执行远程全备：date +%Y-%m-%d-%H-%M-%S " >>back_info_`date +%Y-%m-%d`.log
	vb_probackup backup -B $back_home --instance=${back_instance} -b f -D ${back_data}   -h $IP_back  -p $db_port_back -U $back_user -W $back_pass -d ${db_database}  --remote-host=$IP_back  --remote-port=22  --remote-proto=ssh --remote-path=$home_back --remote-user=$os_back  >> back_info_`date +%Y-%m-%d`.log 2>&1

}

#远程增量
back_ssh_ptrack(){
	echo "执行远程增量：date +%Y-%m-%d-%H-%M-%S " >>back_info_`date +%Y-%m-%d`.log
	vb_probackup backup -B $back_home --instance=${back_instance} -b PTRACK  -D ${back_data}  -h $IP_back  -p $db_port_back -U $back_user -W $back_pass  -d ${db_database} --remote-host=$IP_back  --remote-port=22  --remote-proto=ssh --remote-path=$home_back --remote-user=$os_back  >> back_info_`date +%Y-%m-%d`.log 2>&1

}

#删除由于备份过期之后不会自动删除需要手动执行
delete_expired(){
	echo "删除过期备份数据：date +%Y-%m-%d-%H-%M-%S " >>back_info_`date +%Y-%m-%d`.log
	vb_probackup delete -B $back_home --instance=${back_instance} --delete-expired  >> back_info_`date +%Y-%m-%d`.log 2>&1
	echo "删除过期归档：date +%Y-%m-%d-%H-%M-%S " >>back_info_`date +%Y-%m-%d`.log
	vb_probackup delete -B $back_home --instance=${back_instance} --delete-expired --delete-wal  >> back_info_`date +%Y-%m-%d`.log 2>&1
}

if [[ $1 == '--help' ]]
then
	help
fi

#判断远程/本地  全备/增量
if [[ $1 == 'local' ]]
then
	if [[ $2 == 'full' ]]
	then
		back_local_full
		delete_expired
	fi
	if [[ $2 == 'ptrack' ]]
	then
		back_local_ptrack
		delete_expired	
	fi
fi

if [[ $1 == 'ssh' ]]
then
	if [[ $2 == 'full' ]] 
	then
		back_ssh_full
		delete_expired
	fi
	if [[ $2 == 'ptrack' ]]
	then
		back_ssh_ptrack	
		delete_expired
	fi
fi






#定时任务手动设置检查会更安全
#脚本设置如下：

#30 1 * * 1,3,5,7 ./vastbase_g100_backup.sh  local full

#chmod +x database_backup.sh
#crontab –e –u vastbase
#30 1 * * 7 ./database_backup.sh  ssh full
#30 1 * * 1,2,3,4,5,6 ./database_backup.sh  ssh ptrack
