#!/bin/bash
#mysite:	http://qmjq.github.io 
#github:	http://github.com/qmjq
#blog:		http://qiaomiao.blog.51cto.com
#date: 20171212 v1.0
#author:QMJQ
#description: auto install nginx and keepalvied.

DATE=`date`
LOG=/dev/null
PWD=`pwd`
APPDIR=/app/soft
SRCDIR=$PWD


#	显示颜色。
function RED_COLOR () {
	echo -e "\033[31m $1 \033[0m"	
}
function GREEN_COLOR () {
	echo -e "\033[32m $1 \033[0m"	
}

#	 说明脚本要和nginx及keepalived目录同级，且nginx和keepalived 必须只有一个ngin-x.x.x.tar.gz 和keepalived-x.x.x.tar.gz


#	INSTALL_NGINX 安装nginx 及其第三方模块  ngx_devel_kit-master ngx_cache_purge lua-nginx-module-master naxsi-master 。
function INSTALL_NGINX ()  {
	NGINX=nginx
	NGINX_USER=$NGINX
	NGINX_SRCDIR=$SRCDIR/$NGINX
	NGINX_VERSION=$(cd $NGINX_SRCDIR && ls|grep -v ^LuaJIT|grep ^nginx-[0-9].[0-9]*.[0-9].tar.gz|awk -F ".tar" '{print $1}')
	ADD_MODULE=$(cd $NGINX_SRCDIR && ls|grep -Ev "^LuaJIT|$NGINX_VERSION.tar.gz")
	LUAJIT_VERSION=$(cd $NGINX_SRCDIR && ls|grep ^LuaJIT-[0-9].[0-9].[0-9].tar.gz|awk -F ".tar" '{print $1}')
    NGINX_APPDIR=$APPDIR/$NGINX_VERSION
	NGINX_LOGDIR=/data/nginx_logs

	GREEN_COLOR "$NGINX_USER $NGINX_SRCDIR $NGINX_VERSION $ADD_MODULE $LUAJIT_VERSION $NGINX_APPDIR $NGINX_LOGDIR" && sleep 3s
    
	yum -y install  vim lrzsz elinks links ntpdate lsof unzip bind-utils telnet rsync curl nmap sysstat xz p7zip       	\
			redhat-lsb-core  gcc-c++ make autoconf gcc
	yum -y install  ncurses-devel zlib-devel tcl-devel openssl-devel openssh-clients ncurses-devel libpcap-devel       	\
			pcre-devel gd-devel glibc-devel glib2-devel  bzip2-devel libwebp-devel lua-devel
	
	useradd -M -s /sbin/nologin $NGINX_USER 
	[ ! -z $NGINX_VERSION ] && rm -rf $NGINX_APPDIR $NGINX_SRCDIR/$NGINX_VERSION 
	mkdir -p $NGINX_APPDIR && cd $NGINX_APPDIR && cd ../  && rm -rf $NGINX ; ln -s $NGINX_VERSION $NGINX
	cd $NGINX_SRCDIR	
	tar -zxvf $LUAJIT_VERSION.tar.gz >/dev/null 2>&1 &&  cd $LUAJIT_VERSION && make && make install 				   	\
		&& echo "/usr/local/lib" > /etc/ld.so.conf.d/luajit.conf 						   	\
		&&  ldconfig   && cd .. && GREEN_COLOR "$DATE $LUAJIT_VERSION preinstall ok \n " |tee -a $LOG && sleep 3s	\
		|| RED_COLOR "$DATE $LUAJIT_VERSION preinstall Failed \n " |tee -a $LOG 
		
	tar -zxvf $NGINX_VERSION.tar.gz >/dev/null 2>&1
	for X  in  $ADD_MODULE ;do
		tar -zxvf $X  	2>/dev/null  && Y=$(echo $X|awk -F ".tar" '{print $1}') && mv $Y $NGINX_VERSION/src/ 
		unzip $X 	2>/dev/null  && Y=$(echo $X|awk -F ".zip" '{print $1}') && mv $Y $NGINX_VERSION/src/
	done
	cd $NGINX_SRCDIR/$NGINX_VERSION && ./configure --prefix=$NGINX_APPDIR --user=$NGINX_USER --group=$NGINX_USER		\
		--with-threads --with-file-aio --with-http_ssl_module --with-http_realip_module --with-http_v2_module		\
		--with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_gunzip_module		\
		--with-http_gzip_static_module --with-http_auth_request_module --with-http_secure_link_module			\
		--with-pcre --with-compat --with-stream     									\
		--with-stream_ssl_module --with-stream_realip_module                                                       	\
		--add-module=src/ngx_cache_purge-2.3 --add-module=src/ngx_devel_kit-master                                 	\
		--add-module=src/lua-nginx-module-master --add-module=src/naxsi-master/naxsi_src                           	\
		&& make && make install && GREEN_COLOR "$DATE $NGINX_VERSION install ok \n " |tee -a $LOG && sleep 3s  	        \
		|| RED_COLOR "$DATE $NGINX_VERSION install Failed \n " |tee -a $LOG 
		
	cp $NGINX_SRCDIR/$NGINX_VERSION/src/naxsi-master/naxsi_config/naxsi_core.rules $NGINX_APPDIR/conf/ -a 		  	\
		&& cd $NGINX_APPDIR && rm -rf logs $NGINX_LOGDIR && mkdir -p $NGINX_LOGDIR && ln -s $NGINX_LOGDIR logs	  	\
		&& chown -R $NGINX_USER:$NGINX_USER $NGINX_LOGDIR $NGINX_APPDIR $APPDIR/$NGINX
}

#	INSTALL_keepalived 安装keepalived 建议用 keepalived-1.3.5.tar.gz及以下版本，高版本对centos6可能不支持.
function INSTALL_KEEPALIVED () {
	KEEPALIVED=keepalived
	KEEPALIVED_USER=$KEEPALIVED
	KEEPALIVED_SRCDIR=$SRCDIR/$KEEPALIVED
	KEEPALIVED_VERSION=$(cd $KEEPALIVED_SRCDIR && ls|grep ^keepalived-[0-9].[0-9]*.[0-9].tar.gz|awk -F ".tar" '{print $1}')
	KEEPALIVED_APPDIR=$APPDIR/$KEEPALIVED_VERSION
	KEEPALIVED_LOGDIR=" "
	
	GREEN_COLOR "$KEEPALIVED_USER $KEEPALIVED_SRCDIR $KEEPALIVED_VERSION $KEEPALIVED_APPDIR $KEEPALIVED_LOGDIR" && sleep 3s
	
	yum -y install openssl-devel libnl-devel libnl3-devel ipset-devel iptables-devel libnfnetlink-devel net-snmp-devel glib2-devel json-c-devel
	
	useradd -M -s /sbin/nologin $KEEPALIVED_USER
	[ ! -z $KEEPALIVED_VERSION ] && rm -rf $KEEPALIVED_APPDIR $KEEPALIVED_SRCDIR/$KEEPALIVED_VERSION 
	mkdir -p $KEEPALIVED_APPDIR && cd $KEEPALIVED_APPDIR && cd ../  && rm -rf $KEEPALIVED ; ln -s $KEEPALIVED_VERSION $KEEPALIVED 
	cd $KEEPALIVED_SRCDIR
	tar -zxvf $KEEPALIVED_VERSION.tar.gz >/dev/null 2>&1
	cd $KEEPALIVED_SRCDIR/$KEEPALIVED_VERSION && ./configure  --prefix=$KEEPALIVED_APPDIR	\
	   --enable-snmp --enable-snmp-rfc --enable-dbus --enable-sha1 --enable-mem-check --enable-stacktrace  --enable-json \
	   make && make install && GREEN_COLOR "$DATE $KEEPALIVED_VERSION install ok \n " |tee -a $LOG && sleep 3s  	        \
		|| RED_COLOR "$DATE $KEEPALIVED_VERSION install Failed \n " |tee -a $LOG 
	
	chown -R $KEEPALIVED_USER:$KEEPALIVED_USER $KEEPALIVED_LOGDIR $KEEPALIVED_APPDIR $APPDIR/$KEEPALIVED

}




INSTALL_NGINX
INSTALL_KEEPALIVED

