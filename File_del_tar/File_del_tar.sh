#!/bin/bash
#blog:http://qiaomiao.blog.51cto.com
#date: 20190116 v1.0
#author:QMJQ
#description:  Delete files from some days ago,tar compress files from some days ago

#	全局变量
DATE=$(date)
PWD=$(pwd)
LOG=/dev/null
DIR_PATH=/data/logs

#	删除自定义天数文件
function F_DEL_FILE () {
	DIR_PATH=$1 FILE_KEYNAME=$2 DAYS_AGO=$3
	TAR_NAME=$(basename $DIR_PATH)
	echo ..............
	echo $DIR_PATH $FILE_KEYNAME $DAYS_AGO 
	[ -z $FILE_KEYNAME ] && find $DIR_PATH -mindepth 2 -mtime +$DAYS_AGO -exec rm -rf {} \;  || find $DIR_PATH -mindepth 2 -mtime +$DAYS_AGO -name $FILE_KEYNAME -exec rm -f {} \;
	find $DIR_PATH -mindepth 1 -mtime +$DAYS_AGO -name $TAR_NAME*.tar.gz -exec rm -f {} \;
}

#	tar归档前一天的文件		
function F_TAR_FILE () {
	DIR_PATH=$1
	TAR_NAME=$(basename $DIR_PATH)
	#tar czvf $TAR_NAME.$(date --date="-1 day" +%Y%m%d).tar.gz $(find $DIR_PATH -mindepth 2 -mtime -2 -mtime +0 ) && find $DIR_PATH -mindepth 2 -mtime -2 -mtime +0 -exec rm -rf {} \;
	#	二选一
	#	tar 归档成功 就删除原文件
	#tar czvf $TAR_NAME.$(date --date="-1 day" +%Y%m%d).tar.gz $(find -mindepth 2 -mtime 1 ) && find -mindepth 2 -mtime 1 -exec rm -rf {} \;
	#	tar 归档成功与否 都删除原文件
	tar czvf $TAR_NAME.$(date --date="-1 day" +%Y%m%d).tar.gz $(find -mindepth 2 -mtime 0 ) ; find -mindepth 2 -mtime 0 -exec rm -rf {} \;
}

#	主程序
function F_NEED_FIND_DIR () {
	DIR_PATH=$1 FILE_KEYNAME=$2 DAYS_AGO=$3
	for i in $(echo $1) ;do
		{
		echo "...cd $i.."
		cd $i
		[ -z $FILE_KEYNAME ] &&  F_DEL_FILE $i "" $DAYS_AGO ||  F_DEL_FILE $i $FILE_KEYNAME $DAYS_AGO
		F_TAR_FILE $i
		}& 
		# {}把循环体括起来，后面加&符号，表示每次循环都把命令放入后台运行，一旦放入后台，意味着{}里面的命令交给了操作系统的一个线程处理，实现shell多线程
	done
	wait	#等待（wait命令）上面的命令（放入后台的）都执行完毕了再往下执行 
}

#范例

# 	删除/data/logs/td-charge目录下 第4天以前文件，并tar归档前一天文件
F_NEED_FIND_DIR "/data/logs/td-charge" "" "3" 

# 	删除/data/logs/td-zuul 和 /data/logs/td-cube 两目录下 第7天以前的文件，并tar归档前一天文件
F_NEED_FIND_DIR "/data/logs/td-third /data/logs/td-cube" "" "6" 

# 	删除/data/logs/td-charge 和 /data/logs/td-client 两目录下 第7天以前且文件名匹配1800的文件，并tar归档前一天文件
F_NEED_FIND_DIR "/data/logs/td-admin /data/logs/td-client" "*1800*" "6" 
