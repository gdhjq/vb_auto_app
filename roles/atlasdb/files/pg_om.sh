#!/usr/bin/env bash

#==============================================================#
# File      :   pg_om
# Ctime     :   2022-01-11
# Mtime     :   2022-01-11
# Desc      :   Postgresql    script
# Path      :   ../files/pg_om.sh
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
            pg_om.sh   postgresql shell  operation
        
        DESCRIPTION
            -i 
                db_inspection  postgresql  inspection operation
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
	local pg_home=""
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
                    pg_home=${1##*=}
					pg_home=`echo ${pg_home}|  sed  -e 's/ *\[//;s/]//' `
					pg_home=(${pg_home//,/ })
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
		if [[ ! -z "${pg_home}"  && ! -z  "${db_data}" && ! -z "${db_port}" ]]
		then
			for i in "${!pg_home[@]}"; do
			sh ./db_inspection/shell/pg_all.sh  ${pg_home[i]}  ${db_data[i]}  ${db_port[i]}
			done
		else
			log_error "[INIT] -i parameter unmatched"
		fi
	fi



}


main "$@"
