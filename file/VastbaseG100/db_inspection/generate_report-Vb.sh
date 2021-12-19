#!/bin/bash

# 用法  . ./generate_report-Vb.sh >/home/vastbase/report.log 2>&1
# 生成报告目录   grep -E "^----->>>|^\|" /home/vastbase/report.log | sed 's/^----->>>---->>>/    /' | sed '1 i\ \ 目录\n\n' | sed '$ a\ \n\n\ \ 正文\n\n'


#数据库配置
#vastbase_login_info = off  关闭登陆输出   

# 请将以下变量修改为与当前环境一致, 并且确保使用这个配置连接任何数据库都不需要输入密码
export PGHOST=10.195.25.14
export PGPORT=15432
export PGDATABASE=cicgroup
export PGUSER=vastuser
export PGPASSWORD=Vbase@admin
export PGDATA=/data/vastbase
export GAUSSHOME=/home/vastbase/local/vastbase

export PATH=$GAUSSHOME/bin:$PATH:
export DATE=`date +"%Y%m%d%H%M"`
export LD_LIBRARY_PATH=$GAUSSHOME/lib:/lib64:/usr/lib64:/usr/local/lib64:/lib:/usr/lib:/usr/local/lib:$LD_LIBRARY_PATH
pg_log_dir=/data/vastbase/pg_log

##数据库用户家目录
os_home=/home/vastbase
# 记住当前目录
PWD=`pwd`

# 获取postgresql日志目录
###pg_log_dir=`grep '^\ *[a-z]' $PGDATA/postgresql.conf|awk -F "#" '{print $1}'|grep log_directory|awk -F "=" '{print $2}'`

# 检查是否standby
is_standby=`vsql --pset=pager=off -q -A -t -c 'select pg_is_in_recovery()' -W ${PGPASSWORD}`


echo "    ----- Vastbase 巡检报告 -----  "
echo "    ===== $DATE        =====  "


if [ $is_standby == 't' ]; then
echo "    ===== 这是standby节点     =====  "
else
echo "    ===== 这是primary节点     =====  "
fi
echo ""


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                      操作系统信息                       |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  主机名: "
hostname -s
echo ""
echo "----->>>---->>>  IP地址信息: "
ip addr show
echo ""
echo "----->>>---->>>  路由信息: "
ip route show
echo ""
echo "----->>>---->>>  操作系统内核: "
uname -a
echo ""
echo "----->>>---->>>  内存(MB): "
free -m
echo ""
echo "----->>>---->>>  CPU: "
lscpu
echo ""
echo "----->>>---->>>  块设备: "
lsblk
echo ""
echo "----->>>---->>>  操作系统配置文件 静态配置信息: "
echo "----->>>---->>>  /etc/sysctl.conf "
grep "^[a-z]" /etc/sysctl.conf
echo ""
echo "----->>>---->>>  /etc/security/limits.conf "
grep -v "^#" /etc/security/limits.conf|grep -v "^$"
echo ""
echo "----->>>---->>>  /etc/security/limits.d/*.conf "
for dir in `ls /etc/security/limits.d`; do echo "/etc/security/limits.d/$dir : "; grep -v "^#" /etc/security/limits.d/$dir|grep -v "^$"; done 
echo ""
echo "----->>>---->>>  /etc/fstab "
cat /etc/fstab
echo ""
echo "----->>>---->>>  /etc/selinux/config "
cat /etc/selinux/config
echo ""
echo "----->>>---->>>  selinux 动态配置信息: "
getsebool
sestatus
echo ""
echo "----->>>---->>>  建议禁用Transparent Huge Pages (THP): "
cat /sys/kernel/mm/transparent_hugepage/enabled 
cat /sys/kernel/mm/transparent_hugepage/defrag
echo ""
echo "----->>>---->>>  硬盘SMART信息(需要root): "
smartctl --scan|awk -F "#" '{print $1}' | while read i; do echo -e "\n\nDEVICE $i"; smartctl -a $i; done
echo ""
echo "----->>>---->>>  /var/log/cron(需要root) "
cat /var/log/cron
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                       数据库信息                        |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  数据库版本: "
vsql --pset=pager=off -q -c 'select version()' -W ${PGPASSWORD}

echo "----->>>---->>>  用户已安装的插件版本: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),* from pg_extension' -W ${PGPASSWORD}
done

echo "----->>>---->>>  用户使用了多少种数据类型: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),b.typname,count(*) from pg_attribute a,pg_type b where a.atttypid=b.oid and a.attrelid in (select oid from pg_class where relnamespace not in (select oid from pg_namespace where nspname ~ $$^pg_$$ or nspname=$$information_schema$$)) group by 1,2 order by 3 desc ' -W ${PGPASSWORD}
done

echo "----->>>---->>>  用户创建了多少对象: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),rolname,nspname,relkind,count(*) from pg_class a,pg_authid b,pg_namespace c where a.relnamespace=c.oid and a.relowner=b.oid and nspname !~ $$^pg_$$ and nspname<>$$information_schema$$ group by 1,2,3,4 order by 5 desc' -W ${PGPASSWORD}
done

echo "----->>>---->>>  用户对象占用空间的柱状图: "
for db in `psql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),buk this_buk_no,cnt rels_in_this_buk,pg_size_pretty(min) buk_min,pg_size_pretty(max) buk_max from( select row_number() over (partition by buk order by tsize),tsize,buk,min(tsize) over (partition by buk),max(tsize) over (partition by buk),count(*) over (partition by buk) cnt from ( select pg_relation_size(a.oid) tsize, width_bucket(pg_relation_size(a.oid),tmin-1,tmax+1,10) buk from (select min(pg_relation_size(a.oid)) tmin,max(pg_relation_size(a.oid)) tmax from pg_class a,pg_namespace c where a.relnamespace=c.oid and nspname !~ $$^pg_$$ and nspname<>$$information_schema$$) t, pg_class a,pg_namespace c where a.relnamespace=c.oid and nspname !~ $$^pg_$$ and nspname<>$$information_schema$$ ) t)t where row_number=1;' -W ${PGPASSWORD}
done

echo "----->>>---->>>  当前用户的操作系统定时任务: "
echo "I am `whoami`"
crontab -l
echo "建议: "
echo "    仔细检查定时任务的必要性, 以及定时任务的成功与否的评判标准, 以及监控措施. "
echo "    请以启动数据库的OS用户执行本脚本. "
echo -e "\n"


common() {
# 进入pg_log工作目录
cd $PGDATA
eval cd $pg_log_dir

echo "----->>>---->>>  获取pg_hba.conf md5值: "
md5sum $PGDATA/pg_hba.conf
echo "建议: "
echo "    主备md5值一致(判断主备配置文件是否内容一致的一种手段, 或者使用diff)."
echo -e "\n"

echo "----->>>---->>>  获取pg_hba.conf配置: "
grep '^\ *[a-z]' $PGDATA/pg_hba.conf
echo "建议: "
echo "    主备配置尽量保持一致, 注意trust和password认证方法的危害(password方法 验证时网络传输密码明文, 建议改为md5), 建议除了unix socket可以使用trust以外, 其他都使用md5或者LDAP认证方法."
echo "    建议先设置白名单(超级用户允许的来源IP, 可以访问的数据库), 再设置黑名单(不允许超级用户登陆, reject), 再设置白名单(普通应用), 参考pg_hba.conf中的描述. "
echo -e "\n"

echo "----->>>---->>>  获取postgresql.conf md5值: "
md5sum $PGDATA/postgresql.conf
echo "建议: "
echo "    主备md5值一致(判断主备配置文件是否内容一致的一种手段, 或者使用diff)."
echo -e "\n"

echo "----->>>---->>>  获取postgresql.conf配置: "
grep '^\ *[a-z]' $PGDATA/postgresql.conf|awk -F "#" '{print $1}'
echo "建议: "
echo "    主备配置尽量保持一致, 配置合理的参数值."
echo -e "    建议修改的参数列表如下  ( 假设操作系统内存为512GB, 数据库独占操作系统, 数据库版本v2.2.4, 其他版本可能略有不同, 未来再更新进来 )  : 
echo ""
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
\n "

echo "----->>>---->>>  用户或数据库级别定制参数: "
vsql --pset=pager=off -q -c 'select * from pg_db_role_setting' -W ${PGPASSWORD}
echo "建议: "
echo "    定制参数需要关注, 优先级高于数据库的启动参数和配置文件中的参数, 特别是排错时需要关注. "
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                   数据库错误日志分析                    |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

log_date=`date +"%Y-%m"`

echo "----->>>---->>>  获取错误日志信息: "
cat postgresql-${log_date}*.log | grep -E "^[0-9]" | grep -E "ERROR|FATAL|PANIC" |sort -rn
echo "建议: "
echo "    参考 http://www.postgresql.org/docs/current/static/errcodes-appendix.html ."
echo -e "\n"

echo "----->>>---->>>  获取连接请求情况: "
find . -name "postgresql-${log_date}*.log" -type f -mtime -28 -exec grep "connection authorized" {} +|sort|uniq |sort -n -r
echo "建议: "
echo "    连接请求非常多时, 请考虑应用层使用连接池, 或者使用pgbouncer连接池. "
echo -e "\n"

echo "----->>>---->>>  获取认证失败情况: "
find . -name "postgresql-${log_date}*.log" -type f -mtime -28 -exec grep "password authentication failed" {} +|sort|uniq|sort -n -r
echo "建议: "
echo "    认证失败次数很多时, 可能是有用户在暴力破解, 建议使用auth_delay插件防止暴力破解. "
echo -e "\n"




echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                   数据库空间使用分析                    |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  输出文件系统剩余空间: "
df -m
echo "建议: "
echo "    注意预留足够的空间给数据库. "
echo -e "\n"

echo "----->>>---->>>  输出表空间对应目录: "
echo $PGDATA
ls -la $PGDATA/pg_tblspc/
echo "建议: "
echo "    注意表空间如果不是软链接, 注意是否刻意所为, 正常情况下应该是软链接. "
echo -e "\n"

echo "----->>>---->>>  输出表空间使用情况: "
vsql --pset=pager=off -q -c 'select spcname,pg_tablespace_location(oid),pg_size_pretty(pg_tablespace_size(oid)) from pg_tablespace order by pg_tablespace_size(oid) desc' -W ${PGPASSWORD}
echo "建议: "
echo "    注意检查表空间所在文件系统的剩余空间, (默认表空间在$PGDATA/base目录下), IOPS分配是否均匀, OS的sysstat包可以观察IO使用率. "
echo -e "\n"

echo "----->>>---->>>  输出数据库使用情况: "
vsql --pset=pager=off -q -c 'select datname,pg_size_pretty(pg_database_size(oid)) from pg_database order by pg_database_size(oid) desc' -W ${PGPASSWORD}
echo "建议: "
echo "    注意检查数据库的大小, 是否需要清理历史数据. "
echo -e "\n"

echo "----->>>---->>>  TOP 10 size对象: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),b.nspname,c.relname,c.relkind,pg_size_pretty(pg_relation_size(c.oid)),a.seq_scan,a.seq_tup_read,a.idx_scan,a.idx_tup_fetch,a.n_tup_ins,a.n_tup_upd,a.n_tup_del,a.n_tup_hot_upd,a.n_live_tup,a.n_dead_tup from pg_stat_all_tables a, pg_class c,pg_namespace b where c.relnamespace=b.oid and c.relkind=$$r$$ and a.relid=c.oid order by pg_relation_size(c.oid) desc limit 10' -W ${PGPASSWORD}
done
echo "建议: "
echo "    经验值: 单表超过8GB, 并且这个表需要频繁更新 或 删除+插入的话, 建议对表根据业务逻辑进行合理拆分后获得更好的性能, 以及便于对膨胀索引进行维护; 如果是只读的表, 建议适当结合SQL语句进行优化. "
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                     数据库连接分析                      |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  当前活跃度: "
vsql --pset=pager=off -q -c 'select now(),state,count(*) from pg_stat_activity group by 1,2' -W ${PGPASSWORD}
echo "建议: "
echo "    如果active状态很多, 说明数据库比较繁忙. 如果idle in transaction很多, 说明业务逻辑设计可能有问题. 如果idle很多, 可能使用了连接池, 并且可能没有自动回收连接到连接池的最小连接数. "
echo -e "\n"

echo "----->>>---->>>  总剩余连接数: " 
vsql --pset=pager=off -q -c 'select max_conn,used,res_for_super,max_conn-used-res_for_super res_for_normal from (select count(*) used from pg_stat_activity) t1,(select setting::int res_for_super from pg_settings where name=$$superuser_reserved_connections$$) t2,(select setting::int max_conn from pg_settings where name=$$max_connections$$) t3' -W ${PGPASSWORD}
echo "建议: "
echo "    给超级用户和普通用户设置足够的连接, 以免不能登录数据库. "
echo -e "\n"

echo "----->>>---->>>  用户连接数限制: "
vsql --pset=pager=off -q -c 'select a.rolname,a.rolconnlimit,b.connects from pg_authid a,(select usename,count(*) connects from pg_stat_activity group by usename) b where a.rolname=b.usename order by b.connects desc' -W ${PGPASSWORD}
echo "建议: "
echo "    给用户设置足够的连接数, alter role ... CONNECTION LIMIT . "
echo -e "\n"

echo "----->>>---->>>  数据库连接限制: "
vsql --pset=pager=off -q -c 'select a.datname, a.datconnlimit, b.connects from pg_database a,(select datname,count(*) connects from pg_stat_activity group by datname) b where a.datname=b.datname order by b.connects desc' -W ${PGPASSWORD}
echo "建议: "
echo "    给数据库设置足够的连接数, alter database ... CONNECTION LIMIT . "
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                     数据库性能分析                      |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  TOP 5 SQL : total_cpu_time "
vsql --pset=pager=off -q -x -c 'select c.rolname,b.datname,a.total_time/a.calls per_call_time,a.* from pg_stat_statements a,pg_database b,pg_authid c where a.userid=c.oid and a.dbid=b.oid order by a.total_time desc limit 5' -W ${PGPASSWORD}
echo "建议: "
echo "    检查SQL是否有优化空间, 配合auto_explain插件在csvlog中观察LONG SQL的执行计划是否正确. "
echo -e "\n"

echo "----->>>---->>>  索引数超过4并且SIZE大于10MB的表: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(), t2.nspname, t1.relname, pg_size_pretty(pg_relation_size(t1.oid)), t3.idx_cnt from pg_class t1, pg_namespace t2, (select indrelid,count(*) idx_cnt from pg_index group by 1 having count(*)>4) t3 where t1.oid=t3.indrelid and t1.relnamespace=t2.oid and pg_relation_size(t1.oid)/1024/1024.0>10 order by t3.idx_cnt desc' -W ${PGPASSWORD}
done
echo "建议: "
echo "    索引数量太多, 影响表的增删改性能, 建议检查是否有不需要的索引. "
echo -e "\n"

echo "----->>>---->>>  上次巡检以来未使用或使用较少的索引: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),t2.schemaname,t2.relname,t2.indexrelname,t2.idx_scan,t2.idx_tup_read,t2.idx_tup_fetch,pg_size_pretty(pg_relation_size(indexrelid)) from pg_stat_all_tables t1,pg_stat_all_indexes t2 where t1.relid=t2.relid and t2.idx_scan<10 and t2.schemaname not in ($$pg_toast$$,$$pg_catalog$$) and indexrelid not in (select conindid from pg_constraint where contype in ($$p$$,$$u$$,$$f$$)) and pg_relation_size(indexrelid)>65536 order by pg_relation_size(indexrelid) desc' -W ${PGPASSWORD}
done
echo "建议: "
echo "    建议和应用开发人员确认后, 删除不需要的索引. "
echo -e "\n"

echo "----->>>---->>>  数据库统计信息, 回滚比例, 命中比例, 数据块读写时间, 死锁, 复制冲突: "
vsql --pset=pager=off -q -c 'select datname,round(100*(xact_rollback::numeric/(case when xact_commit > 0 then xact_commit else 1 end + xact_rollback)),2)||$$ %$$ rollback_ratio, round(100*(blks_hit::numeric/(case when blks_read>0 then blks_read else 1 end + blks_hit)),2)||$$ %$$ hit_ratio, blk_read_time, blk_write_time, conflicts, deadlocks from pg_stat_database' -W ${PGPASSWORD}
echo "建议: "
echo "    回滚比例大说明业务逻辑可能有问题, 命中率小说明shared_buffer要加大, 数据块读写时间长说明块设备的IO性能要提升, 死锁次数多说明业务逻辑有问题, 复制冲突次数多说明备库可能在跑LONG SQL. "
echo -e "\n"

echo "----->>>---->>>  检查点, bgwriter 统计信息: "
vsql --pset=pager=off -q -x -c 'select * from pg_stat_bgwriter'  -W ${PGPASSWORD}
echo "建议: "
echo "    checkpoint_write_time多说明检查点持续时间长, 检查点过程中产生了较多的脏页. "
echo "    checkpoint_sync_time代表检查点开始时的shared buffer中的脏页被同步到磁盘的时间, 如果时间过长, 并且数据库在检查点时性能较差, 考虑一下提升块设备的IOPS能力. "
echo "    buffers_backend_fsync太多说明需要加大shared buffer 或者 减小bgwriter_delay参数. "
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                     数据库垃圾分析                      |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"


echo "----->>>---->>>  索引膨胀检查: "
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
done
echo "建议: "
echo "    如果索引膨胀太大, 会影响性能, 建议重建索引, create index CONCURRENTLY ... . "
echo "    根据浪费的字节数, 设置合适的autovacuum_vacuum_scale_factor, 大表如果频繁的有更新或删除和插入操作, 建议设置较小的autovacuum_vacuum_scale_factor来降低浪费空间. "
echo "    同时还需要打开autovacuum, 根据服务器的内存大小, CPU核数, 设置足够大的autovacuum_work_mem 或 autovacuum_max_workers 或 maintenance_work_mem, 以及足够小的 autovacuum_naptime . "
echo "    同时还需要分析是否对大数据库使用了逻辑备份pg_dump, 系统中是否经常有长SQL, 长事务. 这些都有可能导致膨胀. "
echo "    使用pg_reorg或者vacuum full可以回收膨胀的空间. "
echo "    参考: http://blog.163.com/digoal@126/blog/static/1638770402015329115636287/ "
echo "    otta评估出的表实际需要页数, iotta评估出的索引实际需要页数; "
echo "    bs数据库的块大小; "
echo "    tbloat表膨胀倍数, ibloat索引膨胀倍数, wastedpages表浪费了多少个数据块, wastedipages索引浪费了多少个数据块; "
echo "    wastedbytes表浪费了多少字节, wastedibytes索引浪费了多少字节; "
echo -e "\n"

echo "----->>>---->>>  垃圾数据: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),schemaname,relname,n_dead_tup from pg_stat_all_tables where n_live_tup>0 and n_dead_tup/n_live_tup>0.2 and schemaname not in ($$pg_toast$$,$$pg_catalog$$) order by n_dead_tup desc limit 5' -W ${PGPASSWORD}
done
echo "建议: "
echo "    通常垃圾过多, 可能是因为无法回收垃圾, 或者回收垃圾的进程繁忙或没有及时唤醒, 或者没有开启autovacuum, 或在短时间内产生了大量的垃圾 . "
echo "    可以等待autovacuum进行处理, 或者手工执行vacuum table . "
echo -e "\n"



echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                     数据库年龄分析                      |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  数据库年龄: "
vsql --pset=pager=off -q -c 'SELECT datname, age(datfrozenxid64) FROM pg_database order by age(datfrozenxid64) desc' -W ${PGPASSWORD}
echo "建议: "
echo "    数据库的年龄正常情况下应该小于vacuum_freeze_table_age, 如果剩余年龄小于5亿, 建议人为干预, 将LONG SQL或事务杀掉后, 执行vacuum freeze . "
echo -e "\n"

echo "----->>>---->>>  表年龄: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c "SELECT c.oid::regclass as table_name,greatest(age(c.relfrozenxid64),age(t.relfrozenxid64)) as age FROM pg_class c  LEFT JOIN pg_class t ON c.reltoastrelid = t.oid WHERE c.relkind IN ('r', 'm') order by 2 desc limit 5;" -W ${PGPASSWORD}
done
echo "建议: "
echo "    表的年龄正常情况下应该小于vacuum_freeze_table_age, 如果剩余年龄小于5亿, 建议人为干预, 将LONG SQL或事务杀掉后, 执行vacuum freeze . "
echo -e "\n"

echo "----->>>---->>>  长事务, 2PC: "
vsql --pset=pager=off -q -x -c 'select datname,usename,query,xact_start,now()-xact_start xact_duration,query_start,now()-query_start query_duration,state from pg_stat_activity where state<>$$idle$$  and now()-xact_start > interval $$30 min$$ order by xact_start' -W ${PGPASSWORD}
vsql --pset=pager=off -q -x -c 'select name,statement,prepare_time,now()-prepare_time,parameter_types,from_sql from pg_prepared_statements where now()-prepare_time > interval $$30 min$$ order by prepare_time' -W ${PGPASSWORD}
echo "建议: "
echo "    长事务过程中产生的垃圾, 无法回收, 建议不要在数据库中运行LONG SQL, 或者错开DML高峰时间去运行LONG SQL. 2PC事务一定要记得尽快结束掉, 否则可能会导致数据库膨胀. "
echo "    参考: http://blog.163.com/digoal@126/blog/static/1638770402015329115636287/ "
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|               数据库XLOG, 流复制状态分析                |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  是否开启归档, 自动垃圾回收: "
vsql --pset=pager=off -q -c 'select name,setting from pg_settings where name in ($$archive_mode$$,$$autovacuum$$,$$archive_command$$)' -W ${PGPASSWORD}
echo "建议: "
echo "    建议开启自动垃圾回收, 开启归档. "
echo -e "\n"

echo "----->>>---->>>  归档统计信息: "
vsql --pset=pager=off -q -c 'select pg_xlogfile_name(pg_current_xlog_insert_location())' -W ${PGPASSWORD}
echo "建议: "
echo "    如果当前的XLOG文件和最后一个归档失败的XLOG文件之间相差很多个文件, 建议尽快排查归档失败的原因, 以便修复, 否则pg_xlog目录可能会撑爆. "
echo -e "\n"

echo "----->>>---->>>  流复制统计信息: "
vsql --pset=pager=off -q -x -c 'select pid,state,client_addr,pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_insert_location(),sender_sent_location)) sent_delay, pg_size_pretty(pg_xlog_location_diff(pg_current_xlog_insert_location(),receiver_replay_location))  replay_delay, sync_priority,sync_state   from pg_stat_replication' -W ${PGPASSWORD}
echo "建议: "
echo "    关注流复制的延迟, 如果延迟非常大, 建议排查网络带宽, 以及本地读xlog的性能, 远程写xlog的性能. "
echo -e "\n"

echo "----->>>---->>>  流复制插槽: "
vsql --pset=pager=off -q -c ' select pg_xlog_location_diff(pg_current_xlog_insert_location(),restart_lsn), * from pg_replication_slots;' -W ${PGPASSWORD}
echo "建议: "
echo "    如果restart_lsn和当前XLOG相差非常大的字节数, 需要排查slot的订阅者是否能正常接收XLOG, 或者订阅者是否正常. 长时间不将slot的数据取走, pg_xlog目录可能会撑爆. "
echo -e "\n"


echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo "|                数据库安全或潜在风险分析                 |"
echo "|+++++++++++++++++++++++++++++++++++++++++++++++++++++++++|"
echo ""

echo "----->>>---->>>  密码泄露检查: "
echo "    检查 ~/.psql_history :  "
grep -i "password" ${os_home}/.vsql_history|grep -i -E "role|group|user"
echo ""
echo "    检查 *.csv :  "
cat postgresql-${log_date}*.log | grep -E "^[0-9]" | grep -i -r -E "role|group|user" |grep -i "password"|grep -i -E "create|alter"
echo ""
echo "    检查 pg_stat_statements :  "
vsql --pset=pager=off -c 'select query from pg_stat_statements where (query ~* $$group$$ or query ~* $$user$$ or query ~* $$role$$) and query ~* $$password$$'  -W ${PGPASSWORD}
echo "    检查 pg_authid :  "
vsql --pset=pager=off -q -c 'select * from pg_authid where rolpassword !~ $$^md5$$ or length(rolpassword)<>35' -W ${PGPASSWORD}
echo "    检查 pg_user_mappings, pg_views :  "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select current_database(),* from pg_user_mappings where umoptions::text ~* $$password$$' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -c 'select current_database(),* from pg_views where definition ~* $$password$$ and definition ~* $$dblink$$' -W ${PGPASSWORD}
done
echo "建议: "
echo "    如果以上输出显示密码已泄露, 尽快修改, 并通过参数避免密码又被记录到以上文件中(vsql -n) (set log_statement='none'; set log_min_duration_statement=-1; set log_duration=off; set pg_stat_statements.track_utility=off;) . "
echo "    明文密码不安全, 建议使用create|alter role ... encrypted password. "
echo "    在fdw, dblink based view中不建议使用密码明文. "
echo -e "\n"

echo "----->>>---->>>  简单密码检查: "
echo "    1. 检查已有密码是否简单, 从crackdb库提取密码字典, 挨个检查 :  "
echo "    检查 md5('$pwd'||'$username')是否与pg_authid.rolpassword匹配 :  "
echo "    匹配则说明用户使用了简单密码 :  "
echo ""
echo "    2. 事前检查参考 http://blog.163.com/digoal@126/blog/static/16387704020149852941586"
echo -e "\n"

echo "----->>>---->>>  用户密码到期时间: "
vsql --pset=pager=off -q -c 'select rolname,rolvaliduntil from pg_authid order by rolvaliduntil' -W ${PGPASSWORD}
echo "建议: "
echo "    到期后, 用户将无法登陆, 记得修改密码, 同时将密码到期时间延长到某个时间或无限时间, alter role ... VALID UNTIL 'timestamp' . "
echo -e "\n"


echo "----->>>---->>>  普通用户对象上的规则安全检查: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select current_database(),a.schemaname,a.tablename,a.rulename,a.definition from pg_rules a,pg_namespace b,pg_class c,pg_authid d where a.schemaname=b.nspname and a.tablename=c.relname and d.oid=c.relowner and not d.rolsuper union all select current_database(),a.schemaname,a.viewname,a.viewowner,a.definition from pg_views a,pg_namespace b,pg_class c,pg_authid d where a.schemaname=b.nspname and a.viewname=c.relname and d.oid=c.relowner and not d.rolsuper' -W ${PGPASSWORD}
done
echo "建议: "
echo "    防止普通用户在规则中设陷阱, 注意有危险的security invoker的函数调用, 超级用户可能因为规则触发后误调用这些危险函数(以invoker角色). "
echo "    参考 http://blog.163.com/digoal@126/blog/static/16387704020155131217736/ "
echo -e "\n"

echo "----->>>---->>>  普通用户自定义函数安全检查: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select current_database(),b.rolname,c.nspname,a.proname from pg_proc a,pg_authid b,pg_namespace c where a.proowner=b.oid and a.pronamespace=c.oid and not b.rolsuper and not a.prosecdef' -W ${PGPASSWORD}
done
echo "建议: "
echo "    防止普通用户在函数中设陷阱, 注意有危险的security invoker的函数调用, 超级用户可能因为触发器触发后误调用这些危险函数(以invoker角色). "
echo "    参考 http://blog.163.com/digoal@126/blog/static/16387704020155131217736/ "
echo -e "\n"

echo "----->>>---->>>  unlogged table 和 哈希索引: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),t3.rolname,t2.nspname,t1.relname from pg_class t1,pg_namespace t2,pg_authid t3 where t1.relnamespace=t2.oid and t1.relowner=t3.oid and t1.relpersistence=$$u$$' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(),pg_get_indexdef(oid) from pg_class where relkind=$$i$$ and pg_get_indexdef(oid) ~ $$USING hash$$' -W ${PGPASSWORD}
done
echo "建议: "
echo "    unlogged table和hash index不记录XLOG, 无法使用流复制或者log shipping的方式复制到standby节点, 如果在standby节点执行某些SQL, 可能导致报错或查不到数据. "
echo "    在数据库CRASH后无法修复unlogged table和hash index, 不建议使用. "
echo "    PITR对unlogged table和hash index也不起作用. "
echo -e "\n"



echo "----->>>---->>>  触发器, 事件触发器: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),relname,tgname,proname,tgenabled from pg_trigger t1,pg_class t2,pg_proc t3 where t1.tgfoid=t3.oid and t1.tgrelid=t2.oid' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(),owner,schema_name,trigger_name,trigger_type,triggering_event,trigger_body,action_statement from all_triggers' -W ${PGPASSWORD}
done
echo "建议: "
echo "    请管理员注意触发器和事件触发器的必要性. "
echo -e "\n"

echo "----->>>---->>>  检查是否使用了a-z 0-9 _ 以外的字母作为对象名: "
vsql --pset=pager=off -q -c 'select distinct datname from (select datname,regexp_split_to_table(datname,$$$$) word from pg_database) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95' -W ${PGPASSWORD}
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select current_database(),relname,relkind from (select relname,relkind,regexp_split_to_table(relname,$$$$) word from pg_class) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2,3' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(), typname from (select typname,regexp_split_to_table(typname,$$$$) word from pg_type) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(), proname from (select proname,regexp_split_to_table(proname,$$$$) word from pg_proc where proname !~ $$^RI_FKey_$$) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2' -W ${PGPASSWORD}
vsql -d $db --pset=pager=off -q -c 'select current_database(),nspname,relname,attname from (select nspname,relname,attname,regexp_split_to_table(attname,$$$$) word from pg_class a,pg_attribute b,pg_namespace c where a.oid=b.attrelid and a.relnamespace=c.oid ) t where (not (ascii(word) >=97 and ascii(word) <=122)) and (not (ascii(word) >=48 and ascii(word) <=57)) and ascii(word)<>95 group by 1,2,3,4' -W ${PGPASSWORD}
done
echo "建议: "
echo "    建议任何identify都只使用 a-z, 0-9, _ (例如表名, 列名, 视图名, 函数名, 类型名, 数据库名, schema名, 物化视图名等等). "
echo "    identify 用法 https://yq.aliyun.com/articles/52883 . "
echo "    https://www.postgresql.org/docs/9.5/static/sql-keywords-appendix.html . "
echo "    https://www.postgresql.org/docs/9.5/static/sql-syntax-lexical.html#SQL-SYNTAX-IDENTIFIERS . "
echo -e "\n"

echo "----->>>---->>>  锁等待: "
vsql -x --pset=pager=off  -W ${PGPASSWORD} <<EOF
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
EOF
echo "建议: "
echo "    锁等待状态, 反映业务逻辑的问题或者SQL性能有问题, 建议深入排查持锁的SQL. "
echo -e "\n"

echo "----->>>---->>>  继承关系检查: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -q -c 'select inhrelid::regclass,inhparent::regclass,inhseqno from pg_inherits order by 2,3' -W ${PGPASSWORD}
done
echo "建议: "
echo "    如果使用继承来实现分区表, 注意分区表的触发器中逻辑是否正常, 对于时间模式的分区表是否需要及时加分区, 修改触发器函数 . "
echo "    建议继承表的权限统一, 如果权限不一致, 可能导致某些用户查询时权限不足. "
echo -e "\n"


echo "----->>>---->>>  重置统计信息: "
for db in `vsql --pset=pager=off -t -A -q -c 'select datname from pg_database where datname not in ($$template0$$, $$template1$$)' -W ${PGPASSWORD}`
do
vsql -d $db --pset=pager=off -c 'select pg_stat_reset()' -W ${PGPASSWORD}
done
vsql --pset=pager=off -c 'select pg_stat_reset_shared($$bgwriter$$)' -W ${PGPASSWORD}
#vsql --pset=pager=off -c 'select pg_stat_reset_shared($$archiver$$)'

echo "----->>>---->>>  重置pg_stat_statements统计信息: "
vsql --pset=pager=off -q -A -c 'select pg_stat_statements_reset()' -W ${PGPASSWORD}

}  # common function end

common
cd $pwd
#return 0

#  备注
#  csv日志分析需要优化
#  某些操作需要root
