#!/usr/bin/python3
#  _*_  coding:  utf-8 _*_

#==============================================================#
# File      :   generate_report_template_v1.0.1.py
# Ctime     :   2021-11-27
# Mtime     :   2021-12-20
# Desc      :   inspection docxtemplate  tool
# Path      :   ../files/db_inspection/shell/generate_report_g100
# Author    :   Alicebat 
#==============================================================#

import os,time,re
from docxtpl import DocxTemplate

#------------------------------------------------------------------------------
# paraments msg
#------------------------------------------------------------------------------
#### check result file dict ####
check_result_file_dict = dict()
data_docx =  dict()
### init configuration ###
cur_dir = os.path.abspath(os.path.dirname(os.path.dirname(__file__)))
resluts_dir = os.path.join(cur_dir,'resluts')
tar_dir = os.path.join(resluts_dir,'primary_VM-16-10-centos_2022-01-06_15432\\VM-16-10-centos_15432\\')

### node role flag file ###
primary_flag_file = 'is_primary.txt'
secondary_flag_file = 'is_secondary.txt'

### dictionary append key and list ####
perf_key='性能分析'
perf_append_list=['TOP 10语句','数据库缓存命中率']
repl_key='数据库复制'
primary_append_list=['数据库复制状态','数据库复制槽状态']
secondary_append_list=['wal_receiver状态']



def init_check_result_file_dict(path):
    """
    function: get all txt name 
    input :  inspection result file dir
    output:  inspection txt name 
             for example {'1.10': '1.10_sys_uptime.txt',....}
    """
    f_list = os.listdir(path)
    for fname in f_list:
        if os.path.splitext(fname)[1] == '.txt':
            file_pre_num=fname.split('_')[0]
            ### first position is number,then output
            if not file_pre_num.isalpha():
                check_result_file_dict[file_pre_num]= fname



def get_content_from_file(file_name):
    """
    function: get content from check result file
    input :  file_name
    output:  read file_name  content
    """
    with open(file_name,encoding='utf-8') as file_obj:
        content = file_obj.read()
        return content

def check_item_detail(path):
    """
    function: check_item_detail
    input :  NA
    output:  get result 
             for example {{'sysuptimetxt': ' 13:47:50 up 586 days, 21:41,  2 users,  load average: 1.00, 1.01, 1.05\n',....}
    """
    for idx_detail  in check_result_file_dict.values():
        idx_keys = re.sub(u"([^\u0041-\u005a\u0061-\u007a])","" ,idx_detail)
      #  if idx_keys == 'ipaddresstxt':
         #   continue
        idx_result = get_content_from_file(path + str(idx_detail))
        data_docx[idx_keys] = idx_result

def read_content_from_file(fname):
    """
    function: get hostname result file
    input :  file_name
    output:  read hostname  content
    """
    with open(fname,encoding='utf-8') as file_obj:
        return file_obj.read().strip('\n')


### main procedure ###
if __name__ == "__main__":

    ### get check database hostname ###
    default_check_hostname_result_file =  tar_dir +'1.1_hostname.txt'
    check_hostname = read_content_from_file(default_check_hostname_result_file)

    ### generate doc file content ####
    init_check_result_file_dict(tar_dir)
    print(check_result_file_dict)
    check_item_detail(tar_dir)
    
    primary_role = os.path.exists(os.path.join(tar_dir,primary_flag_file))
    check_hostname = 'primary_' + check_hostname if primary_role else  'secondary_' + check_hostname
    

    ## save docx
    doc = DocxTemplate('../template/Template1.docx')
    doc.render(data_docx)
    doc_file_name = check_hostname + '.docx'
    doc.save(doc_file_name)
