#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://www.opsxyz.com 
#     http://qiaomiao.blog.51cto.com
#date: 20190806 v1.0
#author:QMJQ

#description: loop exec curl , Calling a third script Winxin.py

DATE=`date`
PWD=`pwd`
LOG=/dev/null

REMOTE_IP="10.0.0.4 10.0.0.11"
THIRD_SCRIPT="Weixin.py"
USER=Jade
PORT="8001"




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
			for y in $PORT
			do
				#sleep 5 
				curl -s -X GET "http://$x:$y/getServerInfo?ip=127.0.0.1&uid=111&location=CN"|grep -E "获取成功" >/dev/null || F_DO_THIRD_SCRIPT $1 $2 "$(date +%Y%m%d-%H:%M)$3$x\端口$y" $4
			done;
		done;
	done;
}


#F_LOOP_SCRIPT $1 $2  $3 $4  

F_LOOP_SCRIPT  $THIRD_SCRIPT $USER "微软测试环境探测" "获取失败"

