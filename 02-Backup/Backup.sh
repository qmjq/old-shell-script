#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://qmjq.github.io
#     http://qiaomiao.blog.51cto.com
#date: 20180403 v2.0 20220823
#author:QMJQ
#description: backup remote or local file


#全局变量

DATE=$(date +%Y%m%d)
WHOAMI=$(whoami)
LOG=${0}.${DATE}.log
TOBACKUPDIR=/data/backup
NEEDBACKUPDIR=" "
IP="localhost"
KEEPDAY=7


#	删除创建文
function F_RMFILE () {
	rm -rf $1
}
#	创建文件夹
function F_MKFILE () {
	if [ ! -d "$1" ];then
        	mkdir -p "$1" >/dev/null 2>&1;
	fi
}
#	执行远程命令
function F_SSHD () {
	ssh $WHOAMI@"$1" "$2" 
}	
#	需要备份目录
function F_NEEDBACKUPFILE (){
	[ $1 = "localhost" -o $1 = "127.0.0.1" ] && NEEDBACKUPFILE=($(find $2 -maxdepth 1  \( -path "$2/lost+found" -o -path "$2/backup" -o -path "$2/*.log" -o -path "$2/brick*" \) -prune -o  -path "*" -print | awk -F"$2/" '{print $2}' |awk 'NF'))
	#find 理论上用""就可以，但是两次函数转换，所以用了 '""'
	[ $1 = "localhost" -o $1 = "127.0.0.1" ] || NEEDBACKUPFILE=($(F_SSHD $1 "find $2 -maxdepth 1  \( -path "$2/lost+found" -o -path "$2/backup" -o -path '"$2/*.log"' -o -path '"$2/brick*"' \) -prune -o  -path '"*"' -print" | awk -F"$2/" '{print $2}' |awk 'NF'))
	
	echo ${NEEDBACKUPFILE[@]}
}
#	备份函数
function F_RSYNC () {

	num=${#NEEDBACKUPFILE[@]}

	for ((i=0;i<$num;i++))
	do      
  		[ $1 = "localhost" -o $1 = "127.0.0.1" ] && [ -f $2/${NEEDBACKUPFILE[i]} ] && rsync -vzrtopg --delete  $2/${NEEDBACKUPFILE[i]} ${TOBACKUPDIR}/$1/temp/$2_${DATE}/${NEEDBACKUPFILE[i]}
  		[ $1 = "localhost" -o $1 = "127.0.0.1" ] && [ -d $2/${NEEDBACKUPFILE[i]} ] && rsync -vzrtopg --delete --exclude="*.log" --exclude="*.log.*" --exclude="^logs$"  $2/${NEEDBACKUPFILE[i]}/ ${TOBACKUPDIR}/$1/temp/$2_${DATE}/${NEEDBACKUPFILE[i]}
  	
		echo ".............................."	
		[ $1 = "localhost" -o $1 = "127.0.0.1" ] || [ -d $2/${NEEDBACKUPFILE[i]} ] || rsync -vzrtopg --delete  $WHOAMI@$1:$2/${NEEDBACKUPFILE[i]} ${TOBACKUPDIR}/$1/temp/$2_${DATE}/${NEEDBACKUPFILE[i]}
  		[ $1 = "localhost" -o $1 = "127.0.0.1" ] || [ -f $2/${NEEDBACKUPFILE[i]} ] || rsync -vzrtopg --delete --exclude="*.log" --exclude="*.log.*" --exclude="^logs$"  $WHOAMI@$1:$2/${NEEDBACKUPFILE[i]}/ ${TOBACKUPDIR}/$1/temp/$2_${DATE}/${NEEDBACKUPFILE[i]}
	done

}
#	主程序
function F_BACKUP () {
	for i in `echo $2`; do
		IP="$1" ;NEEDBACKUPDIR="$i" ;TOBACKUPDIR="$3" ;
		[ -z $NEEDBACKUPDIR ] && echo "请输入需备份目录" && exit 1 
		F_MKFILE $TOBACKUPDIR/$IP/temp/${NEEDBACKUPDIR}_${DATE}
		F_NEEDBACKUPFILE $IP $NEEDBACKUPDIR 
        	F_RSYNC $IP $NEEDBACKUPDIR		  
		##compress backup,two compress soft,you can chose one of then  
		#tar czf $TOBACKUPDIR/$IP/`basename $NEEDBACKUPDIR`_${DATE}.tar.gz $TOBACKUPDIR/$IP/temp/${NEEDBACKUPDIR}_${DATE} && rm  -rf $TOBACKUPDIR/$IP/temp
		tar cjf $TOBACKUPDIR/$IP/`basename $NEEDBACKUPDIR`_${DATE}.tar.bz $TOBACKUPDIR/$IP/temp/${NEEDBACKUPDIR}_${DATE} && rm  -rf $TOBACKUPDIR/$IP/temp
		#delete data from $TOBACKUPDIR $KEEPDAY days ago
		find $TOBACKUPDIR/$IP/* -maxdepth 0   -mtime +"$KEEPDAY" -exec rm -rf {} \;
	done
}


#nginx=`ps -ef|grep -v grep|grep nginx:|wc -l`
#if [ $nginx -gt 0 ]&&[ -e /usr/local/nginx ];then
#  rsync -vzrtopg --delete --exclude="logs" /usr/local/nginx/* ${TOBACKUPDIR}/nginx-$DATE
#fi

#范例

#备份远程主机 10.37.100.27的"/data“和“/app/soft/nginx/conf” 到本地 /data/backup
#F_BACKUP 10.37.100.27 "/data /app/soft/nginx/conf" /data/backup 

#备份本机的”/data“ 到本地 /data/backup
#F_BACKUP 127.0.0.1 /data /data/backup 

#F_BACKUP 10.37.100.32 /data /data/backup 

#F_BACKUP 10.40.100.42 /data /data/backup 

#F_BACKUP 10.40.100.47 /data /data/backup 
F_BACKUP 127.0.0.1 /data/mysql/data /data/backup 
	
