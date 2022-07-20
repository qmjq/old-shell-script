#!/bin/bash
#date: 20220720 v2.0 20220720
#author:QMJQ 

function CHECK_JOB (){
	[ -z $1 ] && echo "请输入要发布的git仓库名" && exit 1 ;[ ! -z $1 ] && echo $1|grep -Ei "$JOBDICT" || echo "请输入要发布的git仓库名,正确仓库名" 
	[ ! -z $1 ] && echo $1|grep -Ei "$JOBDICT" || exit 1
}

function CHECKOUT_BRANCH (){
	[ -z $1 ] && echo "请输入要发布的分支" && exit 1
	git checkout -f $1 2>/dev/null && git pull &&  echo "成功切换到分支$1,拉取成功" ||echo "分支$1 切换失败,拉取失败" ; git checkout -f $1 2>/dev/null || exit 1
}

function  PNPM_RUN  (){
	source /etc/profile && pnpm install || exit 1 && pnpm run build  || exit 1 && mkdir -p $(dirname $(pwd))/front/$1 && rm -rf $(dirname $(pwd))/front/$1/dist && mv dist $(dirname $(pwd))/front/$1
} 

function NGINX_RUN () {
	DATE=$(date +%F-%H-%M) 
	WWWROOT="/www/wwwroot"
	NGINX=/data/nginx
	case "$1" in
		Packet_Shopman_Web_UI)
			rm -rf $WWWROOT/dj.gotofreight.com && cp -a $(dirname $(pwd))/front/$1/dist $WWWROOT/dj.gotofreight.com
		;;
		Packet_OutCustome_PC_UI)
			rm -rf $WWWROOT/u.gotofreight.com && cp -a $(dirname $(pwd))/front/$1/dist $WWWROOT/u.gotofreight.com
			rm -rf $WWWROOT/gtf.bsiecommerce.com && cp -a $(dirname $(pwd))/front/$1/dist $WWWROOT/gtf.bsiecommerce.com
		;;
		Packet_BSI_PC_UI)
			rm -rf $WWWROOT/tms.gotofreight.com && cp -a $(dirname $(pwd))/front/$1/dist $WWWROOT/tms.gotofreight.com
			rm -rf $WWWROOT/gtfbd.bsiecommerce.com && cp -a $(dirname $(pwd))/front/$1/dist $WWWROOT/gtfbd.bsiecommerce.com
		;;
		Packet_Label)
			rm -rf $WWWROOT/label.bsiecommerce.com && cp -a $(dirname $(pwd))/front/$1/dist $WWWROOT/label.bsiecommerce.com
		;;
	esac
	sudo chown -R yunwei:yunwei /www/wwwroot && sudo $NGINX/sbin/nginx -t && sudo $NGINX/sbin/nginx -s reload && echo "前端 $1 ok" || exit 1
}



function main (){
	JOB=$1
	BRANCH=$2
	JOBDICT="Packet_BSI_PC_UI$|Packet_Label$|Packet_OutCustome_PC_UI$|Packet_Shopman_Web_UI$"
        echo $JOB $BRANCH 
  	echo ------------	
	
	CHECK_JOB $JOB ;
	
	DIR=/data/uat
	#DIR=""
	#DIR=$(pwd) && echo $DIR | grep  \/data\/uat || echo "请切换到cd /data/uat目录,再执行脚本" ;echo $DIR | grep  \/data\/uat || exit 0
	#JOB=$(ls * -d|grep -Ei $JOB) 	
	#cd /data/uat/$JOB
	cd $DIR
	JOB=$(ls * -d|grep -Ei $JOB)
	mkdir -p $JOB && cd $JOB
  	
	CHECKOUT_BRANCH $BRANCH ; PNPM_RUN $JOB ; NGINX_RUN $JOB
	 
}

main $1 $2
