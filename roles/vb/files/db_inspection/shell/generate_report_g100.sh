#!/usr/bin/env bash

#==============================================================#
# File      :   generate_report_g100
# Ctime     :   2021-11-27
# Mtime     :   2021-11-27
# Desc      :   vastbase G100  inspection script
# Path      :   ../files/db_inspection/shell/generate_report_g100
# Depend    :   .pgpass
# Author    :   Alicebat 
#==============================================================#

#数据库配置
#vastbase_login_info = off  关闭登陆输出   


vb_home=$1
vb_data=$2
db_port=$3 
#mange_ip=$5
#mange_inspection=$6




# 请将以下变量修改为与当前环境一致, 并且确保使用这个配置连接任何数据库都不需要输入密码
export PGHOST=127.0.0.1
export PGPORT=${db_port}
export PGDATABASE=vastbase
export PGUSER=vbadmin
export PGPASSWORD=Vbase@admin
export PGDATA=${vb_data}
export GAUSSHOME=${vb_home}

export PATH=$GAUSSHOME/bin:$PATH:
export DATE=`date +"%Y%m%d%H%M"`
export LD_LIBRARY_PATH=$GAUSSHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH
log_dir=$(cat $PGDATA/postgresql.conf | grep -E '^log_directory' | sed 's/.*=\s*//g' | sed "s/'//g" | awk 'END{print $1}')
if [[ ${log_dir} == '' ]]
then
  pg_log_dir=$PGDATA/pg_log
else
  pg_log_dir=$PGDATA/$log_dir
fi
##数据库用户家目录
#os_home=${os_home_1}
# 记住当前目录
PWD=`pwd`

if [[ ! -d ${db_port} ]];then
  mkdir ${db_port}
fi

run_log_file="generate_vb_file_$(date "+%Y_%m_%d_%H_%M_%S").log"
primary_file='is_primary.txt'
log_date=`date +"%Y-%m"`



echo "###########################################################################" > ${db_port}/$run_log_file
echo "#                       1.os system info                                  #" >> ${db_port}/$run_log_file
echo "###########################################################################" >> ${db_port}/$run_log_file
echo "### os info start #####" >> ${db_port}/$run_log_file
echo "## 1.1 hostname ###" >> ${db_port}/$run_log_file
HOST_NAME=`hostname -s`
echo ${HOST_NAME}> ${db_port}/1.1_hostname.txt

echo "## 1.2 ip address ###"  >> ${db_port}/$run_log_file
ip addr show > ${db_port}/1.2_ip_address.txt 

echo "## 1.3 os kernel ###"  >> ${db_port}/$run_log_file
uname -a > ${db_port}/1.3_os_kernel.txt 

echo "## 1.4 memory ###"  >> ${db_port}/$run_log_file
free -m > ${db_port}/1.4_memory.txt 

echo "## 1.5 CPU ###"  >> ${db_port}/$run_log_file
lscpu > ${db_port}/1.5_cpu.txt

echo "## 1.6 os_sysctl ###"  >> ${db_port}/$run_log_file
grep "^[a-z]" /etc/sysctl.conf > ${db_port}/1.6_os_sysctl.txt 

echo "## 1.7 database user limit  ###" >> ${db_port}/$run_log_file
grep -v "^#" /etc/security/limits.conf|grep -v "^$" > ${db_port}/1.7_user_limit.txt 

echo "## 1.8 selinux  ###"  >> ${db_port}/$run_log_file
getsebool > ${db_port}/1.8_selinux.txt 
sestatus >> ${db_port}/1.8_selinux.txt 

echo "## 1.9 Transparent Huge Pages  ###"  >> ${db_port}/$run_log_file
cat /sys/kernel/mm/transparent_hugepage/enabled > ${db_port}/1.9_hugepage.txt
cat /sys/kernel/mm/transparent_hugepage/defrag >> ${db_port}/1.9_hugepage.txt

echo "## 1.10 dir util  ###"  >> ${db_port}/$run_log_file
df -h  > ${db_port}/1.10_dir_util.txt 

echo "### os info end #####"  >> ${db_port}/$run_log_file

echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       2.database info                                   #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 2.1 database version  ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select version()' -W ${PGPASSWORD}  > ${db_port}/2.1_version.txt 

echo "## 2.2 database extension  ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),* from pg_extension' -W ${PGPASSWORD}
done > ${db_port}/2.2_db_extension.txt

echo "## 2.3 database type  ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),b.typname,count(*) from pg_attribute a,pg_type b where a.atttypid=b.oid and a.attrelid in (select oid from pg_class where relnamespace not in (select oid from pg_namespace where nspname ~ $$^pg_$$ or nspname=$$information_schema$$)) group by 1,2 order by 3 desc ' -W ${PGPASSWORD}
done  > ${db_port}/2.3_type.txt 

echo "## 2.4 database objects  ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),rolname,nspname,relkind,count(*) from pg_class a,pg_authid b,pg_namespace c where a.relnamespace=c.oid and a.relowner=b.oid and nspname !~ $$^pg_$$ and nspname<>$$information_schema$$ group by 1,2,3,4 order by 5 desc' -W ${PGPASSWORD}
done > ${db_port}/2.4_objects.txt

echo "## 2.5 db space  ###"  >> ${db_port}/$run_log_file
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),buk this_buk_no,cnt rels_in_this_buk,pg_size_pretty(min) buk_min,pg_size_pretty(max) buk_max from( select row_number() over (partition by buk order by tsize),tsize,buk,min(tsize) over (partition by buk),max(tsize) over (partition by buk),count(*) over (partition by buk) cnt from ( select pg_relation_size(a.oid) tsize, width_bucket(pg_relation_size(a.oid),tmin-1,tmax+1,10) buk from (select min(pg_relation_size(a.oid)) tmin,max(pg_relation_size(a.oid)) tmax from pg_class a,pg_namespace c where a.relnamespace=c.oid and nspname !~ $$^pg_$$ and nspname<>$$information_schema$$) t, pg_class a,pg_namespace c where a.relnamespace=c.oid and nspname !~ $$^pg_$$ and nspname<>$$information_schema$$ ) t)t where row_number=1;' -W ${PGPASSWORD}
done > ${db_port}/2.5_db_space.txt 



echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       3.database conf                                   #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 3.1 pg_hba.conf md5  ###"  >> ${db_port}/$run_log_file
md5sum $PGDATA/pg_hba.conf  > ${db_port}/3.1_hba_md.txt 

echo "## 3.2 pg_hba.conf   ###"  >> ${db_port}/$run_log_file
grep '^\ *[a-z]' $PGDATA/pg_hba.conf > ${db_port}/3.2_pg_hba.txt 
echo "建议: " >> ${db_port}/3.2_pg_hba.txt 
echo "    主备配置尽量保持一致, 注意trust和password认证方法的危害(password方法 验证时网络传输密码明文, 建议改为md5), 建议除了unix socket可以使用trust以外, 其他都使用md5或者LDAP认证方法." >> ${db_port}/3.2_pg_hba.txt 
echo "    建议先设置白名单(超级用户允许的来源IP, 可以访问的数据库), 再设置黑名单(不允许超级用户登陆, reject), 再设置白名单(普通应用), 参考pg_hba.conf中的描述. " >> ${db_port}/3.2_pg_hba.txt 
echo -e "\n" >> ${db_port}/3.2_pg_hba.txt 

echo "## 3.3 postgresql.conf md5  ###"  >> ${db_port}/$run_log_file
md5sum $PGDATA/postgresql.conf  > ${db_port}/3.3_md.txt 


echo "## 3.4 postgresql.conf  ###"  >> ${db_port}/$run_log_file
grep '^\ *[a-z]' $PGDATA/postgresql.conf|awk -F "#" '{print $1}'  > ${db_port}/3.4_postgresql_conf.txt 
echo "建议: " >> ${db_port}/3.4_postgresql_conf.txt 
echo "    主备配置尽量保持一致, 配置合理的参数值." >> ${db_port}/3.4_postgresql_conf.txt 
echo -e "    建议修改的参数列表如下  ( 假设操作系统内存为512GB, 数据库独占操作系统, 数据库版本v2.2.4, 其他版本可能略有不同, 未来再更新进来 )  :
#证书路径
license_path = '请输入licence绝对路径/licence名称'
vastbase_login_info = off

#监听信息
listen_addresses = '*'
port = 5432
max_connections = 2000
session_timeout = 10min

#日志
client_min_messages = warning 
log_min_messages = warning
log_destination = 'stderr'
logging_collector = on 
#log_directory = 'pg_log' 
log_filename = 'postgresql-%Y-%m-%d_%H%M%S.log' 
log_rotation_size = 50MB 
log_duration = off 
track_activities = on
enable_instr_track_wait = on
enable_instr_rt_percentile = off
track_counts = on
track_sql_count = off
enable_instr_cpu_timer = off
enable_instance_metric_persistent = off
enable_logical_io_statistics = off
enable_page_lsn_check = off
enable_user_metric_persistent = off
enable_resource_track = off
instr_unique_sql_count = 0
plog_merge_age = 0

#内存资源调整
shared_buffers = 204GB
max_process_memory = 409GB
work_mem = 48MB
cstore_buffers = 16MB
maintenance_work_mem = 20GB
max_files_per_process = 100000 
max_prepared_transactions = 2048
bulk_write_ring_size = 2GB

#WAL配置
wal_level = hot_standby
wal_log_hints = on
advance_xlog_file_num = 10
wal_buffers = 1GB
xloginsert_locks = 48
enable_xlog_prune = off
max_wal_senders = 4
wal_keep_segments = 16
max_replication_slots = 8
synchronous_commit = on

#执行计划
enable_mergejoin = on
enable_nestloop = on
enable_hashjoin = on
enable_bitmapscan = on
enable_material = off
enable_codegen = false
enable_opfusion = off
enable_beta_opfusion = off
query_dop = 1

#autovacuum
autovacuum = on
autovacuum_mode = vacuum
autovacuum_max_workers = 10
autovacuum_naptime = 20s
autovacuum_vacuum_cost_delay = 10
autovacuum_vacuum_scale_factor = 0.02
autovacuum_analyze_scale_factor = 0.1
enable_save_datachanged_timestamp = false
vacuum_cost_limit = 10000
autoanalyze_timeout = 900

#增量检查点信息
enable_incremental_checkpoint = on
incremental_checkpoint_timeout = 60s
checkpoint_segments = 1024
checkpoint_timeout = 15min
checkpoint_completion_target = 0.9
checkpoint_warning = 5min
checkpoint_wait_timeout = 60s

#归档信息
archive_mode = off
archive_command = '/bin/bash /home/vb24/vb_archive.sh %p %f'
archive_dest = '/data/archive'

#主备信息
application_name = 'vdb'
password_encryption_type = 0
#replconninfo1 = 'localhost=172.20.20.92 localport=26002 localheartbeatport=26005 localservice=26004 remotehost =172.20.20.88 remoteport=26002 remoteheartbeatport=26005 remoteservice=26004'
synchronous_standby_names = '*'
most_available_sync = on
remote_read_mode = non_authentication
hot_standby_feedback = off
enable_data_replicate = off

#并行回放/极致RTO
# 以下为并行回放的参数配置：
hot_standby = off
replication_type = 1
recovery_max_workers = 8
recovery_parallelism = 1
recovery_parse_workers = 1
recovery_redo_workers = 1
recovery_time_target = 0

#审计日志配置
audit_enabled = off
audit_operation_result = 0
#其他
fsync = on
full_page_writes = off
enable_double_write = on
allow_concurrent_tuple_update = true
enable_alarm = off
use_workload_manager = off
transaction_isolation = 'read committed'
default_transaction_isolation = 'read committed'
update_lockwait_timeout = 20min
pagewriter_sleep = 5ms


#线程池
enable_thread_pool = off
numa_distribute_mode = 'none'
thread_pool_attr = '494,4,(allbind)'
wal_writer_cpu = 0

#default
session_timeout = 10min
enable_slot_log = off
walsender_max_send_size = 8MB
enable_kill_query = off
log_file_mode = 0600
log_min_duration_statement = 1800000
log_connections = off
log_disconnections = off
log_hostname = on
log_line_prefix = '%m %u %d %h %p %S '
log_timezone = 'PRC'
connection_alarm_rate = 0.9
alarm_report_interval = 10
alarm_component = '/opt/snas/bin/snas_cm_cmd'
datestyle = 'iso, mdy'
timezone = 'PRC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.english'
lockwait_timeout = 1200s
pgxc_node_name = 'vdb'
job_queue_processes = 10
default_storage_nodegroup = 'installation'
expected_computing_nodegroup = 'query'
\n"  >> ${db_port}/3.4_postgresql_conf.txt 


echo "## 3.5  db_user conf   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select * from pg_db_role_setting' -W ${PGPASSWORD}  > ${db_port}/3.5_db_user_conf.txt 


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       4.database error                                   #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 4.1  error log    ###"  >> ${db_port}/$run_log_file
cat  $pg_log_dir/postgresql-${log_date}*.log | grep -E "^[0-9]" | grep -E "ERROR|FATAL|PANIC" |sort -rn |head -20> ${db_port}/4.1_error_log.txt 


echo "## 4.2  db connection  ###"  >> ${db_port}/$run_log_file
find $pg_log_dir/ -name "postgresql-${log_date}*.log" -type f -mtime -28 -exec grep "connection authorized" {} +|sort|uniq |sort -n -r|head -20 > ${db_port}/4.2_db_connection.txt


echo "## 4.3  password authentication failed  ###"  >> ${db_port}/$run_log_file
find  $pg_log_dir/  -name "postgresql-${log_date}*.log" -type f -mtime -28 -exec grep "password authentication failed" {} +|sort|uniq|sort -n -r > ${db_port}/4.3_authentication_failed.txt 


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       5.Database space usage analysis                   #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 5.1  echo tablespace dir   ###"  >> ${db_port}/$run_log_file
ls -la $PGDATA/pg_tblspc/ > ${db_port}/5.1_echo_tablespace.txt

echo "## 5.2  tablespace usg   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select spcname,pg_tablespace_location(oid),pg_size_pretty(pg_tablespace_size(oid)) from pg_tablespace order by pg_tablespace_size(oid) desc' -W ${PGPASSWORD} > ${db_port}/5.2_tablespace_usg.txt

echo "## 5.3  dastbase usg   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select datname,pg_size_pretty(pg_database_size(oid)) from pg_database order by pg_database_size(oid) desc' -W ${PGPASSWORD} > ${db_port}/5.3_database_usg.txt

echo "## 5.4   TOP 10 size   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),b.nspname,c.relname,c.relkind,pg_size_pretty(pg_relation_size(c.oid)),a.seq_scan,a.seq_tup_read,a.idx_scan,a.idx_tup_fetch,a.n_tup_ins,a.n_tup_upd,a.n_tup_del,a.n_tup_hot_upd,a.n_live_tup,a.n_dead_tup from pg_stat_all_tables a, pg_class c,pg_namespace b where c.relnamespace=b.oid and c.relkind=$$r$$ and a.relid=c.oid order by pg_relation_size(c.oid) desc limit 10' -W ${PGPASSWORD}
done > ${db_port}/5.4_top_object.txt


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       6.Database connection  analysis                   #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 6.1  connection activity   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select now(),state,count(*) from pg_stat_activity group by 1,2' -W ${PGPASSWORD} > ${db_port}/6.1_activity.txt


echo "## 6.2  count connection   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select t3.max_conn,t1.used,t3.max_conn-used-t1.used res_for_normal from (select count(*) used from pg_stat_activity) t1, (select setting::int max_conn from pg_settings where name=$$max_connections$$) t3' -W ${PGPASSWORD} > ${db_port}/6.2_count_connection.txt

echo "## 6.3  user limit connection   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select a.rolname,a.rolconnlimit,b.connects from pg_authid a,(select usename,count(*) connects from pg_stat_activity group by usename) b where a.rolname=b.usename order by b.connects desc' -W ${PGPASSWORD} > ${db_port}/6.3_user_limit.txt


echo "## 6.4  database limit  connection   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select a.datname, a.datconnlimit, b.connects from pg_database a,(select datname,count(*) connects from pg_stat_activity group by datname) b where a.datname=b.datname order by b.connects desc' -W ${PGPASSWORD} >${db_port}/6.4_database_limit.txt


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       7.Database Performance analysis                   #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 7.1  TOP 5 SQL : total_cpu_time   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -x -c 'select c.rolname,b.datname,a.total_time/a.calls per_call_time,a.* from pg_stat_statements a,pg_database b,pg_authid c where a.userid=c.oid and a.dbid=b.oid order by a.total_time desc limit 5' -W ${PGPASSWORD} > ${db_port}/7.1_total_cpu_time.txt


echo "## 7.2   索引数超过4并且SIZE大于10MB的表:   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(), t2.nspname, t1.relname, pg_size_pretty(pg_relation_size(t1.oid)), t3.idx_cnt from pg_class t1, pg_namespace t2, (select indrelid,count(*) idx_cnt from pg_index group by 1 having count(*)>4) t3 where t1.oid=t3.indrelid and t1.relnamespace=t2.oid and pg_relation_size(t1.oid)/1024/1024.0>10 order by t3.idx_cnt desc' -W ${PGPASSWORD}
done > ${db_port}/7.2_index_mb.txt

echo "## 7.3  上次巡检以来未使用或使用较少的索引:   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),t2.schemaname,t2.relname,t2.indexrelname,t2.idx_scan,t2.idx_tup_read,t2.idx_tup_fetch,pg_size_pretty(pg_relation_size(indexrelid)) from pg_stat_all_tables t1,pg_stat_all_indexes t2 where t1.relid=t2.relid and t2.idx_scan<10 and t2.schemaname not in ($$pg_toast$$,$$pg_catalog$$) and indexrelid not in (select conindid from pg_constraint where contype in ($$p$$,$$u$$,$$f$$)) and pg_relation_size(indexrelid)>65536 order by pg_relation_size(indexrelid) desc' -W ${PGPASSWORD}
done > ${db_port}/7.3_little_used_index.txt

echo "## 7.4   数据库统计信息, 回滚比例, 命中比例, 数据块读写时间, 死锁, 复制冲突:   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select datname,round(100*(xact_rollback::numeric/(case when xact_commit > 0 then xact_commit else 1 end + xact_rollback)),2)||$$ %$$ rollback_ratio, round(100*(blks_hit::numeric/(case when blks_read>0 then blks_read else 1 end + blks_hit)),2)||$$ %$$ hit_ratio, blk_read_time, blk_write_time, conflicts, deadlocks from pg_stat_database' -W ${PGPASSWORD} > ${db_port}/7.4_count_information.txt

echo "## 7.5  检查点, bgwriter 统计信息:   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -x -c 'select * from pg_stat_bgwriter'  -W ${PGPASSWORD} > ${db_port}/7.5_bgwriter.txt


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       8.Database garbage analysis                       #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 8.1  Index inflation check   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -x -c 'SELECT
  current_database() AS db, schemaname, tablename, reltuples::bigint AS tups, relpages::bigint AS pages, otta,
  ROUND(CASE WHEN otta=0 OR sml.relpages=0 OR sml.relpages=otta THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS tbloat,
  CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes,
  CASE WHEN relpages < otta THEN $$0 bytes$$::text ELSE (bs*(relpages-otta))::bigint || $$ bytes$$ END AS wastedsize,
  iname, ituples::bigint AS itups, ipages::bigint AS ipages, iotta,
  ROUND(CASE WHEN iotta=0 OR ipages=0 OR ipages=iotta THEN 0.0 ELSE ipages/iotta::numeric END,1) AS ibloat,
  CASE WHEN ipages < iotta THEN 0 ELSE ipages::bigint - iotta END AS wastedipages,
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,
  CASE WHEN ipages < iotta THEN $$0 bytes$$ ELSE (bs*(ipages-iotta))::bigint || $$ bytes$$ END AS wastedisize,
  CASE WHEN relpages < otta THEN
    CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta::bigint) END
    ELSE CASE WHEN ipages < iotta THEN bs*(relpages-otta::bigint)
      ELSE bs*(relpages-otta::bigint + ipages-iotta::bigint) END
  END AS totalwastedbytes
FROM (
  SELECT
    nn.nspname AS schemaname,
    cc.relname AS tablename,
    COALESCE(cc.reltuples,0) AS reltuples,
    COALESCE(cc.relpages,0) AS relpages,
    COALESCE(bs,0) AS bs,
    COALESCE(CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)),0) AS otta,
    COALESCE(c2.relname,$$?$$) AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM
     pg_class cc
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname <> $$information_schema$$
  LEFT JOIN
  (
    SELECT
      ma,bs,foo.nspname,foo.relname,
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        ns.nspname, tbl.relname, hdr, ma, bs,
        SUM((1-coalesce(null_frac,0))*coalesce(avg_width, 2048)) AS datawidth,
        MAX(coalesce(null_frac,0)) AS maxfracsum,
        hdr+(
          SELECT 1+count(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = ns.nspname AND s2.tablename = tbl.relname
        ) AS nullhdr
      FROM pg_attribute att 
      JOIN pg_class tbl ON att.attrelid = tbl.oid
      JOIN pg_namespace ns ON ns.oid = tbl.relnamespace 
      LEFT JOIN pg_stats s ON s.schemaname=ns.nspname
      AND s.tablename = tbl.relname
      AND s.inherited=false
      AND s.attname=att.attname,
      (
        SELECT
          (SELECT current_setting($$block_size$$)::numeric) AS bs,
            CASE WHEN SUBSTRING(SPLIT_PART(v, $$ $$, 2) FROM $$#"[0-9]+.[0-9]+#"%$$ for $$#$$)
              IN ($$8.0$$,$$8.1$$,$$8.2$$) THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ $$mingw32$$ OR v ~ $$64-bit$$ THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      WHERE att.attnum > 0 AND tbl.relkind=$$r$$
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  ON cc.relname = rs.relname AND nn.nspname = rs.nspname
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml order by wastedibytes desc limit 5' -W ${PGPASSWORD}
done > ${db_port}/8.1_index_inflation_check.txt


echo "## 8.2  junk data   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),schemaname,relname,n_dead_tup from pg_stat_all_tables where n_live_tup>0 and n_dead_tup/n_live_tup>0.2 and schemaname not in ($$pg_toast$$,$$pg_catalog$$) order by n_dead_tup desc limit 5' -W ${PGPASSWORD}
done > ${db_port}/8.2_junk_data.txt

echo "## 8.3  table inflation check   ###"  >> ${db_port}/$run_log_file
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
psql -d $db --pset=pager=off -q -x -c 'SELECT    
  current_database() AS db, schemaname, tablename, reltuples::bigint AS tups, relpages::bigint AS pages, otta,    
  ROUND(CASE WHEN otta=0 OR sml.relpages=0 OR sml.relpages=otta THEN 0.0 ELSE sml.relpages/otta::numeric END,1) AS tbloat,    
  CASE WHEN relpages < otta THEN 0 ELSE relpages::bigint - otta END AS wastedpages,    
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::bigint END AS wastedbytes,    
  CASE WHEN relpages < otta THEN $$0 bytes$$::text ELSE (bs*(relpages-otta))::text || $$ bytes$$ END AS wastedsize,    
  iname, ituples::bigint AS itups, ipages::bigint AS ipages, iotta,    
  ROUND(CASE WHEN iotta=0 OR ipages=0 OR ipages=iotta THEN 0.0 ELSE ipages/iotta::numeric END,1) AS ibloat,    
  CASE WHEN ipages < iotta THEN 0 ELSE ipages::bigint - iotta END AS wastedipages,    
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes,    
  CASE WHEN ipages < iotta THEN $$0 bytes$$ ELSE (bs*(ipages-iotta))::text || $$ bytes$$ END AS wastedisize,    
  CASE WHEN relpages < otta THEN    
    CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta::bigint) END    
    ELSE CASE WHEN ipages < iotta THEN bs*(relpages-otta::bigint)    
      ELSE bs*(relpages-otta::bigint + ipages-iotta::bigint) END    
  END AS totalwastedbytes    
FROM (    
  SELECT    
    nn.nspname AS schemaname,    
    cc.relname AS tablename,    
    COALESCE(cc.reltuples,0) AS reltuples,    
    COALESCE(cc.relpages,0) AS relpages,    
    COALESCE(bs,0) AS bs,    
    COALESCE(CEIL((cc.reltuples*((datahdr+ma-    
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)),0) AS otta,    
    COALESCE(c2.relname,$$?$$) AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,    
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols    
  FROM    
     pg_class cc    
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname <> $$information_schema$$    
  LEFT JOIN    
  (    
    SELECT    
      ma,bs,foo.nspname,foo.relname,    
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,    
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2    
    FROM (    
      SELECT    
        ns.nspname, tbl.relname, hdr, ma, bs,    
        SUM((1-coalesce(null_frac,0))*coalesce(avg_width, 2048)) AS datawidth,    
        MAX(coalesce(null_frac,0)) AS maxfracsum,    
        hdr+(    
          SELECT 1+count(*)/8    
          FROM pg_stats s2    
          WHERE null_frac<>0 AND s2.schemaname = ns.nspname AND s2.tablename = tbl.relname    
        ) AS nullhdr    
      FROM pg_attribute att     
      JOIN pg_class tbl ON att.attrelid = tbl.oid    
      JOIN pg_namespace ns ON ns.oid = tbl.relnamespace     
      LEFT JOIN pg_stats s ON s.schemaname=ns.nspname    
      AND s.tablename = tbl.relname    
      AND s.inherited=false    
      AND s.attname=att.attname,    
      (    
        SELECT    
          (SELECT current_setting($$block_size$$)::numeric) AS bs,    
            CASE WHEN SUBSTRING(SPLIT_PART(v, $$ $$, 2) FROM $$#"[0-9]+.[0-9]+#"%$$ for $$#$$)    
              IN ($$8.0$$,$$8.1$$,$$8.2$$) THEN 27 ELSE 23 END AS hdr,    
          CASE WHEN v ~ $$mingw32$$ OR v ~ $$64-bit$$ THEN 8 ELSE 4 END AS ma    
        FROM (SELECT version() AS v) AS foo    
      ) AS constants    
      WHERE att.attnum > 0 AND tbl.relkind=$$r$$    
      GROUP BY 1,2,3,4,5    
    ) AS foo    
  ) AS rs    
  ON cc.relname = rs.relname AND nn.nspname = rs.nspname    
  LEFT JOIN pg_index i ON indrelid = cc.oid    
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid    
) AS sml order by wastedbytes desc limit 5' -W ${PGPASSWORD}
done  > ${db_port}/8.3_table_inflation_check.txt


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       9.Database age analysis                           #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 9.1  database age    ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'SELECT datname, age(datfrozenxid64) FROM pg_database order by age(datfrozenxid64) desc' -W ${PGPASSWORD} > ${db_port}/9.1_database_age.txt

echo "## 9.2  table age    ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c "SELECT c.oid::regclass as table_name,greatest(age(c.relfrozenxid64),age(t.relfrozenxid64)) as age FROM pg_class c  LEFT JOIN pg_class t ON c.reltoastrelid = t.oid WHERE c.relkind IN ('r', 'm') order by 2 desc limit 5;" -W ${PGPASSWORD}
done > ${db_port}/9.2_table_age.txt

echo "## 9.3  Long transaction , 2PC:    ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -x -c 'select datname,usename,query,xact_start,now()-xact_start xact_duration,query_start,now()-query_start query_duration,state from pg_stat_activity where state<>$$idle$$  and now()-xact_start > interval $$30 min$$ order by xact_start' -W ${PGPASSWORD} > ${db_port}/9.3_long_transaction.txt
vsql --pset=pager=off -q -x -c 'select name,statement,prepare_time,now()-prepare_time,parameter_types,from_sql from pg_prepared_statements where now()-prepare_time > interval $$30 min$$ order by prepare_time' -W ${PGPASSWORD} >> ${db_port}/9.3_long_transaction.txt


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#     10.Database XLOG, stream replication status analysis                #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "## 10.1 $$archive_mode$$,$$autovacuum$$,$$archive_command$$   on  ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select name,setting from pg_settings where name in ($$archive_mode$$,$$autovacuum$$,$$archive_command$$)' -W ${PGPASSWORD} > ${db_port}/10.1_on.txt


echo "## 10.2  archive count ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select pg_xlogfile_name(pg_current_xlog_insert_location())' -W ${PGPASSWORD} > ${db_port}/10.2_archive_count.txt

echo "## 10.3  Stream replication  ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -x -c 'select pid,state,client_addr,pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_insert_location(),sender_sent_location)) sent_delay, pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_insert_location(),receiver_replay_location))  replay_delay, sync_priority,sync_state   from pg_stat_replication' -W ${PGPASSWORD} > ${db_port}/10.3_stream.txt

echo "## 10.4   replication solt  ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c ' select pg_xlog_location_diff(pg_current_xlog_insert_location(),restart_lsn), * from pg_replication_slots;' -W ${PGPASSWORD} > ${db_port}/10.4_replication_solt.txt



echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#     11.Database safe                                                    #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file

#echo "## 11.1  检查 ~/.psql_history :  ###"  >> $run_log_file
#grep -i "password" ${os_home}/.vsql_history|grep -i -E "role|group|user" > 11.1_psql_history.txt

echo "## 11.2  检查 *.log :   ###"  >> ${db_port}/$run_log_file
cat  $pg_log_dir/postgresql-${log_date}*.log | grep -E "^[0-9]" | grep -i -r -E "role|group|user" |grep -i "password"|grep -i -E "create|alter" > ${db_port}/11.2_check_log.txt


echo "## 11.3  检查 pg_stat_statements    ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -c 'select query from pg_stat_statements where (query ~* $$group$$ or query ~* $$user$$ or query ~* $$role$$) and query ~* $$password$$'  -W ${PGPASSWORD} > ${db_port}/11.3_check_statements.txt

echo "## 11.4  检查 pg_authid :    ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select * from pg_authid where rolpassword !~ $$^md5$$ or length(rolpassword)<>35' -W ${PGPASSWORD} > ${db_port}/11.4_pg_authid.txt

echo "## 11.5 检查 pg_user_mappings, pg_views :   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select current_database(),* from pg_user_mappings where umoptions::text ~* $$password$$' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -c 'select current_database(),* from pg_views where definition ~* $$password$$ and definition ~* $$dblink$$' -W ${PGPASSWORD}
done > ${db_port}/11.5_pg_views.txt

echo "## 11.6  用户密码到期时间:   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select rolname,rolvaliduntil from pg_authid order by rolvaliduntil' -W ${PGPASSWORD} > ${db_port}/11.6_passwd_authid.txt

echo "## 11.7  普通用户对象上的规则安全检查:  ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select current_database(),a.schemaname,a.tablename,a.rulename,a.definition from pg_rules a,pg_namespace b,pg_class c,pg_authid d where a.schemaname=b.nspname and a.tablename=c.relname and d.oid=c.relowner and not d.rolsuper union all select current_database(),a.schemaname,a.viewname,a.viewowner,a.definition from pg_views a,pg_namespace b,pg_class c,pg_authid d where a.schemaname=b.nspname and a.viewname=c.relname and d.oid=c.relowner and not d.rolsuper' -W ${PGPASSWORD}
done > ${db_port}/11.7_user_safe.txt

echo "## 11.8 普通用户自定义函数安全检查:    ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select current_database(),b.rolname,c.nspname,a.proname from pg_proc a,pg_authid b,pg_namespace c where a.proowner=b.oid and a.pronamespace=c.oid and not b.rolsuper and not a.prosecdef' -W ${PGPASSWORD}
done > ${db_port}/11.8_user_function.txt

echo "## 11.9 unlogged table 和 哈希索引:    ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),t3.rolname,t2.nspname,t1.relname from pg_class t1,pg_namespace t2,pg_authid t3 where t1.relnamespace=t2.oid and t1.relowner=t3.oid and t1.relpersistence=$$u$$' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(),pg_get_indexdef(oid) from pg_class where relkind=$$i$$ and pg_get_indexdef(oid) ~ $$USING hash$$' -W ${PGPASSWORD}
done > ${db_port}/11.9_unlogged_table.txt


echo "## 11.10 触发器, 事件触发器:   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),relname,tgname,proname,tgenabled from pg_trigger t1,pg_class t2,pg_proc t3 where t1.tgfoid=t3.oid and t1.tgrelid=t2.oid' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(),owner,trigger_name,trigger_type,triggering_event,trigger_body,before_statement,after_statement from all_triggers' -W ${PGPASSWORD}
done  > ${db_port}/11.10_ddl.txt


echo "## 11.11 检查是否使用了a-z 0-9 _ 以外的字母作为对象名:   ###"  >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -c 'select distinct datname from (select datname,regexp_split_to_table(datname,$$$$) word from pg_database) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95' -W ${PGPASSWORD} > ${db_port}/11.11_special.txt
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),relname,relkind from (select relname,relkind,regexp_split_to_table(relname,$$$$) word from pg_class) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2,3' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(), typname from (select typname,regexp_split_to_table(typname,$$$$) word from pg_type) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(), proname from (select proname,regexp_split_to_table(proname,$$$$) word from pg_proc where proname !~ $$^RI_FKey_$$) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(),nspname,relname,attname from (select nspname,relname,attname,regexp_split_to_table(attname,$$$$) word from pg_class a,pg_attribute b,pg_namespace c where a.oid=b.attrelid and a.relnamespace=c.oid ) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2,3,4' -W ${PGPASSWORD}
done >> ${db_port}/11.11_special.txt

echo "## 11.12 ----->>>---->>>  锁等待:  ###"  >> ${db_port}/$run_log_file
vsql -x --pset=pager=off    -c "
with    
t_wait as    
(    
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,    
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and not a.granted   
),   
t_run as   
(   
  select a.mode,a.locktype,a.database,a.relation,a.page,a.tuple,a.classid,a.granted,   
  a.objid,a.objsubid,a.pid,a.virtualtransaction,a.virtualxid,a.transactionid,a.fastpath,   
  b.state,b.query,b.xact_start,b.query_start,b.usename,b.datname,b.client_addr,b.client_port,b.application_name   
    from pg_locks a,pg_stat_activity b where a.pid=b.pid and a.granted   
),   
t_overlap as   
(   
  select r.* from t_wait w join t_run r on   
  (   
    r.locktype is not distinct from w.locktype and   
    r.database is not distinct from w.database and   
    r.relation is not distinct from w.relation and   
    r.page is not distinct from w.page and   
    r.tuple is not distinct from w.tuple and   
    r.virtualxid is not distinct from w.virtualxid and   
    r.transactionid is not distinct from w.transactionid and   
    r.classid is not distinct from w.classid and   
    r.objid is not distinct from w.objid and   
    r.objsubid is not distinct from w.objsubid and   
    r.pid <> w.pid   
  )    
),    
t_unionall as    
(    
  select r.* from t_overlap r    
  union all    
  select w.* from t_wait w    
)    
select locktype,datname,relation::regclass,page,tuple,virtualxid,transactionid::text,classid::regclass,objid,objsubid,   
string_agg(   
'Pid: '||case when pid is null then 'NULL' else pid::text end||chr(10)||   
'Lock_Granted: '||case when granted is null then 'NULL' else granted::text end||' , Mode: '||case when mode is null then 'NULL' else mode::text end||' , FastPath: '||case when fastpath is null then 'NULL' else fastpath::text end||' , VirtualTransaction: '||case when virtualtransaction is null then 'NULL' else virtualtransaction::text end||' , Session_State: '||case when state is null then 'NULL' else state::text end||chr(10)||   
'Username: '||case when usename is null then 'NULL' else usename::text end||' , Database: '||case when datname is null then 'NULL' else datname::text end||' , Client_Addr: '||case when client_addr is null then 'NULL' else client_addr::text end||' , Client_Port: '||case when client_port is null then 'NULL' else client_port::text end||' , Application_Name: '||case when application_name is null then 'NULL' else application_name::text end||chr(10)||    
'Xact_Start: '||case when xact_start is null then 'NULL' else xact_start::text end||' , Query_Start: '||case when query_start is null then 'NULL' else query_start::text end||' , Xact_Elapse: '||case when (now()-xact_start) is null then 'NULL' else (now()-xact_start)::text end||' , Query_Elapse: '||case when (now()-query_start) is null then 'NULL' else (now()-query_start)::text end||chr(10)||    
'SQL (Current SQL in Transaction): '||chr(10)||  
case when query is null then 'NULL' else query::text end,    
chr(10)||'--------'||chr(10)    
order by    
  (  case mode    
    when 'INVALID' then 0   
    when 'AccessShareLock' then 1   
    when 'RowShareLock' then 2   
    when 'RowExclusiveLock' then 3   
    when 'ShareUpdateExclusiveLock' then 4   
    when 'ShareLock' then 5   
    when 'ShareRowExclusiveLock' then 6   
    when 'ExclusiveLock' then 7   
    when 'AccessExclusiveLock' then 8   
    else 0   
  end  ) desc,   
  (case when granted then 0 else 1 end)  
) as lock_conflict  
from t_unionall   
group by   
locktype,datname,relation,page,tuple,virtualxid,transactionid::text,classid,objid,objsubid ;    
" -W ${PGPASSWORD} > ${db_port}/11.12_lock_wait.txt



echo "## 11.13 ----->>>---->>>  继承关系检查:   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select inhrelid::regclass,inhparent::regclass,inhseqno from pg_inherits order by 2,3' -W ${PGPASSWORD}
done >${db_port}/11.13_inheritance_checking.txt


echo "## 11.14 ----->>>---->>>  重置统计信息:   ###"  >> ${db_port}/$run_log_file
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select pg_stat_reset()' -W ${PGPASSWORD}
done > ${db_port}/11.14_reset.txt
vsql --pset=pager=off -c 'select pg_stat_reset_shared($$bgwriter$$)' -W ${PGPASSWORD} >> ${db_port}/11.14_reset.txt
echo "----->>>---->>>  重置pg_stat_statements统计信息: " >> ${db_port}/$run_log_file
vsql --pset=pager=off -q -A -c 'select pg_stat_statements_reset()' -W ${PGPASSWORD}  >> ${db_port}/11.14_reset.txt


echo "###########################################################################"  >> ${db_port}/$run_log_file
echo "#                       check replication status                          #"  >> ${db_port}/$run_log_file
echo "###########################################################################"  >> ${db_port}/$run_log_file
is_standby=`vsql --pset=pager=off -q -A -t -c 'select pg_is_in_recovery();' -W ${PGPASSWORD}`

### primary process ###
if [ "$is_standby" = "f" ]; then
touch ${db_port}/${primary_file}
find ./db_inspection/resluts/ -name *${db_port}.tar.gz   -exec rm -rf {} \;
tar zcvf  ./db_inspection/resluts/primary_inspection_`date +"%Y-%m-%d"`_${HOST_NAME}_${db_port}.tar.gz ${db_port}/*.txt
#scp primary_inspection_`date +"%Y-%m-%d"`_${HOST_NAME}_${db_port}.tar.gz root@${mange_ip}:${mange_inspection}
fi  

### secondary process ###
if [ "$is_standby" = "t" ]; then
touch ${db_port}/is_secondary.txt
find ./db_inspection/resluts/ -name *${db_port}.tar.gz   -exec rm -rf {} \;
tar zcvf  ./db_inspection/resluts/secondary_inspection_`date +"%Y-%m-%d"`_${HOST_NAME}_${db_port}.tar.gz ${db_port}/*.txt
#scp primary_inspection_`date +"%Y-%m-%d"`_${HOST_NAME}_${db_port}.tar.gz root@${mange_ip}:${mange_inspection}
fi