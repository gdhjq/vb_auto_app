#!/bin/sh
## wyb  2021-12-31 ##
## Parameter $1:  unilateral/mutual
##             uilateral :  password free for the target server ( Can login to the target server without password)
##             mutual :  password free for both ( Source server and target server can login to each other without password )
##             all :  password free for any two servers of input
## Parameter $2:  silent      ( Non interactive mode )   --optional parameter
## Parameter $3:  username                           --optional parameter
## Parameter $4:  password                           --optional parameter
## Parameter $5:  targetIP                           --optional parameter
## Parameter $6:  localIP                           --optional parameter

cb_name=$1
cb_name2=$2
cb_name3=$3
cb_name4=$4
cb_name5=$5
cb_name6=$6
globalname=''

function usage() {
    echo ''
    echo "Usage one: $0 <unilateral|mutual|all> ";
    echo "Usage two: $0 unilateral  silent  [username] [password] [IP] ";
    echo "Usage three: $0 mutual silent [username] [password] [targetIP] [localIP]  :Two servers must to have same username/password.  ";
    echo ''
    exit 1;
}



function rsabuild(){
if [ -f ~/.ssh/id_rsa.pub ];
then
 echo 'id_rsa.pub already exists. '
else
 ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
fi
}



function unilateral(){
read -p "Please input  the IP addresses of all servers to be configured.  Example: 192.168.100.2,192.168.100.3 >>>>>"  servers
ip_list=`echo $servers|awk -F , '{for(i=1;i<=NF;i++){print $i}}'`
read -p "Are all the servers have same username and password?  Y/N >>>>>"  SSS
if [ "$SSS" = "Y" ]||[ "$SSS" = "y" ];then
  read -p "Please input username of all servers to be configured.  >>>>>"  uuu
  read -s -p "Please input password of all servers to be configured.  >>>>>"  ppp
  rsabuild
  for j in $ip_list
  do
    sshpass -p$ppp ssh-copy-id -i ~/.ssh/id_rsa.pub $uuu@$j
  done;
elif [ "$SSS" = "N" ]||[ "$SSS" = "n" ];then
  rsabuild
  for j in $ip_list
  do
    read -p "Please input username of server $j :   >>>>>"  uuuu
    read -s -p "Please input password of server $j :   >>>>>"  pppp
    sshpass -p$pppp ssh-copy-id -i ~/.ssh/id_rsa.pub $uuuu@$j
  done;
else
echo "your input is wrong.Please try again."
unilateral
fi

}



function unilateral_silent(){
## $1: username
## $2: password
## $3: ip address
rsabuild
sshpass -p$2  ssh-copy-id -i ~/.ssh/id_rsa.pub $1@$3

}




function mutual(){
read -p "Please input local IP: Example: 192.168.100.100   >>>>>" localip
read -p "Please input  the IP addresses of all servers to be configured.  Example: 192.168.100.2,192.168.100.3 >>>>>"  servers
ip_list=`echo $servers|awk -F , '{for(i=1;i<=NF;i++){print $i}}'`
read -p "Are all the servers have same username and password?  Y/N >>>>>"  SSS
if [ "$SSS" = "Y" ]||[ "$SSS" = "y" ];then
  read -p "Please input username of all servers to be configured.  >>>>>"  uuu
  read -s -p "Please input password of all servers to be configured.  >>>>>"  ppp
  rsabuild
  for j in $ip_list
  do
    sshpass -p$ppp ssh-copy-id -i ~/.ssh/id_rsa.pub $uuu@$j
  scp $uuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
  if [ -f ~/.ssh/tmp$j ];then
    cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
  else
ssh $uuu@$j<<EOF
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
EOF
  scp $uuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
  cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/authorized_keys
  fi
ssh $uuu@$j<<EOF
ssh $uuu@$localip -o StrictHostKeyChecking=no
EOF
  rm -f ~/.ssh/tmp$j
  done;
elif [ "$SSS" = "N" ]||[ "$SSS" = "n" ];then
  rsabuild
  for j in $ip_list
  do
    read -p "Please input username of server $j :   >>>>>"  uuuu
    read -s -p "Please input password of server $j :   >>>>>"  pppp
    sshpass -p$pppp ssh-copy-id -i ~/.ssh/id_rsa.pub $uuuu@$j
    scp $uuuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
    if [ -f ~/.ssh/tmp$j ];then
      cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
    else
ssh $uuuu@$j<<EOF
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
EOF
    scp $uuuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
    cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    fi
ssh $uuuu@$j<<EOF
ssh $uuuu@$localip -o StrictHostKeyChecking=no
EOF
    rm -f ~/.ssh/tmp$j
   done;
else
echo "your input is wrong.Please try again."
mutual
fi

}


function mutual_silent(){
## $1: username
## $2: password
## $3: target ip address
## $4: local ip address
rsabuild
sshpass -p$2  ssh-copy-id -i ~/.ssh/id_rsa.pub $1@$3
scp $1@$3:~/.ssh/id_rsa.pub ~/.ssh/tmp000
if [ -f ~/.ssh/tmp000 ];then
  cat ~/.ssh/tmp000 >> ~/.ssh/authorized_keys
else
ssh $3<<EOF
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
EOF
scp $1@$3:~/.ssh/id_rsa.pub ~/.ssh/tmp000
cat ~/.ssh/tmp000 >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
fi
ssh $3<<EOF
ssh $4 -o StrictHostKeyChecking=no
EOF
rm -f ~/.ssh/tmp000
}


function all(){
read -p "Please input local IP: Example: 192.168.100.100   >>>>>" localip
read -p "Please input  the IP addresses of all servers to be configured.  Example: 192.168.100.2,192.168.100.3 >>>>>"  servers
ip_list=`echo $servers|awk -F , '{for(i=1;i<=NF;i++){print $i}}'`
read -p "Are all the servers have same username and password?  Y/N >>>>>"  SSS
if [ "$SSS" = "Y" ]||[ "$SSS" = "y" ];then
  read -p "Please input username of all servers to be configured.  >>>>>"  uuu
  globalname=$uuu
  read -s -p "Please input password of all servers to be configured.  >>>>>"  ppp
  rsabuild
  for j in $ip_list
  do
    echo $uuu
    echo $ppp
    echo $j
    sshpass -p$ppp ssh-copy-id -i ~/.ssh/id_rsa.pub $uuu@$j
  scp $uuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
  if [ -f ~/.ssh/tmp$j ];then
    cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
  else
ssh $uuu@$j<<EOF
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
EOF
  scp $uuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
  cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
  chmod 700 ~/.ssh
  chmod 600 ~/.ssh/authorized_keys
  fi
ssh $uuu@$j<<EOF
ssh $localip -o StrictHostKeyChecking=no
EOF
#  rm -f ~/.ssh/tmp$j
  done;
elif [ "$SSS" = "N" ]||[ "$SSS" = "n" ];then
  rsabuild
  for j in $ip_list
  do
    read -p "Please input username of server $j :   >>>>>"  uuuu
    globalname=$uuuu
    read -s -p "Please input password of server $j :   >>>>>"  pppp
    sshpass -p$pppp ssh-copy-id -i ~/.ssh/id_rsa.pub $uuuu@$j
    scp $uuuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
    if [ -f ~/.ssh/tmp$j ];then
      cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
    else
ssh $uuuu@$j<<EOF
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
EOF
    scp $uuuu@$j:~/.ssh/id_rsa.pub ~/.ssh/tmp$j
    cat ~/.ssh/tmp$j >> ~/.ssh/authorized_keys
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys
    fi
ssh $uuuu@$j<<EOF
ssh $uuuu@$localip -o StrictHostKeyChecking=no
EOF
#    rm -f ~/.ssh/tmp$j
   done;
else
echo "your input is wrong.Please try again."
all
fi

cat ~/.ssh/id_rsa.pub>> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
for pp in $ip_list
do
  scp ~/.ssh/authorized_keys $globalname@$pp:~/.ssh/authorized_keys
done;

for m in $ip_list
do 
  for n in $ip_list
    do
    ssh $m<<EOF
ssh $n -o StrictHostKeyChecking=no
EOF
  done;
done;

}



if [ "$cb_name2" = "silent" ];then
 if [ "$cb_name" = "unilateral" ];then
   unilateral_silent $cb_name3 $cb_name4 $cb_name5
 elif [ "$cb_name" = "mutual" ];then
   mutual_silent $cb_name3 $cb_name4 $cb_name5 $cb_name6
 else 
   usage
 fi
else
case $cb_name in
    unilateral)
        unilateral
        ;;
    mutual)
        mutual
        ;;
       all)
        all
        ;;
    *)
        usage

        ;;
esac
fi