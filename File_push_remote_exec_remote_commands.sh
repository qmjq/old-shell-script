#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://www.opsxyz.com 
#     http://qiaomiao.blog.51cto.com
#date: 20190523 v1.0
#author:QMJQ
#description: Push file remote and Execute remote commands

#全局变量
DATE=`date`
PWD=`pwd`
LOG=/dev/null
WHOAMI=root
PORT=$PORT
REMOTE_IP=$REMOTE_IP

#取远程IP
function F_REMOTE_IP (){
                REMOTE_IP=($(echo $REMOTE_IP|awk 'NF'))
                echo ${REMOTE_IP[@]}
}

#执行远程命令
function F_SSHD () {
        ssh -p $2 $WHOAMI@"$1" "$3"
}

#执行文件PUSH同步
function F_PUSH_RSYNC () {
				echo $2 $WHOAMI@$1:$4/             
                
                rsync -vzrlptD -e "ssh -p $2"    --exclude="*.log" --exclude="*.log.*" --exclude="^logs$ " --exclude="$5"   $PWD/$3/*  $WHOAMI@$1:$4/                
                #rsync -avz  -e "ssh -p $2"  --exclude="*.log" --exclude="*.log.*" --exclude="^logs$ " --exclude="$5"   $PWD/$3/*  $WHOAMI@$1:$4/
}


#主程序
function F_PUSH_SSHD () {
		

        F_REMOTE_IP
        num=${#REMOTE_IP[@]}

        for ((i=0;i<$num;i++))
        do
                REMOTE_IP=${REMOTE_IP[i]}
				
                #备份远程文件
                F_SSHD  $REMOTE_IP 	$PORT 	"tar czf  /home/webroot/morseapp-api.$(date +%Y%m%d%H%M).bak.tar.gz /home/webroot/morseapp-api "
                F_SSHD  $REMOTE_IP 	$PORT 	"tar czf  /home/webroot/morseapp-api-swoole.$(date +%Y%m%d%H%M).bak.tar.gz /home/webroot/morseapp-api-swoole "
                
                #同步当前目录下文件 到端口为PORT的远程主机 目录
                F_PUSH_RSYNC $REMOTE_IP	$PORT 	""  "/home/webroot/morseapp-api"
                F_PUSH_RSYNC $REMOTE_IP $PORT	""  "/home/webroot/morseapp-api-swoole" 
                
				#范例 同步当前目录文件abc 到端口为PORT的远程主机 目录 ，并排除 A/B/C               
                #     F_PUSH_RSYNC $REMOTE_IP	$PORT 	"abc"  "/home/webroot/morseapp-api" "A/B/C"
        
                #执行远程命令
                F_SSHD  $REMOTE_IP 	$PORT 	"/etc/init.d/php_push stop"    
                F_SSHD  $REMOTE_IP 	$PORT 	"/etc/init.d/php_swoole stop"
                F_SSHD  $REMOTE_IP 	$PORT 	"/etc/init.d/php_swoole start"
                F_SSHD  $REMOTE_IP 	$PORT 	"/etc/init.d/php_push start"
        done

}

F_PUSH_SSHD

