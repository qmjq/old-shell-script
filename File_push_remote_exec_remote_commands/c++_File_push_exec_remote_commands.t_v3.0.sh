#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://www.opsxyz.com 
#     http://qiaomiao.blog.51cto.com
#date: 20190523 v3.0
#author:QMJQ
#description: Push file remote and Execute remote commands

#全局变量
DATE=`date`
PWD=`pwd`
LOG=/dev/null
WHOAMI=root
PORT=$PORT
REMOTE_IP=$REMOTE_IP
TEST_PORT=$TEST_PORT
TEST_IP=$TEST_IP
DEPLOY_OR_ROLLBACK=$DEPLOY_OR_ROLLBACK
DIR=$DIR


#取远程IP
function F_REMOTE_IP (){
         REMOTE_IP=($(echo $REMOTE_IP|awk 'NF'))
         echo ${REMOTE_IP[@]}
}

#取远程目录
function F_DIR (){
         DIR=($(echo $DIR|awk 'NF'))
         echo ${DIR[@]}
}

#执行远程命令
function F_SSHD () {
         ssh -p $2 $WHOAMI@"$1" "$3"
}


#将测试环境的文件拉到本地
function F_PULL_RSYNC () {                              
         rsync -vzrlptD -e "ssh -p $2" --exclude=".git/"  --exclude="*.log" --exclude="*.log.*" --exclude="^logs$ "  $WHOAMI@$1:$4  $PWD/$3/   
         rm -rf ./$5 >/dev/null 2>&1; 
            
}


#执行文件PUSH同步
function F_PUSH_RSYNC () {                        
         rm -rf ./$5 >/dev/null 2>&1;
         rsync -vzrlptD -e "ssh -p $2" --exclude=".git/"   --exclude="*.log" --exclude="*.log.*" --exclude="^logs$ "  $PWD/$3  $WHOAMI@$1:$4/ 
}

#备份还原PUSH同步
function F_PUSH_BACK_RSYNC () {                        
         rm -rf ./$5 >/dev/null 2>&1;
         rsync -vzrlptD -e "ssh -p $2" --exclude=".git/"   --exclude="*.log" --exclude="*.log.*" --exclude="^logs$ "  $WHOAMI@$1:$3  $WHOAMI@$1:$4/ 
}


#判断是更新还是回滚
function F_DEPLOY_BACK () {
      
         echo $DEPLOY_OR_ROLLBACK
         case $DEPLOY_OR_ROLLBACK in
             DEPLOY)
                 echo "DEPLOY: $DEPLOY_OR_ROLLBACK"
                 F_PUSH_UPDATE
             ;;
             ROLLBACK)
                 echo "ROLLBACK: $DEPLOY_OR_ROLLBACK"
                 F_PUSH_BACK
             ;;
          *)
         exit
         ;;
         esac
}

#更新服务
function F_PUSH_UPDATE () {

          #执行远程命令
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;systemctl stop crond"  
          
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/msgd stop"  
          #F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/notifyd stop" 
          
          
          #范例 同步当前目录文件abc 到端口为PORT的远程主机 目录 ，并排除 A/B/C               
          F_PUSH_RSYNC $REMOTE_IP	$PORT 	"msg_server"             "/data/server/msgserver/$DIR" ""
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"notify_server"          "/data/server/notifyserver/notify" ""

          
          F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libbase.so"             "/data/server/msgserver/lib" ""
          F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libcommongrpc.so"       "/data/server/msgserver/lib" ""
          F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libdatabase.so"         "/data/server/msgserver/lib" ""
          
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libbase.so"             "/data/server/notifyserver/lib" ""
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libcommongrpc.so"       "/data/server/notifyserver/lib" ""
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libdatabase.so"         "/data/server/notifyserver/lib" ""

          
          #测试用的
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"msg_server"              "/data/server/test" ""
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"notify_server"           "/data/server/test" ""
        
          
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libbase.so"             "/data/server/test" ""
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libcommongrpc.so"       "/data/server/test" ""
          #F_PUSH_RSYNC $REMOTE_IP	$PORT 	"libdatabase.so"         "/data/server/test" "" 
          
          
          #执行远程命令  
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/msgd start  >/dev/null 2>&1 & "
          #F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/notifyd start  >/dev/null 2>&1 & "
         
          
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;systemctl start crond" 

}

#回滚服务
function F_PUSH_BACK () {

          echo "F_PUSH_BACK"
          
          #执行远程命令
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;systemctl stop crond"  
          
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/msgd stop"  
          #F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/notifyd stop" 
                  
             
             
             
          #回滚函数 
          F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/msg_server"              "/data/server/msgserver/$DIR" ""
          #F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/notify_server"           "/data/server/notifyserver/notify" ""
          
          
          F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/libbase.so"             "/data/server/msgserver/lib" ""
          F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/libcommongrpc.so"       "/data/server/msgserver/lib" ""
          F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/libdatabase.so"         "/data/server/msgserver/lib" ""
          
          #F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/libbase.so"             "/data/server/notifyserver/lib" ""
          #F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/libcommongrpc.so"       "/data/server/notifyserver/lib" ""
          #F_PUSH_BACK_RSYNC $REMOTE_IP	$PORT 	"/data/server/updatebak/libdatabase.so"         "/data/server/notifyserver/lib" ""
                   
                
          
          #执行远程命令  
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/msgd start  >/dev/null 2>&1 & "
          #F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;/etc/init.d/notifyd start  >/dev/null 2>&1 & "
         
          
          F_SSHD  $REMOTE_IP 	$PORT 	"source /etc/profile;systemctl start crond" 


}

#主程序
function F_PUSH_SSHD () {
		
        F_PULL_RSYNC $TEST_IP $TEST_PORT "" "/data/server/msg/msg_server" ""
        #F_PULL_RSYNC $TEST_IP $TEST_PORT "" "/data/server/notify/notify_server" ""
        
        F_PULL_RSYNC $TEST_IP $TEST_PORT "" "/data/server/lib/libbase.so" ""
        F_PULL_RSYNC $TEST_IP $TEST_PORT "" "/data/server/lib/libcommongrpc.so" ""
        F_PULL_RSYNC $TEST_IP $TEST_PORT "" "/data/server/lib/libdatabase.so" ""
        
        F_REMOTE_IP
        num=${#REMOTE_IP[@]}

        for ((i=0;i<$num;i++))
        do
                REMOTE_IP=${REMOTE_IP[i]}
                
				for ((y=0;y<$num;y++))
        		do
                	DIR=${DIR[y]}  	
                	F_DEPLOY_BACK
                done
                
                #F_SSHD  $REMOTE_IP 	$PORT 	"\cp -r /data/server/msgserver/msg/msg_server /data/server/notifyserver/notify/notify_server /data/server/msgserver/lib/libbase.so /data/server/msgserver/lib/libcommongrpc.so /data/server/msgserver/lib/libdatabase.so /data/server/updatebak && tar -zcvf  /data/server/updatebak.$(date +%Y%m%d%H%M).tar.gz  -C /data/server/ updatebak"
                F_SSHD  $REMOTE_IP 	$PORT 	"\cp -r /data/server/msgserver/msg/msg_server /data/server/msgserver/lib/libbase.so /data/server/msgserver/lib/libcommongrpc.so /data/server/msgserver/lib/libdatabase.so /data/server/updatebak && tar -zcvf  /data/server/updatebak.$(date +%Y%m%d%H%M).tar.gz  -C /data/server/ updatebak"
                

        done

}

F_PUSH_SSHD

