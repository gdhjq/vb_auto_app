#!/usr/bin/env bash

#==============================================================#
# File      :   generate_report_g100
# Ctime     :   2021-12-27
# Mtime     :   2021-12-27
# Desc      :   vastbase G100   script
# Path      :   ../files/vb_om.sh
# Depend    :   .pgpass
# Author    :   Alicebat 
#==============================================================#

#==============================================================#
# const
#==============================================================#
# Aliceauto version string
VERSION=v1.1.0



#==============================================================#
# environment
#==============================================================#




#==============================================================#
#                             Usage                            #
#==============================================================#

function help() {
	cat <<-'EOF'
        NAME
            vb_om.sh   Vastbase G100 shell  operation
        
        DESCRIPTION
            -i 
                db_inspection   Vastbase G100  inspection operation
	EOF
}
#==============================================================#
#                             Utils                            #
#==============================================================#
# logger functions
function log_debug() {
	[ -t 2 ] && printf "\033[0;34m[$(date "+%Y-%m-%d %H:%M:%S")][DEBUG] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][DEBUG] $*\n" >&2
}
function log_info() {
	[ -t 2 ] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" >&2
}
function log_warn() {
	[ -t 2 ] && printf "\033[0;33m[$(date "+%Y-%m-%d %H:%M:%S")][WARN] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" >&2
}
function log_error() {
	[ -t 2 ] && printf "\033[0;31m[$(date "+%Y-%m-%d %H:%M:%S")][ERROR] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][INFO] $*\n" >&2
}



#--------------------------------------------------------------#
# Name: db_inspection
# Desc: execute db_inspection shell 
#--------------------------------------------------------------#
#function exe_inspection(){

#}



#==============================================================#
#                            MAIN                              #
#==============================================================#
function main() {
	# parse arguments
    local db_inspection=""
	local vb_home=""
	local db_data=""
	local db_port=""
    while (($# > 0)); do
    	a[$i]=$1
		case "${a[$i]}" in
            -i) 
		        [ "${a[$i]}" == "-i" ] && shift
                    db_inspection="TRUE"
                    ;;
	        -b)
                [ "${a[$i]}" == "-b" ] && shift
                    vb_home=${1##*=}
					vb_home=`echo ${vb_home}|  sed  -e 's/ *\[//;s/]//' `
					vb_home=(${vb_home//,/ })
                    shift
                    ;;
			-D)
			    [ "${a[$i]}" == "-D" ] && shift
                    db_data=${1##*=}
					db_data=`echo ${db_data}|  sed  -e 's/ *\[//;s/]//' `
					db_data=(${db_data//,/ })
                    shift
                    ;;
			-p)
			    [ "${a[$i]}" == "-p" ] && shift
                    #db_port=${1##*=}
					db_port=`echo ${1}|  sed  -e 's/ *\[//;s/]//;s/, /,/' `
					db_port2=`echo ${2}|  sed  -e 's/ *\[//;s/]//;s/,//'`
					db_port=(${db_port//,/ } ${db_port2})	
					shift
                    shift
                    ;;		
            -h)
                help
                exit
                ;;
            *)
    	        help
                exit 1
                ;;
                esac
            
        done

	if [[ ${db_inspection} == "TRUE" ]]
	then 
		if [[ ! -z "${vb_home}"  && ! -z  "${db_data}" && ! -z "${db_port}" ]]
		then
			for i in "${!vb_home[@]}"; do
			sh ./db_inspection/shell/generate_report_g100.sh  ${vb_home[i]}  ${db_data[i]}  ${db_port[i]}
			done
		else
			log_error "[INIT] -i parameter unmatched"
		fi
	fi



}


main "$@"
