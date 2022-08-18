#!/bin/bash
#git:https://github.com/QMJQ
#blog:http://qmjq.github.io 
#     http://qiaomiao.blog.51cto.com
#date: 20180419 v1.2
#author:QMJQ
#description: general install source software ,eg:*.tar.gz  

#全局变量		
DATE=$(date +%Y-%m-%d)			#日志时间
LOG=${0}.${DATE}.log			#日志
RUNDIR=`pwd`				#软件执行目录
DEPDIR=/app/soft			#部署目录
SRCDIR=" "				#源码目录

#清空日志
echo > $RUNDIR/$LOG 

#	显示颜色。
function RED_COLOR () {
	echo -e "\033[01;31m $1 \033[0m"	
}
function GREEN_COLOR () {
	echo -e "\033[01;32m $1 \033[0m"	
}

#	删除创建文件。
function F_RMFILE () {
	rm -rf $1
}
#	创建文件夹
function F_MKFILE () {
	if [ ! -d "$1" ];then
        	mkdir -p "$1" >/dev/null 2>&1;
	fi
}

#	yum软件安装
function F_YUM () {
	GREEN_COLOR "		yum 安装相关依赖包: $1 "|tee -a $RUNDIR/$LOG 
	yum repolist|grep epel >/dev/null || yum -y install epel-release >/dev/null 
	yum -y install vim lrzsz ntpdate lsof unzip ncurses-devel zlib-devel tcl-devel gcc gcc-c++ make automake autoconf openssl-devel bind-utils telnet  openssh-clients rsync curl nmap sysstat  libpcap ncurses ncurses-devel libpcap-devel xz p7zip pcre-devel gd-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel  redhat-lsb-core >/dev/null
	yum -y install $1 
}

#	建立用户
function F_CREATEUSER () {
	GREEN_COLOR "		建立相关用户: $1 "|tee -a $RUNDIR/$LOG 
	useradd -M -s /sbin/nologin $1 
}


#	解压源码包
function F_DECOMPRESS () {
	GREEN_COLOR "		解压源码包: $1 " |tee -a $RUNDIR/$LOG 
        [[ $1 ]] && TAR_NAME=$(ls * |grep $1|grep -Ei ".tar$"|awk -F ".tar" '{print $1}')
	[[ $1 ]] && TAR_GZ_NAME=$(ls * |grep $1|grep -Ei ".tar.gz$"|awk -F ".tar.gz" '{print $1}')
	[[ $1 ]] && TAR_BZ2_NAME=$(ls * |grep $1|grep -Ei ".tar.bz2$"|awk -F ".tar.bz2" '{print $1}')
	[[ $1 ]] && ZIP_NAME=$(ls * |grep $1|grep -Ei ".zip$"|awk -F ".zip" '{print $1}')
        [[ $TAR_NAME ]] && F_RMFILE "$TAR_NAME" && tar xvf ${TAR_NAME}.tar >/dev/null && SOFTWARENAME=$TAR_NAME
        [[ $TAR_GZ_NAME ]] && F_RMFILE "$TAR_GZ_NAME" && tar zxvf ${TAR_GZ_NAME}.tar.gz >/dev/null && SOFTWARENAME=$TAR_GZ_NAME
        [[ $TAR_BZ2_NAME ]] && F_RMFILE "$TAR_BZ2_NAME" && tar jxvf ${TAR_BZ2_NAME}.tar.bz2 >/dev/null && SOFTWARENAME=$TAR_BZ2_NAME 
        [[ $ZIP_NAME ]] && F_RMFILE "$ZIP_NAME" && tar jxvf ${ZIP_NAME}.ZIP > /dev/null && SOFTWARENAME=$ZIP_NAME
	 
}

#	编译执行前执行动作；如:调用其他命令或语言 python、shell、c、c++ 
function F_B_ACTION () {
	$1
}

#	编译安装后执行动作,如:调用其他命令或语言 python、shell、c、c++ 
function F_A_ACTION () {
	$1
}

#	编译安装
function F_COMPILE () {
	GREEN_COLOR "		编译安装: $2 "|tee -a $RUNDIR/$LOG && sleep 2s
        echo $1
        echo $2
 	echo $3
	if [ -e ./configure ] ; then
		#默认部署目录 和 确认软件安装目录 相同,带/不带 config编译参数
        	[[ $DEPDIR == $1 ]] && ./configure  --prefix=$DEPDIR/$SOFTWARENAME $3 && make && make install && GREEN_COLOR "$DATE $SOFTWARENAME is install ok"|tee -a $RUNDIR/$LOG 
        	
		#默认部署目录 和 确认软件安装目录 不相同,且确认目录为其他目录,带/不带 config编译参数
		[[ $DEPDIR != $1 ]] && [[ $1 ]]  && ./configure --prefix=$1/$SOFTWARENAME $3 && make && make install && GREEN_COLOR "$DATE $SOFTWARENAME is install ok"|tee -a $RUNDIR/$LOG 
		
		#默认部署目录 和 确认软件安装目录 不相同,且确认目录不存在,带/不带 config编译参数
        	[[ $DEPDIR != $1 ]] && [[ -z $1 ]] && ./configure $3  && make && make install && GREEN_COLOR "$DATE $SOFTWARENAME is install ok"|tee -a $RUNDIR/$LOG 
	fi
	if [ ! -e ./configure ] ; then    
		#默认部署目录 和 确认软件安装目录 相同,带/不带编译参数
		[[ $DEPDIR == $1 ]] && make $3 && make  PREFIX=$DEPDIR/$SOFTWARENAME install && GREEN_COLOR "$DATE $SOFTWARENAME is install ok"|tee -a $RUNDIR/$LOG 
		
		#默认部署目录 和 确认软件安装目录 不相同,且确认目录为其他目录,带/不带 编译参数
        	[[ $DEPDIR != $1 ]] && [[ $1 ]] && make $3  && make  PREFIX=$1/$SOFTWARENAME install && GREEN_COLOR "$DATE $SOFTWARENAME is install ok"|tee -a $RUNDIR/$LOG 
		
		#默认部署目录 和 确认软件安装目录 不相同,且确认目录不存在,带/不带 编译参数
        	[[ $DEPDIR != $1 ]] && [[ -z $1 ]] && make $3 && make  install  && GREEN_COLOR "$DATE $SOFTWARENAME is install ok"|tee -a $RUNDIR/$LOG 
        fi
}

#	主函数
function F_DEPLOY () {
	
	DATE=$(date +'%Y-%d-%m %T')		#开始时间
	
	#CONFIRMINSTALLDIR 	确认软件安装目录
	#SOFTKEY    		需安装软件关键字
	#YUMARG			yum安装参数
	#CONFARG		编译参数
	#BACTION		编译前动作
	#ACTIION 		编译后动作
	CONFIRMINSTALLDIR="$1" SOFTKEY="$2" CONFARG="$3" YUMARG="$4" BACTION="$5" AACTION="$6"
    GREEN_COLOR "$DATE 正在准备安装$SOFTKEY，5s以内。ctrl+c可以取消执行"|tee -a $RUNDIR/$LOG  && sleep 5s 
	echo $CONFIRMINSTALLDIR 
	echo $SOFTKEY 
	echo $CONFARG 
	echo $YUMARG
	echo $BACTION
	echo $AACTION

	cd $RUNDIR
	
	F_YUM "$YUMARG"

	F_CREATEUSER "$SOFTKEY"
	
	F_DECOMPRESS "$SOFTKEY"

	[[ $CONFIRMINSTALLDIR ]] && cd $CONFIRMINSTALLDIR && F_RMFILE "$SOFTWARENAME" && F_MKFILE $SOFTWARENAME && F_RMFILE "$SOFTKEY" ; cd $RUNDIR/$SOFTWARENAME
	
	F_B_ACTION "$BACTION"
	F_COMPILE "$CONFIRMINSTALLDIR" "$SOFTKEY" "$CONFARG"
        F_A_ACTION "$AACTION"

	ln -s  $CONFIRMINSTALLDIR/$SOFTWARENAME $CONFIRMINSTALLDIR/$SOFTKEY 				#增加软链接
        chown -R $SOFTKEY:$SOFTKEY $CONFIRMINSTALLDIR/$SOFTWARENAME  $CONFIRMINSTALLDIR/$SOFTKEY	#修改安装目录为相关软件用户
}

#范例：
#安装	nginx
#F_DEPLOY "/app/soft" "nginx" "--user=nginx --group=nginx --with-threads --with-file-aio --with-http_ssl_module --with-http_realip_module --with-http_v2_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_secure_link_module --with-pcre --with-compat --with-stream" "libnl-devel libnl3-devel libnfnetlink-devel"
#安装	keepalived
#F_DEPLOY "/app/soft" "keepalived" "--enable-snmp --enable-snmp-rfc --enable-dbus --enable-sha1 --enable-mem-check --enable-stacktrace  --enable-json" "openssl-devel libnl-devel libnl3-devel ipset-devel iptables-devel libnfnetlink-devel net-snmp-devel glib2-devel json-c-devel" 

#安装	glusterfs
#F_DEPLOY "/app/soft" "glusterfs" "--disable-tiering" "libtool flex bison openssl-devel libxml2-devel python-devel libaio-devel libibverbs-devel librdmacm-devel readline-devel lvm2-devel glib2-devel userspace-rcu-devel libcmocka-devel libacl-devel fuse-devel" "./autogen.sh" 

#安装	redis
#F_DEPLOY "/app/soft" "redis"   

#安装	erlang
#F_DEPLOY "/app/soft" "otp_src"  "" "" "./otp_build autoconf" 

#安装	haproxy
#F_DEPLOY "/app/soft" "haproxy" "TARGET=linux2628"







