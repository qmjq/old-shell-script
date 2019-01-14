#!/bin/bash
#blog:http://qiaomiao.blog.51cto.com
#date: 20171208 v3.0
#author:QMJQ
#description: use curl and telnet test program's status. if program is faied then send mail.

DATE=`date`
PWD=`pwd`
LOG=/dev/null
IP=$(ip addr |grep  "brd" |grep  -v "link"|awk  '{print   $2}')
echo  -e "$DATE \n" >> $LOG
#read -p "ip or url :"  IPURL
#read -p "port:"   PORT
#read -p "user curl or telnet:"  MODE
#read -p "program that you want killed:"  PROGRAM

#	显示颜色。
function RED_COLOR () {
	echo -e "\033[31m $1 \033[0m"	
}
function GREEN_COLOR () {
	echo -e "\033[32m $1 \033[0m"	
}

#	主函数，判断检测是TELNET_CHECK,还是CURL_CHECK,并执行相应操作。默认为TELNET_CHECK。
function CHECK () {
	IPURL=$1;PORT=$2;MODE=$3;PROGRAM=$4
	echo -e  "'check' $DATE $IPURL $PORT $MODE $PROGRAM \n" >> $LOG
	[[ $MODE == "telnet"  ]] && TELNET_CHECK 
	[[ $MODE == "curl"  ]] && CURL_CHECK
	[[ $MODE != "curl"  ]] && [[ $MODE != "telnet"  ]] && RED_COLOR "Mode Error,use default ... \n telnet ... \n " &&  TELNET_CHECK

}

#	TELNET_CHECK检测函数。
function TELNET_CHECK () {
	echo -e  "'telnet' $DATE $IPURL $PORT \n" >> $LOG
	#echo "q"|telnet $IPURL $PORT  2>/dev/null|grep "Escape character is '^]'" && exit 0  || KILL_PROGRAM	
	echo "q"|telnet $IPURL $PORT  2>/dev/null|grep "Escape character is '^]'" || KILL_PROGRAM	
}

#	CURL_CHECK检查函数。
function CURL_CHECK () {
	echo -e  "'curl' $DATE $IPURL $PORT \n" >> $LOG
	#curl -I $IPURL:$PORT 2>/dev/null |grep -E "HTTP\/1.1\ 3|HTTP\/1.1\ 2|HTTP\/1.1\ 4" && exit 0  || KILL_PROGRAM		
	curl -I $IPURL:$PORT 2>/dev/null |grep -E "HTTP\/1.1\ 3|HTTP\/1.1\ 2|HTTP\/1.1\ 4" || KILL_PROGRAM		
}

#	KILL_PROGRAM关闭进程函数。
function KILL_PROGRAM () {
	killall $PROGRAM && GREEN_COLOR "kill $PROGRAM ok" >> $LOG && SEND_MAIL Sucesss || RED_COLOR "Failed kill $PROGRAM" >>$LOG
}

#	SEND_MAIL 发邮件函数。
function SEND_MAIL() {
	FROM_MAIL="lijing@libradata.com.cn"
	TO_MAIL="lijing@opsxyz.com jingge@opssite.cn"  #可以加多个邮件地址
	echo -e "Dear \n \b  sir \n \b		because port $PORT is down,\n \b 	so killed $PROGRAM $1 . \n \n \n \b From $FROM_MAIL \n \b $DATE"|mail -s "$IP port $PORT is down $DATE " -r $FROM_MAIL $TO_MAIL
}

#	执行主函数。
CHECK  "127.0.0.1" "80"   "curl"   "keepalived"   #curl   检查http://127.0.0.1:80,如果失败就kill keepalived  并发邮件
CHECK  "127.0.0.1" "3306" "telnet" "keepalived"   #telent 检查127.0.0.1 3306,如果失败就kill keepalived  并发邮件


