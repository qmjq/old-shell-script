#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://www.opsxyz.com 
#     http://qiaomiao.blog.51cto.com
#date: 20190712 v1.0
#author:QMJQ

#description: loop exec tcping , Calling a third script Winxin.py

DATE=`date`
PWD=`pwd`
LOG=/dev/null

REMOTE_IP="47.244.118.214 47.112.127.38 47.105.76.7"
THIRD_SCRIPT="Weixin.py"
USER=Jade
PORT="1800"




#执行外部脚本
function F_DO_THIRD_SCRIPT () {
	THIRD_SCRIPT=$1
	ARG01=$2
	ARG02=$3
	ARG03=$4
	$PWD/$THIRD_SCRIPT $ARG01 $ARG02 $ARG03
}

#主循环函数
function F_LOOP_SCRIPT () {
	
	echo $REMOTE_IP
	echo $THIRD_SCRIPT
	echo $USER
	while true :
		do
		sleep 5
		for x in $REMOTE_IP
		    do 
			#sleep 5 
			tcping -t 3 $x $PORT |grep -Ev "timeout|close" >/dev/null || F_DO_THIRD_SCRIPT $1 $2 "$3$x\端口$PORT" $4 	
		done;
	done;
}


#F_LOOP_SCRIPT $1 $2  $3 $4  

F_LOOP_SCRIPT  $THIRD_SCRIPT $USER "深圳办公网络到转发服务器" "严重timeout,请注意!!!"

