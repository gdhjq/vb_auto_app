#!/bin/bash 


# =====================================================================
# 使用说明：
#	1. 将脚本拷贝到数据库安装用户的home目录下
#	2. 运行本脚本
#	3. 程序检查是否存在$PGDATA目录，若不存在，则退出
#	4. 程序目前仅收集当前节点信息：
#		- lscpu信息
#     - lsblk信息
#     - df信息
#     - 软件列表
#		- /etc/os-release信息
#     - /proc/meminfo信息
#		- $PGDATA/postgresql*配置文件
#		- $PGDATA/<日志路径>/* 数据库日志文件（最近1天内的日志）	
#		- $PGDATA/pg_hba.conf配置文件
#     - has配置文件（若有集群在运行）
#     - dcs配置文件（若有集群在运行）
#	5. 程序将以上文件打包成debug_files_yyyymmddHHMMSS.tar.gz
#	6. 若出现较严重问题，请手工收集以下信息：
#		- coredump文件
#		- /var/log/messages*日志文件
#  7. 请在CRM工单附上以上收集的文件
# =====================================================================	

#======================================================================
#     				environment
#======================================================================
vb_data=$1
mange_ip=$2
mange_check=$3
export PGDATA=${vb_data}

echo "数据实例目录：$PGDATA"
if [[ $PGDATA == '' ]]
then
	echo "\$PGDATA值为空，数据库实例不存在，退出..."
	exit
fi

echo "删除debug_files开头的文件"
rm -rf debug_files*

dfilename='debug_files_'`date +%Y%m%d%H%M%S`

echo "创建目录$dfilename"
mkdir $dfilename

echo "切换到目录$dfilename"
cd $dfilename


###################
#   System info   #
###################
mkdir system_info
echo "输出lscpu到文件lscpu.txt"
lscpu > ./system_info/lscpu.txt

echo "输出lsblk到文件lsblk.txt"
lsblk > ./system_info/lsblk.txt

echo "输出df到文件df.txt"
df > ./system_info/df.txt

echo "输出已经安装的软件列表"
rpm -qa > ./system_info/software_installed.txt

echo "拷贝文件/etc/os-release到当前目录"
cp /etc/os-release ./system_info

echo "拷贝文件/proc/meminfo到当前目录"
cp /proc/meminfo ./system_info


###################
#  Database info  #
###################
mkdir db_info
echo "拷贝数据库配置文件postgresql.conf到当前目录"
cp $PGDATA/postgresql.conf ./db_info
echo "拷贝数据库配置文件pg_hba.conf到当前目录"
cp $PGDATA/pg_hba.conf ./db_info
if [ -f $PGDATA/postgresql.base.conf ]
then
	echo "拷贝数据库配置文件postgresql.base.conf到当前目录"
	cp $PGDATA/postgresql.base.conf ./db_info
fi

log_dir=$(cat $PGDATA/postgresql.conf | grep -E '^log_directory' | sed 's/.*=\s*//g' | sed "s/'//g" | awk 'END{print $1}')
mkdir db_info/pg_log

if [ `echo $log_dir | grep -E "^/"` ]
then
	echo "从目录$log_dir拷贝数据库日志到pg_log目录"
	find $log_dir -mtime 0 -type f | xargs cp -t db_info/pg_log
elif [[ $log_dir == '' ]]
then
	echo "从目录pg_log拷贝数据库日志到pg_log目录"
	find $PGDATA/pg_log -mtime 0 -type f | xargs cp -t db_info/pg_log
else
	echo "从目录$PGDATA/$log_dir拷贝数据库日志到pg_log目录"
	find $PGDATA/$log_dir -mtime 0 -type f | xargs cp -t db_info/pg_log
fi


id=`ps -ef |grep patroni  |grep -v grep|awk '{print $2}'`
if [[ $id != '' ]]
then
   echo "拷贝has配置文件到当前目录"
   mkdir has
   patroni_file=`ps -ef |grep patroni  |grep -v grep|awk '{print $10}'`
   cp $patroni_file ./has
fi
   
e_id=`ps -ef |grep etcd_conf.yml  |grep -v grep|awk '{print $2}'`

if [[ $e_id != '' ]]
then 
   echo "拷贝dcs配置文件到当前目录"
   mkdir dcs
   etcd_conf=`ps -ef |grep etcd_conf.yml  |grep -v grep|awk '{print $NF}'`
   cp $etcd_conf  ./dcs
fi

echo "打包文件$dfilename.tar.gz"
cd ..
tar zcvf $dfilename.tar.gz $dfilename

scp $dfilename.tar.gz  root@${mange_ip}:${mange_check}