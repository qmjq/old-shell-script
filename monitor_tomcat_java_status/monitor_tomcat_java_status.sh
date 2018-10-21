#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://www.opsxyz.com 
#     http://qiaomiao.blog.51cto.com
#date: 20181021 v1.0
#author:QMJQ
#description: monitor tomcat or java ,and sending wrong alarm messages.

#全局变量
DATE=$(date +%Y%m%d)
V_LOG="/tmp/${0}.log"
RNDIR=`pwd`   			#脚本目录

# nginx重启的脚本
P_NGINX="/usr/local/ngx/nginx"
V_NGINX_STOP="$P_NGINX/sbin/nginx -s stop"
V_NGINX_START="$P_NGINX/sbin/nginx"
V_NGINX_RELOAD="$P_NGINX/sbin/nginx -s reload"
DIR_NGINX_CONF="$P_NGINX/conf"

WAN_IP1="8.8.8.8"
LAN_IP1="172.18.242.234"
WAN_IP2="4.4.4.4"
LAN_IP2="172.18.201.160"
PORT="10000 10001 10002"
URL1=''
URL2=''

ACC_USER="qmjq"
PASSWD="20180116"
MSMUSER="qmjq"
MSMPASSWD="20180116"
PHONE="13400000000"
source /etc/profile

cd $DIR_NGINX_CONF

function restart_nginx(){
    echo "----- `date` -----" >> $V_LOG
    echo "------------------" >> $V_LOG
    echo "`ps aux |grep 'ngx'`" >> $V_LOG
    echo "------------------" >> $V_LOG
    #   echo "`ps aux |grep 'php-cgi'`" >> $V_LOG
    echo "------------------" >> $V_LOG
    echo "`netstat -nlpt | grep 'php-cgi'`" >> $V_LOG
    echo "------------------" >> $V_LOG
    $V_NGINX_STOP  >> $V_LOG
    $V_NGINX_START  >> $V_LOG
}
function reload_nginx(){
    echo "----- `date` -----" >> $V_LOG
    echo "------------------" >> $V_LOG
    echo "`ps aux |grep 'ngx'`" >> $V_LOG
    echo "------------------" >> $V_LOG
    $V_NGINX_RELOAD  >> $V_LOG
}

function check_url (){
    		STATUS1=`java -jar $RNDIR/MonitorUtils.jar http://$URL1/ $ACC_USER $PASSWD 2>&1`
        	STATUS2=`java -jar $RNDIR/MonitorUtils.jar http://$URL2/ $ACC_USER $PASSWD 2>&1`
}

function alarm_messages(){
    if [ "$STATUS1" = "false" -a "$STATUS2" = "true" ]; then
        cat nginx.conf| grep "server $URL1;"
        if [[ "$?" -eq 0 ]]; then
            echo "[error]URL:"$WAN_IP1/$URL1"检查失败！" >> $V_LOG \
            && java -jar $RNDIR/SmsTools.jar $PHONE "[error]URL:"外网IP:$WAN_IP1/内网IP:$URL1"检查失败,请立即处理！" $MSMUSER $MSMPASSWD
            sed -i "/#$1/{n;d}" nginx.conf
            sed -i "/#$1/aserver $URL2;" nginx.conf
            reload_nginx
        fi
    elif [ "$STATUS1" = "true" -a "$STATUS2" = "false" ]; then
        cat nginx.conf| grep "server $URL2;"
        if [[ "$?" -eq 0 ]]; then
            echo "[error]URL:"$WAN_IP2/$URL2"检查失败！" >> $V_LOG \
            && java -jar $RNDIR/SmsTools.jar $PHONE "[error]URL:"外网IP:$WAN_IP2/内网IP:$URL2"检查失败,请立即处理！" $MSMUSER $MSMPASSWD
            sed -i "/#$1/{n;d}" nginx.conf
            sed -i "/#$1/aserver $URL1;" nginx.conf
            reload_nginx
        fi
    elif [ "$STATUS1" = "false" -a "$STATUS2" = "false" ]; then
        echo "[error]URL:严重！！！"$WAN_IP1/$URL1" and "$WAN_IP2/$URL2"检查失败！" >> $V_LOG \
            && java -jar $RNDIR/SmsTools.jar $PHONE "[error]URL:严重!!!"外网IP:$WAN_IP1/内网IP:$URL1" and "外网IP:$WAN_IP2/内网IP:$URL2"检查失败,请立即处理!" $MSMUSER $MSMPASSWD
    else
        echo "[info]URL检查页面正常." >> $V_LOG
        echo "------------------" >> $V_LOG
    fi
    
}

# 循环执行,不采用 crontab ,国为 crontab 最小单位是分钟,时间太长了
while :
do
    
    # 1:先检测 nginx 主进程是否存在
    echo "[info]开始监控nginx...[$(date +'%F %H:%M:%S')]" >> $V_LOG
    V_NGINX_NUM=`ps axu |grep 'ngx' |grep -v 'grep' |wc -l`
    if [ $V_NGINX_NUM -lt 1 ];then
        restart_nginx
        continue
    fi
    for i in $PORT ;do
	URL1=$LAN_IP1:$i
        URL2=$LAN_IP2:$i
        echo $URL1
        echo $URL2
	check_url
	alarm_messages $i
    done   
    
    # 休眠
    sleep 30
done
