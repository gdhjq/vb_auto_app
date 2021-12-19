#!/usr/bin/python3.6
#  _*_  coding:  utf-8 _*_

"""
Description: 
@author: xiao H
"""
import os,time,re
from docxtpl import DocxTemplate


#### check result file dict ####
check_result_file_dict = dict()
data_docx =  dict()
def init_check_result_file_dict(path):
    f_list = os.listdir(path)
    for fname in f_list:
        if os.path.splitext(fname)[1] == '.txt':
            file_pre_num=fname.split('_')[0]
            ### first position is number,then output
            if not file_pre_num.isalpha():
                #print(file_pre_num,fname)
                check_result_file_dict[file_pre_num]= fname


### get content from check result file ###
def get_content_from_file(file_name):
    with open(file_name,encoding='utf-8') as file_obj:
        content = file_obj.read()
        #print(content)
        return content

#### def: check_item_detail #####
def check_item_detail():

    for idx_detail  in check_result_file_dict.values():
        #print(idx_detail)
        idx_keys = re.sub(u"([^\u0041-\u005a\u0061-\u007a])","" ,idx_detail)
      #  if idx_keys == 'ipaddresstxt':
         #   continue
        idx_result = get_content_from_file(str(idx_detail))
        data_docx[idx_keys] = idx_result
        #print(data_docx)

### read content from check result file ###
def read_content_from_file(fname):
    with open(fname) as file_obj:
        return file_obj.read().strip('\n')

### check file exists or not, exist return TRUE ###
def file_exists(file_name,dir_name):
    for file_item in os.listdir(dir_name):
        if file_item == file_name:
            return True

### main procedure ###
if __name__ == "__main__":
    ### init configuration ###
    cur_dir = os.getcwd()

    ### node role flag file ###
    primary_flag_file = 'is_primary.txt'
    secondary_flag_file = 'is_secondary.txt'

    ### dictionary append key and list ####
    perf_key='性能分析'
    perf_append_list=['TOP 10语句','数据库缓存命中率']
    repl_key='数据库复制'
    primary_append_list=['数据库复制状态','数据库复制槽状态']
    secondary_append_list=['wal_receiver状态']

    ### get check database hostname ###
    default_check_hostname_result_file = '1.1_hostname.txt'
    check_hostname = read_content_from_file(default_check_hostname_result_file)

    ### generate doc file content ####
    init_check_result_file_dict(cur_dir)
    print(check_result_file_dict)
    check_item_detail()
    primary_role =file_exists(primary_flag_file,cur_dir)
    secondary_role =file_exists(secondary_flag_file,cur_dir)

    if primary_role:
        check_hostname = 'primary_' + check_hostname
    if  secondary_role:
        check_hostname = 'secondary_' + check_hostname
    ## save docx

    doc = DocxTemplate('Template1.docx')
    doc.render(data_docx)
    doc_file_name = check_hostname + '.docx'
    doc.save(doc_file_name)
