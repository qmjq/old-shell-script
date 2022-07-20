#!/bin/bash
#date: 20220719 v2.0 20220720
#author:QMJQ 

function CHECK_JOB (){
        [ -z $1 ] && echo "请输入要发布的git仓库名" && exit 1 ;[ ! -z $1 ] && echo $1|grep -Ei "$JOBDICT" || echo "请输入要发布的git仓库名,正确仓库名"
        [ ! -z $1 ] && echo $1|grep -Ei "$JOBDICT" || exit 1
}

function CHECKOUT_BRANCH (){
	[ -z $BRANCH ] && echo "请输入要发布的分支" && exit 1
	git checkout -f $1 2>/dev/null && git pull &&  echo "成功切换到分支$1,拉取成功" ||echo "分支$1 切换失败,拉取失败" ; git checkout -f $1 2>/dev/null || exit 1
}

function  DOTNET_RUN  (){
	SLN=$( ls |grep .sln)
	sudo dotnet restore $SLN -s http://192.168.80.56:5555/v3/index.json -s https://api.nuget.org/v3/index.json -s https://nuget.cnblogs.com/v3/index.json   &&  sudo dotnet build $SLN && sudo dotnet publish $SLN  -p:PublishDir=$(dirname $(pwd))/back/$1 || exit 1
} 

function DOCKER_RUN () {
	DATE=$(date +%F-%H-%M) 
	IMAGENAME=$1
	cd $(dirname $(pwd))/back/$1 && PORT=$(grep -i expose Dockerfile|awk '{print $2}') && sudo docker build -t ${IMAGENAME,,}:$DATE . || exit 1;
	sudo docker stop ${IMAGENAME,,} ; sudo docker rm  -f ${IMAGENAME,,} && sudo docker run -itd -p $PORT:$PORT --restart=always --name ${IMAGENAME,,} ${IMAGENAME,,}:$DATE && echo "后端 docker $IMAGENAME 部署ok" || exit 1
}



function main (){
	JOB=$1
	BRANCH=$2
	JOBDICT="SJZY.Package.Api$|SJZY.Package.Task.Api$|SJZY.Package.Output.Api$"
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
  	
	CHECKOUT_BRANCH $BRANCH ; DOTNET_RUN $JOB ; DOCKER_RUN $JOB
	 
}

main $1 $2
