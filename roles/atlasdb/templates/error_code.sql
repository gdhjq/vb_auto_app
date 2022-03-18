CREATE TABLE error_log
(
    log_time timestamp(3) with time zone,
    node_name text,
    user_name text,
    database_name text,
    process_id bigint,
    connection_from text,
    "session_id" text,
    session_line_num bigint,
    command_tag text,
    session_start_time timestamp with time zone,
    virtual_transaction_id text,
    transaction_id bigint,
    query_id bigint,
    module text,
    error_severity text,
    sql_state_code text,
    message text,
    detail text,
    hint text,
    internal_query text,
    internal_query_pos integer,
    context text,
    query text,
    query_pos integer,
    location text,
    application_name text
);

COMMENT ON TABLE error_log IS '错误日志表';
 
--COPY error_log FROM '/home/vastbase/data/pg_log/postgresql-2021-12-08.csv' WITH csv;

create table error_code
(
    code_id  numeric(10,0) NOT NULL,
    e_sqlstate varchar(20),
    e_standard varchar(1),
    errcode_macro_name varchar(200),
    spec_name  varchar(100),
    e_type     varchar(50),
    e_type_definition varchar(50),
    e_remark  text
);

COMMENT ON TABLE error_code IS '错误代码定义表';
COMMENT ON COLUMN error_code.e_sqlstate IS '错误编码';
COMMENT ON COLUMN error_code.e_standard IS '错误定义';



create table error_result 
(
    e_id  numeric(10,0) NOT NULL,
    e_sqlstate varchar(20),
    e_gauss_number varchar(25),
    e_message    varchar(255),
    e_cause    text ,
    e_solution  text ,
    inset_time  timestamp with time zone ,
    update_time timestamp with time zone default now(),
    e_library   text,
    e_remark    text 
);

COMMENT ON TABLE error_result IS '错误代码结果表';
COMMENT ON COLUMN error_result.e_sqlstate IS '错误编码';
COMMENT ON COLUMN error_result.e_gauss_number IS 'opengauss官方定义码';
COMMENT ON COLUMN error_result.e_message IS '内容';
COMMENT ON COLUMN error_result.e_cause IS '错误原因';
COMMENT ON COLUMN error_result.e_solution IS '解决方法';
COMMENT ON COLUMN error_result.update_time IS '修改时间';
COMMENT ON COLUMN error_result.e_library IS '官方技术库';




-- 定时将日志导入数据库
CREATE OR REPLACE PROCEDURE  error_job()
AS 
declare 
e_date varchar = to_char(now()-1,'yyyy-mm-dd HH') ;
e_log_date varchar = to_char(now(),'yyyy-mm-dd');
e_log_dir  varchar = '';
e_data_dir  varchar = '';
e_log_directory varchar = 'log_directory';
e_data_directory varchar = 'data_directory';
begin
-- 清理错误日志表内容
truncate error_log ;

--导入当天日志情况
EXECUTE format('select setting from pg_settings where name=''%s'' ', e_log_directory) into e_log_dir;
EXECUTE format('select setting from pg_settings where name=''%s'' ',e_data_directory) into e_data_dir;
EXECUTE format('COPY error_log FROM ''%s/%s/postgresql-%s.csv'' WITH csv',e_data_dir,e_log_dir,e_log_date);

--删除LOG WARNING报错信息
--select count(*),sql_state_code,error_severity from public.error_log group by sql_state_code,error_severity;
delete from error_log where error_severity in ('LOG','WARNING');

--更新错误日志中登录失败 error code 代码
update error_log a SET a.sql_state_code ='42704' where a.message='Invalid username/password,login denied.';
end;
/

--创建定时任务
select dbms_job.submit(512,'begin  error_job; end;' ,sysdate,'sysdate + 1/24');


--查询错误
select
	ec.e_sqlstate ,
	el.message,
	ev.e_cause ,
	ev.e_solution ,
	ev.e_gauss_number ,
	el.session_start_time ,
	ev.e_library 
from
	public.error_code ec ,
	public.error_log el,
	public.error_result ev
where
	ec.e_sqlstate = el.sql_state_code
	and ec.e_sqlstate = ev.e_sqlstate 
	and el.message =ev.e_message 
	and ec.e_sqlstate ='42704';
	