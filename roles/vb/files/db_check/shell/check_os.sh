#!/bin/bash

#==============================================================#
# File      :   configure
# Ctime     :   2021-11-14
# Mtime     :   2021-11-20
# Desc      :   configure {PG,Vastbase}
# Usage     :   ./configure [-imdn]
# Note      :   run as admin user (nopass sudo & ssh)
# Path      :   configure
#==============================================================#




#==============================================================#
# const
#==============================================================#
# Aliceauto version string
VERSION=v1.1.0



#==============================================================#
# environment
#==============================================================#
PWD=`pwd`



#==============================================================#
# color log util
#==============================================================#
__CN='\033[0m'    # no color
__CB='\033[0;30m' # black
__CR='\033[0;31m' # red
__CG='\033[0;32m' # green
__CY='\033[0;33m' # yellow
__CB='\033[0;34m' # blue
__CM='\033[0;35m' # magenta
__CC='\033[0;36m' # cyan
__CW='\033[0;37m' # white
function log_info() {  printf "OK $* \n";   }
function log_warn() {  printf "WARN $*\n";   }
function log_error() { printf "FAIL $* \n";   }
function log_debug() { printf "HINT  $* \n"; }
function log_input() { printf "IN  $*\n=>"; }
function log_hint()  { printf "$* "; }
ipv4_regexp='(([0-9]|[0-9]{2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[0-9]{2}|1[0-9]{2}|2[0-4][0-9]|25[0-5])'
#==============================================================#


#远程服务器执行应该返回json方式 后续规划
#echo "---" 
#echo "# vars file for vb" 
 

#----------------------------------------------#
# kernel
#----------------------------------------------#
function check_kernel(){
    local kernel_name=$(uname -s)
    if [[ "${kernel_name}" == "Linux" ]]; then
        log_info "kernel = ${kernel_name}"
        #echo "#kernel" 
        #echo "kernel_name: $(uname -s)"  
        return 0
    else
        log_error "kernel = ${kernel_name}, not supported, Linux only"
        exit 1
    fi
}


#----------------------------------------------#
# machine
#----------------------------------------------#
function check_machine(){
    local machine_name=$(uname -m)
    if [[ "${machine_name}" == "x86_64" ]]; then
        log_info "machine = ${machine_name}"
        #echo "machine_name: $(uname -m)" 
        return 0
    elif [[ "${machine_name}" == "aarch64" ]]; then
        log_info "machine = ${machine_name}"
        #echo "machine_name: $(uname -m)" 
        return 0
    else
        log_error "machine = ${machine_name}, not supported, x86_64&aarch64 only"
        exit 2
    fi
}


#----------------------------------------------#
# os release (Linux|supported redhat&openEuler)
#----------------------------------------------#
function check_release(){
    if [[ ! -f /etc/os-release ]]; then
        log_error "release = unknown, /etc/os-release not exists"
        exit 3
    fi
    while read line;
    do
        eval "$line"
    done < /etc/os-release
    if [[ "${NAME}" == 'CentOS Linux' ]]; then
        #echo "os_name: ${NAME}"
        local full=`cat /etc/centos-release | tr -dc '0-9.'`
        local major=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)
        local minor=$(cat /etc/centos-release | tr -dc '0-9.' |cut -d \.  -f 1,2)
        #echo "os_version=$(cat /etc/centos-release | tr -dc '0-9.' |cut -d \.  -f 1,2)" 
        if [[ ${major} != "7" ]]; then
            log_error "release = ${full} , only 7 is supported"
            exit 4
        fi
        if [[ ${minor} == "7.6" ]]; then
            log_info "release = ${full} , perfect"
        elif [[ ${minor} == "7.4" ]]; then
            log_info "release = ${full} , perfect"
        else
            log_warn "release = ${full} , it's fine. But beware that 'yum.tgz' are made under 7.8"
            log_hint "HINT: If something goes wrong with minor version. Consider bootstrap via Internet without yum.tgz \n"
        fi
        return 0
    elif [[ "${NAME}" == 'openEuler' ]];then
        #echo "os_name: ${NAME}" 
        #echo ""
        local full=`cat /etc/openEuler-release | tr -dc '0-9.'`
        local asynchronous=$(uname -a |awk '{print $3}'|cut -d \- -f1)
        if [[ ${asynchronous} == '4.19.90' ]];then 
            log_warn "core='4.19.90  will arise IO-ERROR please update pkg"
        fi
    else 
        log_error "now not supported, centos & openEuler only"
    fi
}



#----------------------------------------------#
# sudo
#----------------------------------------------#
function can_nopass_sudo(){
    local current_user=$(whoami)
    if [[ "${current_user}" == "root" ]]; then
        return 0
    fi
    if sudo -n ls >/dev/null 2>/dev/null; then
        return 0
    fi
    return 1
}

function check_sudo(){
    local current_user=$(whoami)
    if can_nopass_sudo; then
        log_info "sudo = ${current_user} ok"
    else
        log_error "sudo = ${current_user} missing nopasswd"
        log_warn "fix nopass sudo for '${current_user}' with sudo:"
        log_hint "echo '%%${current_user} ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/${current_user}"
        exit 5
    fi
}



function check_mem(){
    #echo "mem_info: $(cat /proc/meminfo |grep MemTotal|awk '{print $2}')" 
    #echo "page_size: $(getconf PAGE_SIZE)" 
    if [[ ! -f /proc/meminfo ]]; then
        log_error "mem = unknown, /proc/meminfo not exists"
        exit 6
    fi
    log_info "mem_info = $(cat /proc/meminfo |grep MemTotal|awk '{print $2}') KB"
}

function check_secure(){
    local firewalld_info=$(systemctl status firewalld |grep Active|awk '{print $2}')
    local selinux_info=$(getenforce)
    if [[ ${firewalld_info} == 'active' ]]; then
        log_warn "secure firewall is not close "
        return  1
    fi
    if [[ ${selinux_info} != 'Disabled' ]]; then
        log_warn "secure selinux  is not Disabled"
        return  1
    fi
    log_info "secure = Disabled  OK"
    
}

#======================================================#
# check python version whetther supported
#======================================================#
function python_version(){
    local py_version=$(python3 --version)
    if [[ $? -eq 0 ]];then
        log_info  ${py_version} "python  is OK"
        local py_modle=$(pip3 list --format=columns|grep -E "docxtpl"|wc -l)
        if [[ ${py_modle} -eq 0 ]];then
            log_error "[vastbase-52200] : Unable to import module"
        fi
    else
        log_error  py2_version=`python --version`
        log_error "[vastbase-52201] : The current python version is not supported."
        exit 7
    fi        
}

#========================================#
# main
#========================================#
function main(){

    log_hint "configure Aliceauto ${VERSION} begin\n"
    #empty cfg
    #echo "[conf]" > conf.cfg
    # check
    check_kernel     # kernel        = Linux
    check_machine    # machine       = x86_64
    check_release    # OS
    check_sudo       # current_user  = NOPASSWD sudo
    check_mem        # mem_info      = KB
    check_secure     # secure
    python_version   # python
    log_hint "configure Aliceauto done. Use 'make install' to proceed\n"
}


main $@
