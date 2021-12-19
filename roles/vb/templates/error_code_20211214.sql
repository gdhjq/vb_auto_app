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
-- Name: error_code; Type: TABLE; Schema: public; Owner: vastbase; Tablespace: 
--

CREATE TABLE error_code (
    code_id numeric(10,0) NOT NULL,
    e_sqlstate varchar(20),
    e_standard varchar(1),
    errcode_macro_name varchar(200),
    spec_name varchar(100),
    e_type varchar(25),
    e_type_definition varchar(50),
    e_remark text
)
WITH (orientation=row, compression=no);


ALTER TABLE public.error_code OWNER TO vastbase;

--
-- Data for Name: error_code; Type: TABLE DATA; Schema: public; Owner: vastbase
--

COPY error_code (code_id, e_sqlstate, e_standard, errcode_macro_name, spec_name, e_type, e_type_definition, e_remark) FROM stdin;
1	00000	S	ERRCODE_SUCCESSFUL_COMPLETION	successful_completion	Class 00	Successful Completion	\N
2	01000	W	ERRCODE_WARNING	warning	Class 01	Warning	\N
3	0100C	W	ERRCODE_WARNING_DYNAMIC_RESULT_SETS_RETURNED	dynamic_result_sets_returned	Class 01	Warning	\N
4	01008	W	ERRCODE_WARNING_IMPLICIT_ZERO_BIT_PADDING	implicit_zero_bit_padding	Class 01	Warning	\N
5	01003	W	ERRCODE_WARNING_NULL_VALUE_ELIMINATED_IN_SET_FUNCTION	null_value_eliminated_in_set_function	Class 01	Warning	\N
6	01007	W	ERRCODE_WARNING_PRIVILEGE_NOT_GRANTED	privilege_not_granted	Class 01	Warning	\N
7	01006	W	ERRCODE_WARNING_PRIVILEGE_NOT_REVOKED	privilege_not_revoked	Class 01	Warning	\N
8	01004	W	ERRCODE_WARNING_STRING_DATA_RIGHT_TRUNCATION	string_data_right_truncation	Class 01	Warning	\N
9	01P01	W	ERRCODE_WARNING_DEPRECATED_FEATURE	deprecated_feature	Class 01	Warning	\N
10	02000	W	ERRCODE_NO_DATA	no_data	Class 02	No Data	\N
11	02001	W	ERRCODE_NO_ADDITIONAL_DYNAMIC_RESULT_SETS_RETURNED	no_additional_dynamic_result_sets_returne	Class 02	No Data	\N
12	02002	W	ERRCODE_INVALID_OPTION	invalid_option	Class 02	No Data	\N
13	03000	E	ERRCODE_SQL_STATEMENT_NOT_YET_COMPLETE	sql_statement_not_yet_complete	Class 03	SQL Statement Not Yet Complete	\N
14	08000	E	ERRCODE_CONNECTION_EXCEPTION	connection_exception	Class 08	Connection Exception	\N
15	08003	E	ERRCODE_CONNECTION_DOES_NOT_EXIST	connection_does_not_exist	Class 08	Connection Exception	\N
16	08006	E	ERRCODE_CONNECTION_FAILURE	connection_failure	Class 08	Connection Exception	\N
17	08001	E	ERRCODE_SQLCLIENT_UNABLE_TO_ESTABLISH_SQLCONNECTION	sqlclient_unable_to_establish_sqlconnecti	Class 08	Connection Exception	\N
18	08004	E	ERRCODE_SQLSERVER_REJECTED_ESTABLISHMENT_OF_SQLCONNECTION	sqlserver_rejected_establishment_of_sqlco	Class 08	Connection Exception	\N
19	08007	E	ERRCODE_TRANSACTION_RESOLUTION_UNKNOWN	transaction_resolution_unknown	Class 08	Connection Exception	\N
20	08P01	E	ERRCODE_PROTOCOL_VIOLATION	protocol_violation	Class 08	Connection Exception	\N
21	09000	E	ERRCODE_TRIGGERED_ACTION_EXCEPTION	triggered_action_exception	Class 09	Triggered Action Exception	\N
22	0A000	E	ERRCODE_FEATURE_NOT_SUPPORTED	feature_not_supported	Class 0A	Feature Not Supported	\N
23	0A100	E	ERRCODE_STREAM_NOT_SUPPORTED	stream_not_supported	Class 0A	Feature Not Supported	\N
24	0B000	E	ERRCODE_INVALID_TRANSACTION_INITIATION	invalid_transaction_initiation	Class 0B	Invalid Transaction Initiation	\N
25	0F000	E	ERRCODE_LOCATOR_EXCEPTION	locator_exception	Class 0F	Locator Exception	\N
26	0F001	E	ERRCODE_L_E_INVALID_SPECIFICATION	invalid_locator_specification	Class 0F	Locator Exception	\N
27	0L000	E	ERRCODE_INVALID_GRANTOR	invalid_grantor	Class 0L	Invalid Grantor	\N
28	0LP01	E	ERRCODE_INVALID_GRANT_OPERATION	invalid_grant_operation	Class 0L	Invalid Grantor	\N
29	0P000	E	ERRCODE_INVALID_ROLE_SPECIFICATION	invalid_role_specification	Class 0P	Invalid Role Specification	\N
30	0Z000	E	ERRCODE_DIAGNOSTICS_EXCEPTION	diagnostics_exception	Class 0Z	Diagnostics Exception	\N
31	0Z002	E	ERRCODE_STACKED_DIAGNOSTICS_ACCESSED_WITHOUT_ACTIVE_HANDLER	stacked_diagnostics_accessed_without_acti	Class 0Z	Diagnostics Exception	\N
32	20000	E	ERRCODE_CASE_NOT_FOUND	case_not_found	Class 20	Case Not Found	\N
33	21000	E	ERRCODE_CARDINALITY_VIOLATION	cardinality_violation	Class 21	Cardinality Violation	\N
34	22000	E	ERRCODE_DATA_EXCEPTION	data_exception	Class 22	Data Exception	\N
35	2200E	E	ERRCODE_ARRAY_ELEMENT_ERROR	\N	Class 22	Data Exception	\N
36	2202E	E	ERRCODE_ARRAY_SUBSCRIPT_ERROR	array_subscript_error	Class 22	Data Exception	\N
37	22021	E	ERRCODE_CHARACTER_NOT_IN_REPERTOIRE	character_not_in_repertoire	Class 22	Data Exception	\N
38	22008	E	ERRCODE_DATETIME_FIELD_OVERFLOW	datetime_field_overflow	Class 22	Data Exception	\N
39	22020	E	ERRCODE_DATETIME_VALUE_OUT_OF_RANGE	\N	Class 22	Data Exception	\N
40	22012	E	ERRCODE_DIVISION_BY_ZERO	division_by_zero	Class 22	Data Exception	\N
41	22005	E	ERRCODE_ERROR_IN_ASSIGNMENT	error_in_assignment	Class 22	Data Exception	\N
42	2200B	E	ERRCODE_ESCAPE_CHARACTER_CONFLICT	escape_character_conflict	Class 22	Data Exception	\N
43	22022	E	ERRCODE_INDICATOR_OVERFLOW	indicator_overflow	Class 22	Data Exception	\N
44	22015	E	ERRCODE_INTERVAL_FIELD_OVERFLOW	interval_field_overflow	Class 22	Data Exception	\N
45	2201E	E	ERRCODE_INVALID_ARGUMENT_FOR_LOG	invalid_argument_for_logarithm	Class 22	Data Exception	\N
46	22014	E	ERRCODE_INVALID_ARGUMENT_FOR_NTILE	invalid_argument_for_ntile_function	Class 22	Data Exception	\N
47	22016	E	ERRCODE_INVALID_ARGUMENT_FOR_NTH_VALUE	invalid_argument_for_nth_value_function	Class 22	Data Exception	\N
48	2201F	E	ERRCODE_INVALID_ARGUMENT_FOR_POWER_FUNCTION	invalid_argument_for_power_function	Class 22	Data Exception	\N
49	2201G	E	ERRCODE_INVALID_ARGUMENT_FOR_WIDTH_BUCKET_FUNCTION	invalid_argument_for_width_bucket_functio	Class 22	Data Exception	\N
50	22018	E	ERRCODE_INVALID_CHARACTER_VALUE_FOR_CAST	invalid_character_value_for_cast	Class 22	Data Exception	\N
51	22007	E	ERRCODE_INVALID_DATETIME_FORMAT	invalid_datetime_format	Class 22	Data Exception	\N
52	22019	E	ERRCODE_INVALID_ESCAPE_CHARACTER	invalid_escape_character	Class 22	Data Exception	\N
53	2200D	E	ERRCODE_INVALID_ESCAPE_OCTET	invalid_escape_octet	Class 22	Data Exception	\N
54	22025	E	ERRCODE_INVALID_ESCAPE_SEQUENCE	invalid_escape_sequence	Class 22	Data Exception	\N
55	22P06	E	ERRCODE_NONSTANDARD_USE_OF_ESCAPE_CHARACTER	nonstandard_use_of_escape_character	Class 22	Data Exception	\N
56	22010	E	ERRCODE_INVALID_INDICATOR_PARAMETER_VALUE	invalid_indicator_parameter_value	Class 22	Data Exception	\N
57	22023	E	ERRCODE_INVALID_PARAMETER_VALUE	invalid_parameter_value	Class 22	Data Exception	\N
58	2201B	E	ERRCODE_INVALID_REGULAR_EXPRESSION	invalid_regular_expression	Class 22	Data Exception	\N
59	2201W	E	ERRCODE_INVALID_ROW_COUNT_IN_LIMIT_CLAUSE	invalid_row_count_in_limit_clause	Class 22	Data Exception	\N
60	2201X	E	ERRCODE_INVALID_ROW_COUNT_IN_RESULT_OFFSET_CLAUSE	invalid_row_count_in_result_offset_clause	Class 22	Data Exception	\N
61	22009	E	ERRCODE_INVALID_TIME_ZONE_DISPLACEMENT_VALUE	invalid_time_zone_displacement_value	Class 22	Data Exception	\N
62	2200C	E	ERRCODE_INVALID_USE_OF_ESCAPE_CHARACTER	invalid_use_of_escape_character	Class 22	Data Exception	\N
63	2200G	E	ERRCODE_MOST_SPECIFIC_TYPE_MISMATCH	most_specific_type_mismatch	Class 22	Data Exception	\N
64	22004	E	ERRCODE_NULL_VALUE_NOT_ALLOWED	null_value_not_allowed	Class 22	Data Exception	\N
65	22002	E	ERRCODE_NULL_VALUE_NO_INDICATOR_PARAMETER	null_value_no_indicator_parameter	Class 22	Data Exception	\N
66	22003	E	ERRCODE_NUMERIC_VALUE_OUT_OF_RANGE	numeric_value_out_of_range	Class 22	Data Exception	\N
67	22017	E	ERRCODE_DOP_VALUE_OUT_OF_RANGE	dop_value_out_of_range	Class 22	Data Exception	\N
68	22026	E	ERRCODE_STRING_DATA_LENGTH_MISMATCH	string_data_length_mismatch	Class 22	Data Exception	\N
69	22028	E	ERRCODE_REGEXP_MISMATCH	\N	Class 22	Data Exception	\N
70	22001	E	ERRCODE_STRING_DATA_RIGHT_TRUNCATION	string_data_right_truncation	Class 22	Data Exception	\N
71	22011	E	ERRCODE_SUBSTRING_ERROR	substring_error	Class 22	Data Exception	\N
72	22027	E	ERRCODE_TRIM_ERROR	trim_error	Class 22	Data Exception	\N
73	22024	E	ERRCODE_UNTERMINATED_C_STRING	unterminated_c_string	Class 22	Data Exception	\N
74	2200F	E	ERRCODE_ZERO_LENGTH_CHARACTER_STRING	zero_length_character_string	Class 22	Data Exception	\N
75	22P01	E	ERRCODE_FLOATING_POINT_EXCEPTION	floating_point_exception	Class 22	Data Exception	\N
76	22P02	E	ERRCODE_INVALID_TEXT_REPRESENTATION	invalid_text_representation	Class 22	Data Exception	\N
77	22P03	E	ERRCODE_INVALID_BINARY_REPRESENTATION	invalid_binary_representation	Class 22	Data Exception	\N
78	22P04	E	ERRCODE_BAD_COPY_FILE_FORMAT	bad_copy_file_format	Class 22	Data Exception	\N
79	22P05	E	ERRCODE_UNTRANSLATABLE_CHARACTER	untranslatable_character	Class 22	Data Exception	\N
80	2200L	E	ERRCODE_NOT_AN_XML_DOCUMENT	not_an_xml_document	Class 22	Data Exception	\N
81	2200M	E	ERRCODE_INVALID_XML_DOCUMENT	invalid_xml_document	Class 22	Data Exception	\N
82	2200N	E	ERRCODE_INVALID_XML_CONTENT	invalid_xml_content	Class 22	Data Exception	\N
83	2200O	E	ERRCODE_INVALID_XML_ERROR_CONTEXT	invalid_xml_error_context	Class 22	Data Exception	\N
84	2200S	E	ERRCODE_INVALID_XML_COMMENT	invalid_xml_comment	Class 22	Data Exception	\N
85	2200T	E	ERRCODE_INVALID_XML_PROCESSING_INSTRUCTION	invalid_xml_processing_instruction	Class 22	Data Exception	\N
86	23000	E	ERRCODE_INTEGRITY_CONSTRAINT_VIOLATION	integrity_constraint_violation	Class 23	Integrity Constraint Violation	\N
87	23001	E	ERRCODE_RESTRICT_VIOLATION	restrict_violation	Class 23	Integrity Constraint Violation	\N
88	23502	E	ERRCODE_NOT_NULL_VIOLATION	not_null_violation	Class 23	Integrity Constraint Violation	\N
89	23503	E	ERRCODE_FOREIGN_KEY_VIOLATION	foreign_key_violation	Class 23	Integrity Constraint Violation	\N
90	23505	E	ERRCODE_UNIQUE_VIOLATION	unique_violation	Class 23	Integrity Constraint Violation	\N
91	23514	E	ERRCODE_CHECK_VIOLATION	check_violation	Class 23	Integrity Constraint Violation	\N
92	23P01	E	ERRCODE_EXCLUSION_VIOLATION	exclusion_violation	Class 23	Integrity Constraint Violation	\N
93	24000	E	ERRCODE_INVALID_CURSOR_STATE	invalid_cursor_state	Class 24	Invalid Cursor State	\N
94	25000	E	ERRCODE_INVALID_TRANSACTION_STATE	invalid_transaction_state	Class 25	Invalid Transaction State	\N
95	25001	E	ERRCODE_ACTIVE_SQL_TRANSACTION	active_sql_transaction	Class 25	Invalid Transaction State	\N
96	25002	E	ERRCODE_BRANCH_TRANSACTION_ALREADY_ACTIVE	branch_transaction_already_active	Class 25	Invalid Transaction State	\N
97	25008	E	ERRCODE_HELD_CURSOR_REQUIRES_SAME_ISOLATION_LEVEL	held_cursor_requires_same_isolation_level	Class 25	Invalid Transaction State	\N
98	25003	E	ERRCODE_INAPPROPRIATE_ACCESS_MODE_FOR_BRANCH_TRANSACTION	inappropriate_access_mode_for_branch_tran	Class 25	Invalid Transaction State	\N
99	25004	E	ERRCODE_INAPPROPRIATE_ISOLATION_LEVEL_FOR_BRANCH_TRANSACTION	inappropriate_isolation_level_for_branch_	Class 25	Invalid Transaction State	\N
100	25005	E	ERRCODE_NO_ACTIVE_SQL_TRANSACTION_FOR_BRANCH_TRANSACTION	no_active_sql_transaction_for_branch_tran	Class 25	Invalid Transaction State	\N
101	25006	E	ERRCODE_READ_ONLY_SQL_TRANSACTION	read_only_sql_transaction	Class 25	Invalid Transaction State	\N
102	25007	E	ERRCODE_SCHEMA_AND_DATA_STATEMENT_MIXING_NOT_SUPPORTED	schema_and_data_statement_mixing_not_supp	Class 25	Invalid Transaction State	\N
103	25009	E	ERRCODE_RUN_TRANSACTION_DURING_RECOVERY	run_transaction_during_recovery	Class 25	Invalid Transaction State	\N
104	25010	E	ERRCODE_GXID_DOES_NOT_EXIST	gxid_does_not_exist	Class 25	Invalid Transaction State	\N
105	25P01	E	ERRCODE_NO_ACTIVE_SQL_TRANSACTION	no_active_sql_transaction	Class 25	Invalid Transaction State	\N
106	25P02	E	ERRCODE_IN_FAILED_SQL_TRANSACTION	in_failed_sql_transaction	Class 25	Invalid Transaction State	\N
107	26000	E	ERRCODE_INVALID_SQL_STATEMENT_NAME	invalid_sql_statement_name	Class 26	Invalid SQL Statement Name	\N
108	26001	E	ERRCODE_SLOW_QUERY	SLOW_QUERY_statement_name	Class 26	Invalid SQL Statement Name	\N
109	26002	E	ERRCODE_ACTIVE_SESSION_PROFILE	active_session_profile	Class 26	Invalid SQL Statement Name	\N
110	27000	E	ERRCODE_TRIGGERED_DATA_CHANGE_VIOLATION	triggered_data_change_violation	Class 27	Triggered Data Change Violation	\N
111	27001	E	ERRCODE_TRIGGERED_INVALID_TUPLE	\N	Class 27	Triggered Data Change Violation	\N
112	28000	E	ERRCODE_INVALID_AUTHORIZATION_SPECIFICATION	invalid_authorization_specification	Class 28	Invalid Authorization Specificat	\N
113	28P01	E	ERRCODE_INVALID_PASSWORD	invalid_password	Class 28	Invalid Authorization Specificat	\N
114	28P02	E	ERRCODE_INITIAL_PASSWORD_NOT_MODIFIED	initial_password_not_modified	Class 28	Invalid Authorization Specificat	\N
115	29000	E	ERRCODE_INVALID_STATUS	invalid_status	Class 29	Invalid or Unexpected Status	\N
116	29001	E	ERRCODE_INVALID_TABLESAMPLE_ARGUMENT	invalid_tablesample_argument	Class 29	Invalid or Unexpected Status	\N
117	29002	E	ERRCODE_INVALID_TABLESAMPLE_REPEAT	invalid_tablesample_repeat	Class 29	Invalid or Unexpected Status	\N
118	29003	E	ERRORCODE_ASSERT_FAILED	assert_failed	Class 29	Invalid or Unexpected Status	\N
119	29P01	E	ERRCODE_CACHE_LOOKUP_FAILED	cache_lookup_failed	Class 29	Invalid or Unexpected Status	\N
120	29P02	E	ERRCODE_FETCH_DATA_FAILED	fetch_data_failed	Class 29	Invalid or Unexpected Status	\N
121	29P03	E	ERRCODE_FLUSH_DATA_SIZE_MISMATCH	flush_data_size_mismatch	Class 29	Invalid or Unexpected Status	\N
122	29P04	E	ERRCODE_RELATION_OPEN_ERROR	relation_open_error	Class 29	Invalid or Unexpected Status	\N
123	29P05	E	ERRCODE_RELATION_CLOSE_ERROR	relation_close_error	Class 29	Invalid or Unexpected Status	\N
124	29P06	E	ERRCODE_INVALID_CACHE_PLAN	invalid_cache_plan	Class 29	Invalid or Unexpected Status	\N
125	2B000	E	ERRCODE_DEPENDENT_PRIVILEGE_DESCRIPTORS_STILL_EXIST	dependent_privilege_descriptors_still_exi	Class 2B	Dependent Privilege Descriptors 	\N
126	2BP01	E	ERRCODE_DEPENDENT_OBJECTS_STILL_EXIST	dependent_objects_still_exist	Class 2B	Dependent Privilege Descriptors 	\N
127	2D000	E	ERRCODE_INVALID_TRANSACTION_TERMINATION	invalid_transaction_termination	Class 2D	Invalid Transaction Termination	\N
128	2F000	E	ERRCODE_SQL_ROUTINE_EXCEPTION	sql_routine_exception	Class 2F	SQL Routine Exception	\N
129	2F005	E	ERRCODE_S_R_E_FUNCTION_EXECUTED_NO_RETURN_STATEMENT	function_executed_no_return_statement	Class 2F	SQL Routine Exception	\N
130	2F002	E	ERRCODE_S_R_E_MODIFYING_SQL_DATA_NOT_PERMITTED	modifying_sql_data_not_permitted	Class 2F	SQL Routine Exception	\N
131	2F003	E	ERRCODE_S_R_E_PROHIBITED_SQL_STATEMENT_ATTEMPTED	prohibited_sql_statement_attempted	Class 2F	SQL Routine Exception	\N
132	2F004	E	ERRCODE_S_R_E_READING_SQL_DATA_NOT_PERMITTED	reading_sql_data_not_permitted	Class 2F	SQL Routine Exception	\N
133	34000	E	ERRCODE_INVALID_CURSOR_NAME	invalid_cursor_name	Class 34	Invalid Cursor Name	\N
134	38000	E	ERRCODE_EXTERNAL_ROUTINE_EXCEPTION	external_routine_exception	Class 38	External Routine Exception	\N
135	38001	E	ERRCODE_E_R_E_CONTAINING_SQL_NOT_PERMITTED	containing_sql_not_permitted	Class 38	External Routine Exception	\N
136	38002	E	ERRCODE_E_R_E_MODIFYING_SQL_DATA_NOT_PERMITTED	modifying_sql_data_not_permitted	Class 38	External Routine Exception	\N
137	38003	E	ERRCODE_E_R_E_PROHIBITED_SQL_STATEMENT_ATTEMPTED	prohibited_sql_statement_attempted	Class 38	External Routine Exception	\N
138	38004	E	ERRCODE_E_R_E_READING_SQL_DATA_NOT_PERMITTED	reading_sql_data_not_permitted	Class 38	External Routine Exception	\N
139	39000	E	ERRCODE_EXTERNAL_ROUTINE_INVOCATION_EXCEPTION	external_routine_invocation_exception	Class 39	External Routine Invocation Exce	\N
140	39001	E	ERRCODE_E_R_I_E_INVALID_SQLSTATE_RETURNED	invalid_sqlstate_returned	Class 39	External Routine Invocation Exce	\N
141	39004	E	ERRCODE_E_R_I_E_NULL_VALUE_NOT_ALLOWED	null_value_not_allowed	Class 39	External Routine Invocation Exce	\N
142	39P01	E	ERRCODE_E_R_I_E_TRIGGER_PROTOCOL_VIOLATED	trigger_protocol_violated	Class 39	External Routine Invocation Exce	\N
143	39P02	E	ERRCODE_E_R_I_E_SRF_PROTOCOL_VIOLATED	srf_protocol_violated	Class 39	External Routine Invocation Exce	\N
144	3B000	E	ERRCODE_SAVEPOINT_EXCEPTION	savepoint_exception	Class 3B	Savepoint Exception	\N
145	3B001	E	ERRCODE_S_E_INVALID_SPECIFICATION	invalid_savepoint_specification	Class 3B	Savepoint Exception	\N
146	3D000	E	ERRCODE_INVALID_CATALOG_NAME	invalid_catalog_name	Class 3D	Invalid Catalog Name	\N
147	3F000	E	ERRCODE_INVALID_SCHEMA_NAME	invalid_schema_name	Class 3F	Invalid Schema Name	\N
148	40000	E	ERRCODE_TRANSACTION_ROLLBACK	transaction_rollback	Class 40	Transaction Rollback	\N
149	40002	E	ERRCODE_T_R_INTEGRITY_CONSTRAINT_VIOLATION	transaction_integrity_constraint_violatio	Class 40	Transaction Rollback	\N
150	40001	E	ERRCODE_T_R_SERIALIZATION_FAILURE	serialization_failure	Class 40	Transaction Rollback	\N
151	40003	E	ERRCODE_T_R_STATEMENT_COMPLETION_UNKNOWN	statement_completion_unknown	Class 40	Transaction Rollback	\N
152	40P01	E	ERRCODE_T_R_DEADLOCK_DETECTED	deadlock_detected	Class 40	Transaction Rollback	\N
153	42000	E	ERRCODE_SYNTAX_ERROR_OR_ACCESS_RULE_VIOLATION	syntax_error_or_access_rule_violation	Class 42	Syntax Error or Access Rule Viol	\N
154	42601	E	ERRCODE_SYNTAX_ERROR	syntax_error	Class 42	Syntax Error or Access Rule Viol	\N
155	42501	E	ERRCODE_INSUFFICIENT_PRIVILEGE	insufficient_privilege	Class 42	Syntax Error or Access Rule Viol	\N
156	42846	E	ERRCODE_CANNOT_COERCE	cannot_coerce	Class 42	Syntax Error or Access Rule Viol	\N
157	42803	E	ERRCODE_GROUPING_ERROR	grouping_error	Class 42	Syntax Error or Access Rule Viol	\N
158	42P20	E	ERRCODE_WINDOWING_ERROR	windowing_error	Class 42	Syntax Error or Access Rule Viol	\N
159	42P19	E	ERRCODE_INVALID_RECURSION	invalid_recursion	Class 42	Syntax Error or Access Rule Viol	\N
160	42830	E	ERRCODE_INVALID_FOREIGN_KEY	invalid_foreign_key	Class 42	Syntax Error or Access Rule Viol	\N
161	42602	E	ERRCODE_INVALID_NAME	invalid_name	Class 42	Syntax Error or Access Rule Viol	\N
162	42622	E	ERRCODE_NAME_TOO_LONG	name_too_long	Class 42	Syntax Error or Access Rule Viol	\N
163	42939	E	ERRCODE_RESERVED_NAME	reserved_name	Class 42	Syntax Error or Access Rule Viol	\N
164	42804	E	ERRCODE_DATATYPE_MISMATCH	datatype_mismatch	Class 42	Syntax Error or Access Rule Viol	\N
165	42P38	E	ERRCODE_INDETERMINATE_DATATYPE	indeterminate_datatype	Class 42	Syntax Error or Access Rule Viol	\N
166	42P21	E	ERRCODE_COLLATION_MISMATCH	collation_mismatch	Class 42	Syntax Error or Access Rule Viol	\N
167	42P22	E	ERRCODE_INDETERMINATE_COLLATION	indeterminate_collation	Class 42	Syntax Error or Access Rule Viol	\N
168	42809	E	ERRCODE_WRONG_OBJECT_TYPE	wrong_object_type	Class 42	Syntax Error or Access Rule Viol	\N
169	42P23	E	ERRCODE_PARTITION_ERROR	partition_error	Class 42	Syntax Error or Access Rule Viol	\N
170	42P24	E	ERRCODE_INVALID_ATTRIBUTE	invalid_attribute	Class 42	Syntax Error or Access Rule Viol	\N
171	42P25	E	ERRCODE_INVALID_AGG	invalid_agg	Class 42	Syntax Error or Access Rule Viol	\N
172	42P26	E	ERRCODE_RESOURCE_POOL_ERROR	resource_pool_error	Class 42	Syntax Error or Access Rule Viol	\N
173	42P27	E	ERRCODE_PLAN_PARENT_NOT_FOUND	plan_parent_not_found	Class 42	Syntax Error or Access Rule Viol	\N
174	42P28	E	ERRCODE_MODIFY_CONFLICTS	modify_conflicts	Class 42	Syntax Error or Access Rule Viol	\N
175	42P29	E	ERRCODE_DISTRIBUTION_ERROR	distribution_error	Class 42	Syntax Error or Access Rule Viol	\N
176	42703	E	ERRCODE_UNDEFINED_COLUMN	undefined_column	Class 42	Syntax Error or Access Rule Viol	\N
177	34001	E	ERRCODE_UNDEFINED_CURSOR	undefined_cursor	Class 42	Syntax Error or Access Rule Viol	\N
178	3D000	E	ERRCODE_UNDEFINED_DATABASE	\N	Class 42	Syntax Error or Access Rule Viol	\N
179	42883	E	ERRCODE_UNDEFINED_FUNCTION	undefined_function	Class 42	Syntax Error or Access Rule Viol	\N
180	26010	E	ERRCODE_UNDEFINED_PSTATEMENT	undefined_pstatement	Class 42	Syntax Error or Access Rule Viol	\N
181	3F001	E	ERRCODE_UNDEFINED_SCHEMA	undefined_schema	Class 42	Syntax Error or Access Rule Viol	\N
182	42P01	E	ERRCODE_UNDEFINED_TABLE	undefined_table	Class 42	Syntax Error or Access Rule Viol	\N
183	42P02	E	ERRCODE_UNDEFINED_PARAMETER	undefined_parameter	Class 42	Syntax Error or Access Rule Viol	\N
184	42704	E	ERRCODE_UNDEFINED_OBJECT	undefined_object	Class 42	Syntax Error or Access Rule Viol	\N
185	42701	E	ERRCODE_DUPLICATE_COLUMN	duplicate_column	Class 42	Syntax Error or Access Rule Viol	\N
186	42P03	E	ERRCODE_DUPLICATE_CURSOR	duplicate_cursor	Class 42	Syntax Error or Access Rule Viol	\N
187	42P04	E	ERRCODE_DUPLICATE_DATABASE	duplicate_database	Class 42	Syntax Error or Access Rule Viol	\N
188	42723	E	ERRCODE_DUPLICATE_FUNCTION	duplicate_function	Class 42	Syntax Error or Access Rule Viol	\N
189	42P05	E	ERRCODE_DUPLICATE_PSTATEMENT	duplicate_prepared_statement	Class 42	Syntax Error or Access Rule Viol	\N
190	42P06	E	ERRCODE_DUPLICATE_SCHEMA	duplicate_schema	Class 42	Syntax Error or Access Rule Viol	\N
191	42P07	E	ERRCODE_DUPLICATE_TABLE	duplicate_table	Class 42	Syntax Error or Access Rule Viol	\N
192	42712	E	ERRCODE_DUPLICATE_ALIAS	duplicate_alias	Class 42	Syntax Error or Access Rule Viol	\N
193	42710	E	ERRCODE_DUPLICATE_OBJECT	duplicate_object	Class 42	Syntax Error or Access Rule Viol	\N
194	42702	E	ERRCODE_AMBIGUOUS_COLUMN	ambiguous_column	Class 42	Syntax Error or Access Rule Viol	\N
195	42725	E	ERRCODE_AMBIGUOUS_FUNCTION	ambiguous_function	Class 42	Syntax Error or Access Rule Viol	\N
196	42P08	E	ERRCODE_AMBIGUOUS_PARAMETER	ambiguous_parameter	Class 42	Syntax Error or Access Rule Viol	\N
197	42P09	E	ERRCODE_AMBIGUOUS_ALIAS	ambiguous_alias	Class 42	Syntax Error or Access Rule Viol	\N
198	42P10	E	ERRCODE_INVALID_COLUMN_REFERENCE	invalid_column_reference	Class 42	Syntax Error or Access Rule Viol	\N
199	42611	E	ERRCODE_INVALID_COLUMN_DEFINITION	invalid_column_definition	Class 42	Syntax Error or Access Rule Viol	\N
200	42P11	E	ERRCODE_INVALID_CURSOR_DEFINITION	invalid_cursor_definition	Class 42	Syntax Error or Access Rule Viol	\N
201	42P12	E	ERRCODE_INVALID_DATABASE_DEFINITION	invalid_database_definition	Class 42	Syntax Error or Access Rule Viol	\N
202	42P13	E	ERRCODE_INVALID_FUNCTION_DEFINITION	invalid_function_definition	Class 42	Syntax Error or Access Rule Viol	\N
203	42P14	E	ERRCODE_INVALID_PSTATEMENT_DEFINITION	invalid_prepared_statement_definition	Class 42	Syntax Error or Access Rule Viol	\N
204	42P15	E	ERRCODE_INVALID_SCHEMA_DEFINITION	invalid_schema_definition	Class 42	Syntax Error or Access Rule Viol	\N
205	42P16	E	ERRCODE_INVALID_TABLE_DEFINITION	invalid_table_definition	Class 42	Syntax Error or Access Rule Viol	\N
206	42P17	E	ERRCODE_INVALID_OBJECT_DEFINITION	invalid_object_definition	Class 42	Syntax Error or Access Rule Viol	\N
207	42P18	E	ERRCODE_INVALID_TEMP_OBJECTS	invalidtempobjects(table	 namespace)   	Class 42	Syntax Error or Access Rule Vi
208	42705	E	ERRCODE_UNDEFINED_KEY	undefined_key	Class 42	Syntax Error or Access Rule Viol	\N
209	42711	E	ERRCODE_DUPLICATE_KEY	duplicate_key	Class 42	Syntax Error or Access Rule Viol	\N
210	42713	E	ERRCODE_UNDEFINED_CL_COLUMN	undefined_cl_column	Class 42	Syntax Error or Access Rule Viol	\N
211	44000	E	ERRCODE_WITH_CHECK_OPTION_VIOLATION	with_check_option_violation	Class 44	WITH CHECK OPTION Violation	\N
212	53000	E	ERRCODE_INSUFFICIENT_RESOURCES	insufficient_resources	Class 53	Insufficient Resources	\N
213	53100	E	ERRCODE_DISK_FULL	disk_full	Class 53	Insufficient Resources	\N
214	53200	E	ERRCODE_OUT_OF_MEMORY	out_of_memory	Class 53	Insufficient Resources	\N
215	53300	E	ERRCODE_TOO_MANY_CONNECTIONS	too_many_connections	Class 53	Insufficient Resources	\N
216	53400	E	ERRCODE_CONFIGURATION_LIMIT_EXCEEDED	configuration_limit_exceeded	Class 53	Insufficient Resources	\N
217	53500	E	ERRCODE_OUT_OF_BUFFER	out_of_buffer	Class 53	Insufficient Resources	\N
218	54000	E	ERRCODE_PROGRAM_LIMIT_EXCEEDED	program_limit_exceeded	Class 54	Program Limit Exceeded	\N
219	54001	E	ERRCODE_STATEMENT_TOO_COMPLEX	statement_too_complex	Class 54	Program Limit Exceeded	\N
220	54011	E	ERRCODE_TOO_MANY_COLUMNS	too_many_columns	Class 54	Program Limit Exceeded	\N
221	54023	E	ERRCODE_TOO_MANY_ARGUMENTS	too_many_arguments	Class 54	Program Limit Exceeded	\N
222	55000	E	ERRCODE_OBJECT_NOT_IN_PREREQUISITE_STATE	object_not_in_prerequisite_state	Class 55	Object Not In Prerequisite State	\N
223	55006	E	ERRCODE_OBJECT_IN_USE	object_in_use	Class 55	Object Not In Prerequisite State	\N
224	55P02	E	ERRCODE_CANT_CHANGE_RUNTIME_PARAM	cant_change_runtime_param	Class 55	Object Not In Prerequisite State	\N
225	55P03	E	ERRCODE_LOCK_NOT_AVAILABLE	lock_not_available	Class 55	Object Not In Prerequisite State	\N
226	57000	E	ERRCODE_OPERATOR_INTERVENTION	operator_intervention	Class 57	Operator Intervention	\N
227	57014	E	ERRCODE_QUERY_CANCELED	query_canceled	Class 57	Operator Intervention	\N
228	57015	E	ERRCODE_QUERY_INTERNAL_CANCEL	query_internal_cancel	Class 57	Operator Intervention	\N
229	57P01	E	ERRCODE_ADMIN_SHUTDOWN	admin_shutdown	Class 57	Operator Intervention	\N
230	57P02	E	ERRCODE_CRASH_SHUTDOWN	crash_shutdown	Class 57	Operator Intervention	\N
231	57P03	E	ERRCODE_CANNOT_CONNECT_NOW	cannot_connect_now	Class 57	Operator Intervention	\N
232	57P04	E	ERRCODE_DATABASE_DROPPED	database_dropped	Class 57	Operator Intervention	\N
233	57P05	E	ERRCODE_RU_STOP_QUERY	ru_stop_query	Class 57	Operator Intervention	\N
234	58000	E	ERRCODE_SYSTEM_ERROR	system_error	Class 58	System Error	\N
235	58030	E	ERRCODE_IO_ERROR	io_error	Class 58	System Error	\N
236	58P01	E	ERRCODE_UNDEFINED_FILE	undefined_file	Class 58	System Error	\N
237	58P02	E	ERRCODE_DUPLICATE_FILE	duplicate_file	Class 58	System Error	\N
238	58P03	E	ERRCODE_FILE_READ_FAILED	file_read_failed	Class 58	System Error	\N
239	58P04	E	ERRCODE_FILE_WRITE_FAILED	file_write_failed	Class 58	System Error	\N
240	2200Z	E	ERRCODE_INVALID_ENCRYPTED_COLUMN_DATA	encryped_column_wrong_data	Class 58	System Error	\N
241	F0000	E	ERRCODE_CONFIG_FILE_ERROR	config_file_error	Class F0	Configuration File Error	\N
242	F0001	E	ERRCODE_LOCK_FILE_EXISTS	lock_file_exists	Class F0	Configuration File Error	\N
243	HV000	E	ERRCODE_FDW_ERROR	fdw_error	Class HV	Foreign Data Wrapper Error (SQL/	\N
244	HV005	E	ERRCODE_FDW_COLUMN_NAME_NOT_FOUND	fdw_column_name_not_found	Class HV	Foreign Data Wrapper Error (SQL/	\N
245	HV002	E	ERRCODE_FDW_DYNAMIC_PARAMETER_VALUE_NEEDED	fdw_dynamic_parameter_value_needed	Class HV	Foreign Data Wrapper Error (SQL/	\N
246	HV010	E	ERRCODE_FDW_FUNCTION_SEQUENCE_ERROR	fdw_function_sequence_error	Class HV	Foreign Data Wrapper Error (SQL/	\N
247	HV021	E	ERRCODE_FDW_INCONSISTENT_DESCRIPTOR_INFORMATION	fdw_inconsistent_descriptor_information	Class HV	Foreign Data Wrapper Error (SQL/	\N
248	HV024	E	ERRCODE_FDW_INVALID_ATTRIBUTE_VALUE	fdw_invalid_attribute_value	Class HV	Foreign Data Wrapper Error (SQL/	\N
249	HV007	E	ERRCODE_FDW_INVALID_COLUMN_NAME	fdw_invalid_column_name	Class HV	Foreign Data Wrapper Error (SQL/	\N
250	HV008	E	ERRCODE_FDW_INVALID_COLUMN_NUMBER	fdw_invalid_column_number	Class HV	Foreign Data Wrapper Error (SQL/	\N
251	HV004	E	ERRCODE_FDW_INVALID_DATA_TYPE	fdw_invalid_data_type	Class HV	Foreign Data Wrapper Error (SQL/	\N
252	HV006	E	ERRCODE_FDW_INVALID_DATA_TYPE_DESCRIPTORS	fdw_invalid_data_type_descriptors	Class HV	Foreign Data Wrapper Error (SQL/	\N
253	HV091	E	ERRCODE_FDW_INVALID_DESCRIPTOR_FIELD_IDENTIFIER	fdw_invalid_descriptor_field_identifier	Class HV	Foreign Data Wrapper Error (SQL/	\N
254	HV00B	E	ERRCODE_FDW_INVALID_HANDLE	fdw_invalid_handle	Class HV	Foreign Data Wrapper Error (SQL/	\N
255	HV00C	E	ERRCODE_FDW_INVALID_OPTION_INDEX	fdw_invalid_option_index	Class HV	Foreign Data Wrapper Error (SQL/	\N
256	HV00D	E	ERRCODE_FDW_INVALID_OPTION_NAME	fdw_invalid_option_name	Class HV	Foreign Data Wrapper Error (SQL/	\N
257	HV00E	E	ERRCODE_FDW_INVALID_OPTOIN_DATA	fdw_invalid_option_data	Class HV	Foreign Data Wrapper Error (SQL/	\N
258	HV090	E	ERRCODE_FDW_INVALID_STRING_LENGTH_OR_BUFFER_LENGTH	fdw_invalid_string_length_or_buffer_lengt	Class HV	Foreign Data Wrapper Error (SQL/	\N
259	HV00A	E	ERRCODE_FDW_INVALID_STRING_FORMAT	fdw_invalid_string_format	Class HV	Foreign Data Wrapper Error (SQL/	\N
260	HV009	E	ERRCODE_FDW_INVALID_USE_OF_NULL_POINTER	fdw_invalid_use_of_null_pointer	Class HV	Foreign Data Wrapper Error (SQL/	\N
261	HV014	E	ERRCODE_FDW_TOO_MANY_HANDLES	fdw_too_many_handles	Class HV	Foreign Data Wrapper Error (SQL/	\N
262	HV001	E	ERRCODE_FDW_OUT_OF_MEMORY	fdw_out_of_memory	Class HV	Foreign Data Wrapper Error (SQL/	\N
263	HV00P	E	ERRCODE_FDW_NO_SCHEMAS	fdw_no_schemas	Class HV	Foreign Data Wrapper Error (SQL/	\N
264	HV00J	E	ERRCODE_FDW_OPTION_NAME_NOT_FOUND	fdw_option_name_not_found	Class HV	Foreign Data Wrapper Error (SQL/	\N
265	HV00K	E	ERRCODE_FDW_REPLY_HANDLE	fdw_reply_handle	Class HV	Foreign Data Wrapper Error (SQL/	\N
266	HV00Q	E	ERRCODE_FDW_SCHEMA_NOT_FOUND	fdw_schema_not_found	Class HV	Foreign Data Wrapper Error (SQL/	\N
267	HV00R	E	ERRCODE_FDW_TABLE_NOT_FOUND	fdw_table_not_found	Class HV	Foreign Data Wrapper Error (SQL/	\N
268	HV00L	E	ERRCODE_FDW_UNABLE_TO_CREATE_EXECUTION	fdw_unable_to_create_execution	Class HV	Foreign Data Wrapper Error (SQL/	\N
269	HV00M	E	ERRCODE_FDW_UNABLE_TO_CREATE_REPLY	fdw_unable_to_create_reply	Class HV	Foreign Data Wrapper Error (SQL/	\N
270	HV00N	E	ERRCODE_FDW_UNABLE_TO_ESTABLISH_CONNECTION	fdw_unable_to_establish_connection	Class HV	Foreign Data Wrapper Error (SQL/	\N
271	HV00O	E	ERRCODE_FDW_INVALID_LIST_LENGTH	fdw_invalid_list_length	Class HV	Foreign Data Wrapper Error (SQL/	\N
272	HV00S	E	ERRCODE_FDW_INVALID_SERVER_TYPE	fdw_invalid_server_type	Class HV	Foreign Data Wrapper Error (SQL/	\N
273	HV025	E	ERRCODE_FDW_OPERATION_NOT_SUPPORTED	fdw_operation_not_supported	Class HV	Foreign Data Wrapper Error (SQL/	\N
274	HV026	E	ERRCODE_FDW_CROSS_STORAGE_ENGINE_TRANSACTION_NOT_SUPPORTED	fdw_cross_storage_engine_transaction_not_	Class HV	Foreign Data Wrapper Error (SQL/	\N
275	HV027	E	ERRCODE_FDW_CROSS_STORAGE_ENGINE_QUERY_NOT_SUPPORTED	fdw_cross_storage_engine_query_not_suppor	Class HV	Foreign Data Wrapper Error (SQL/	\N
276	HV028	E	ERRCODE_FDW_UPDATE_INDEXED_FIELD_NOT_SUPPORTED	fdw_cross_update_indexed_field_not_suppor	Class HV	Foreign Data Wrapper Error (SQL/	\N
277	HV029	E	ERRCODE_FDW_TOO_MANY_INDEXES	fdw_too_many_indexes	Class HV	Foreign Data Wrapper Error (SQL/	\N
278	HV030	E	ERRCODE_FDW_KEY_SIZE_EXCEEDS_MAX_ALLOWED	fdw_key_size_exceeds_max_allowed	Class HV	Foreign Data Wrapper Error (SQL/	\N
279	HV031	E	ERRCODE_FDW_DDL_IN_TRANSACTION_NOT_ALLOWED	fdw_ddl_in_transaction_not_allowed	Class HV	Foreign Data Wrapper Error (SQL/	\N
280	HV032	E	ERRCODE_FDW_TOO_MANY_INDEX_COLUMNS	fdw_too_many_index_columns	Class HV	Foreign Data Wrapper Error (SQL/	\N
281	HV033	E	ERRCODE_FDW_INDEX_ON_NULLABLE_COLUMN_NOT_ALLOWED	fdw_index_on_nullable_column_not_allowed	Class HV	Foreign Data Wrapper Error (SQL/	\N
282	HV034	E	ERRCODE_FDW_TOO_MANY_DDL_CHANGES_IN_TRANSACTION_NOT_ALLOWED	fdw_too_many_ddl_statements_in_transactio	Class HV	Foreign Data Wrapper Error (SQL/	\N
283	P0000	E	ERRCODE_PLPGSQL_ERROR	plpgsql_error	Class P0	PL/pgSQL Error	\N
284	P0001	E	ERRCODE_RAISE_EXCEPTION	raise_exception	Class P0	PL/pgSQL Error	\N
285	P0002	E	ERRCODE_NO_DATA_FOUND	no_data_found	Class P0	PL/pgSQL Error	\N
286	P0003	E	ERRCODE_TOO_MANY_ROWS	too_many_rows	Class P0	PL/pgSQL Error	\N
287	P0004	E	ERRCODE_FORALL_NEED_DML	forall_need_dml	Class P0	PL/pgSQL Error	\N
288	XX000	E	ERRCODE_INTERNAL_ERROR	internal_error	Class XX	Internal Error	\N
289	XX001	E	ERRCODE_DATA_CORRUPTED	data_corrupted	Class XX	Internal Error	\N
290	XX002	E	ERRCODE_INDEX_CORRUPTED	index_corrupted	Class XX	Internal Error	\N
291	XX003	E	ERRCODE_STREAM_REMOTE_CLOSE_SOCKET	stream_remote_close_socket	Class XX	Internal Error	\N
292	XX004	E	ERRCODE_UNRECOGNIZED_NODE_TYPE	unrecognized_node_type	Class XX	Internal Error	\N
293	XX005	E	ERRCODE_UNEXPECTED_NULL_VALUE	unexpected_null_value	Class XX	Internal Error	\N
294	XX006	E	ERRCODE_UNEXPECTED_NODE_STATE	unexpected_node_state	Class XX	Internal Error	\N
295	XX007	E	ERRCODE_NULL_JUNK_ATTRIBUTE	null_junk_attribute	Class XX	Internal Error	\N
296	XX008	E	ERRCODE_OPTIMIZER_INCONSISTENT_STATE	optimizer_inconsistent_state	Class XX	Internal Error	\N
297	XX009	E	ERRCODE_STREAM_DUPLICATE_QUERY_ID	stream_duplicate_query_id	Class XX	Internal Error	\N
298	XX010	E	ERRCODE_INVALID_BUFFER	invalid_buffer	Class XX	Internal Error	\N
299	XX011	E	ERRCODE_INVALID_BUFFER_REFERENCE	invalid_buffer_reference	Class XX	Internal Error	\N
300	XX012	E	ERRCODE_NODE_ID_MISSMATCH	\N	Class XX	Internal Error	\N
301	XX013	E	ERRCODE_CANNOT_MODIFY_XIDBASE	\N	Class XX	Internal Error	                
302	XX014	E	ERRCODE_UNEXPECTED_CHUNK_VALUE	unexpected_chunk_value	Class XX	Internal Error	\N
303	XX015	E	ERRCODE_CN_RETRY_STUB	cn_retry_stub	Class XX	Internal Error	\N
304	CG000	E	ERRCODE_CODEGEN_ERROR	codegen_error	Class CG	CodeGen Error	\N
305	CG001	E	ERRCODE_LOAD_IR_FUNCTION_FAILED	load_ir_function_failed	Class CG	CodeGen Error	\N
306	CG002	E	ERRCODE_LOAD_INTRINSIC_FUNCTION_FAILED	load_intrinsic_function_failed	Class CG	CodeGen Error	\N
307	YY001	E	ERRCODE_CONNECTION_RESET_BY_PEER	connection_reset_by_peer	Class YY	SQL Retry Error	\N
308	YY002	E	ERRCODE_STREAM_CONNECTION_RESET_BY_PEER	stream_connection_reset_by_peer	Class YY	SQL Retry Error	\N
309	YY003	E	ERRCODE_LOCK_WAIT_TIMEOUT	lock_wait_timeout	Class YY	SQL Retry Error	\N
310	YY004	E	ERRCODE_CONNECTION_TIMED_OUT	connection_timed_out	Class YY	SQL Retry Error	\N
311	YY005	E	ERRCODE_SET_QUERY	set_query_error	Class YY	SQL Retry Error	\N
312	YY006	E	ERRCODE_OUT_OF_LOGICAL_MEMORY	out_of_logical_memory	Class YY	SQL Retry Error	\N
313	YY007	E	ERRCODE_SCTP_MEMORY_ALLOC	sctp_memory_alloc	Class YY	SQL Retry Error	\N
314	YY008	E	ERRCODE_SCTP_NO_DATA_IN_BUFFER	sctp_no_data_in_buffer	Class YY	SQL Retry Error	\N
315	YY009	E	ERRCODE_SCTP_RELEASE_MEMORY_CLOSE	sctp_release_memory_close	Class YY	SQL Retry Error	\N
316	YY010	E	ERRCODE_SCTP_TCP_DISCONNECT	sctp_tcp_disconnect	Class YY	SQL Retry Error	\N
317	YY011	E	ERRCODE_SCTP_DISCONNECT	sctp_disconnect	Class YY	SQL Retry Error	\N
318	YY012	E	ERRCODE_SCTP_REMOTE_CLOSE	sctp_remote_close	Class YY	SQL Retry Error	\N
319	YY013	E	ERRCODE_SCTP_WAIT_POLL_UNKNOW	sctp_wait_poll_unknow	Class YY	SQL Retry Error	\N
320	YY014	E	ERRCODE_SNAPSHOT_INVALID	snapshot_invalid	Class YY	SQL Retry Error	\N
321	YY015	E	ERRCODE_CONNECTION_RECEIVE_WRONG	connection_receive_wrong	Class YY	SQL Retry Error	\N
322	YY016	E	ERRCODE_STREAM_CONCURRENT_UPDATE	stream_concurrent_update	Class YY	SQL Retry Error	\N
323	SP000	E	ERRCODE_SPI_ERROR	spi_error	Class SI	SPI Interface Error	\N
324	SP001	E	ERRCODE_SPI_CONNECTION_FAILURE	spi_connection_failure	Class SI	SPI Interface Error	\N
325	SP002	E	ERRCODE_SPI_FINISH_FAILURE	spi_finish_failure	Class SI	SPI Interface Error	\N
326	SP003	E	ERRCODE_SPI_PREPARE_FAILURE	spi_prepare_failure	Class SI	SPI Interface Error	\N
327	SP004	E	ERRCODE_SPI_CURSOR_OPEN_FAILURE	spi_cursor_open_failure	Class SI	SPI Interface Error	\N
328	SP005	E	ERRCODE_SPI_EXECUTE_FAILURE	spi_execute_failure	Class SI	SPI Interface Error	\N
329	SP006	E	ERRORCODE_SPI_IMPROPER_CALL	spi_improper_call_function	Class SI	SPI Interface Error	\N
330	D0000	E	ERRCODE_PLDEBUGGER_ERROR	pldebugger_internal_error	Class PD	PL Debugger Error	\N
331	D0001	E	ERRCODE_DUPLICATE_BREAKPOINT	duplicate_breakpoint	Class PD	PL Debugger Error	\N
332	D0002	E	ERRCODE_FUNCTION_HASH_NOT_INITED	function_hash_is_not_initialized	Class PD	PL Debugger Error	\N
333	D0003	E	ERRCODE_BREAKPOINT_NOT_PRESENT	breakpoint_is_not_present	Class PD	PL Debugger Error	\N
334	D0004	E	ERRCODE_TARGET_SERVER_ALREADY_ATTACHED	debug_server_already_is_attached	Class PD	PL Debugger Error	\N
335	D0005	E	ERRCODE_TARGET_SERVER_NOT_ATTACHED	debug_server_not_attached	Class PD	PL Debugger Error	\N
336	D0006	E	ERRCODE_DEBUG_SERVER_ALREADY_SYNC	debug_server_already_in_sync	Class PD	PL Debugger Error	\N
337	D0007	E	ERRCODE_DEBUG_TARGET_SERVERS_NOT_IN_SYNC	debug_target_servers_not_in_sync	Class PD	PL Debugger Error	\N
338	D0008	E	ERRCODE_TARGET_SERVER_ALREADY_SYNC	target_server_already_in_sync	Class PD	PL Debugger Error	\N
339	D0009	E	ERRCODE_NONEXISTANT_VARIABLE	non_existant_variable	Class PD	PL Debugger Error	\N
340	D0010	E	ERRCODE_INVALID_TARGET_SESSION_ID	invalid_target_session_id	Class PD	PL Debugger Error	\N
341	D0011	E	ERRCODE_INVALID_OPERATION	invalid_operation	Class PD	PL Debugger Error	\N
342	D0012	E	ERRCODE_MAX_DEBUG_SESSIONS_REACHED	maximum_number_of_debug_sessions_reached	Class PD	PL Debugger Error	\N
343	D0013	E	ERRCODE_MAX_BREAKPOINTS_REACHED	maximum_number_of_breakpoints_reached	Class PD	PL Debugger Error	\N
344	D0014	E	ERRCODE_INITIALIZE_FAILED	initialization_failed	Class PD	PL Debugger Error	\N
345	RB001	E	ERRCODE_RBTREE_INVALID_NODE_STATE	rbtree_invalid_node_state	Class RB	RBTree Error	\N
346	RB002	E	ERRCODE_RBTREE_INVALID_ITERATOR_ORDER	rbtree_invalid_iterator_order	Class RB	RBTree Error	\N
347	DB001	W	ERRCODE_DEBUG	debug	Class DB	Debug info	\N
348	DB010	W	ERRCODE_LOG	log	Class DB	Log info	\N
349	OP001	E	ERRCODE_OPERATE_FAILED	operate_failed	Class DB	Operate Error & Warning	\N
350	OP002	E	ERRCODE_OPERATE_RESULT_NOT_EXPECTED	operate_result_not_expected	Class DB	Operate Error & Warning	\N
351	OP003	E	ERRCODE_OPERATE_NOT_SUPPORTED	operate_not_supported	Class DB	Operate Error & Warning	\N
352	OP0A3	E	ERRCODE_OPERATE_INVALID_PARAM	operate_invalid_param	Class DB	Operate Error & Warning	\N
353	OP004	E	ERRCODE_INDEX_OPERATOR_MISMATCH	ClassDB	Operate Error & Warning	\N	\N
354	OP005	E	ERRCODE_NO_FUNCTION_PROVIDED	ClassDB	Operate Error & Warning	\N	\N
355	LL001	E	ERRCODE_LOGICAL_DECODE_ERROR	logical_decode_error	Class DB	Operate Error & Warning	\N
356	LL002	E	ERRCODE_RELFILENODEMAP	relfilenodemap	Class DB	Operate Error & Warning	\N
357	TS000	E	ERRCODE_TS_COMMON_ERROR	timeseries_common_error	Class TS	Timeseries Error	\N
358	TS001	E	ERRCODE_TS_KEYTYPE_MISMATCH	column_key_type_mismatch	Class TS	Timeseries Error	\N
359	ORC00	O	ORC_INFO	INVALID_ERROR_CODE	无效错误类型	\N	\N
360	ORC01	O	ORC_ERROR	NOTIMPLEMENTEDYET	不支持错误类型	\N	\N
361	ORC02	O	ORC_ERROR	PARSEERROR	编译错误类型	\N	\N
362	ORC03	O	ORC_ERROR	LOGICERROR	逻辑错误类型	\N	\N
363	ORC04	O	ORC_ERROR	RANGEERROR	范围错误类型	\N	\N
364	ORC05	O	ORC_ERROR	WRITEERROR	写错误类型	\N	\N
365	ORC06	O	ORC_FATAL	ASSERTERROR	中断错误类型	\N	\N
366	ORC07	O	ORC_ERROR	MEMORYERROR	内存错误类型	\N	\N
367	ORC08	O	ORC_ERROR	OTHERERROR	其他错误类型	\N	\N
\.
;

--
-- PostgreSQL database dump complete
--

