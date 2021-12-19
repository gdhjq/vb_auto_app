--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET xmloption = content;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: error_result; Type: TABLE; Schema: public; Owner: vastbase; Tablespace: 
--

CREATE TABLE error_result (
    e_id numeric(10,0) NOT NULL,
    e_sqlstate varchar(20),
    e_gauss_number varchar(25),
    e_message varchar(255),
    e_cause text,
    e_solution text,
    inset_time timestamp with time zone,
    update_time timestamp with time zone DEFAULT now(),
    e_library text,
    e_remark text
)
WITH (orientation=row, compression=no);


ALTER TABLE public.error_result OWNER TO vastbase;

--
-- Name: TABLE error_result; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON TABLE error_result IS '错误代码结果表';


--
-- Name: COLUMN error_result.e_sqlstate; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.e_sqlstate IS '错误编码';


--
-- Name: COLUMN error_result.e_gauss_number; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.e_gauss_number IS 'opengauss官方定义码';


--
-- Name: COLUMN error_result.e_message; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.e_message IS '内容';


--
-- Name: COLUMN error_result.e_cause; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.e_cause IS '错误原因';


--
-- Name: COLUMN error_result.e_solution; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.e_solution IS '解决方法';


--
-- Name: COLUMN error_result.update_time; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.update_time IS '修改时间';


--
-- Name: COLUMN error_result.e_library; Type: COMMENT; Schema: public; Owner: vastbase
--

COMMENT ON COLUMN error_result.e_library IS '官方技术库';


--
-- Data for Name: error_result; Type: TABLE DATA; Schema: public; Owner: vastbase
--

COPY error_result (e_id, e_sqlstate, e_gauss_number, e_message, e_cause, e_solution, inset_time, update_time, e_library, e_remark) FROM stdin;
1	42883	GAUSS-00001	operator does not exist: %s	所指定使用的操作符不存在	建议错误信息中包含操作符所涉及的类型，以便在系统表中查询是否存在相关的	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	https://support.huaweicloud.com/errorcode-dws/dws_08_0003.html	\N
2	42883	GAUSS-00002	could not identify an ordering operator for type %s	对于需要进行 sort/group 操作时，需要进行排序，如果涉及类型的大于或小于操	对于需要进行 sort/group 操作时，需要进行排序，如果涉及类型的大于或小于操	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	https://support.huaweicloud.com/errorcode-dws/dws_08_0003.html	\N
2611	54000	GAUSS-02611	out of memory	无法申请内存	请检查系统看是否有足够的内存	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	https://support.huaweicloud.com/errorcode-dws/dws_08_0290.html	\N
2801	54000	GAUSS-02801	string is too long for tsvector (%d bytes, max %d by	字符串超出 tsvector 最大长度	检查输入数据是否过长	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
3305	54000	GAUSS-03305	string is too long for tsvector (%ld bytes, max %	字符串太长，超过允许的最大长度	字符串太长，超过允许的最大长度	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
637	28P01	GAUSS-00637	Password must contain at least three kinds of characters.	密码包含的字符类型少于 3 种	请参照密码规则进行修改：1. 密码默认不少于 8 个字符。2. 不能和用户名相	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
3257	22001	GAUSS-03257	value too long for type character(%d)	值超出字段设定限制	检查传入值是否超过字段限制	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
4045	28000	GAUSS-04045	Invalid username/password,login denied.	用户名或密码无效，登录失败	检查登录的用户名和密码是否有效	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
4905	28000	GAUSS-04905	Forbid remote connection with initial user.	禁止与初始用户进行远程连接。	更换初始化用户连接	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
656	42704	GAUSS-00656	Invalid username/password,login denied.	用户名或密码无效，登录失败	检查登录的用户名和密码是否有效	2021-12-09 01:56:48+08	2021-12-09 01:56:48+08	\N	\N
\.
;

--
-- PostgreSQL database dump complete
--

