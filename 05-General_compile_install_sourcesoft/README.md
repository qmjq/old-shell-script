# General_compile_install_sourcesoft
general install source software

可以用于安装各种常用源码包软件 ,eg : *.tar.gz , *.tar ,*.tar.bz2 

使用方法：

    1、复制要安装的源码软件包到脚本同级目录。
    2、编辑General_compile_install_sourcesoft.sh，添加要安装的软件
    格式为：F_DEPLOY "确认软件安装目录" "安装的软件关键字" "编译参数" "yum依赖包参数" "编译前动作" "编译后动作" 。
    如安装nginx 
    F_DEPLOY "/app/soft" "nginx" "--user=nginx --group=nginx --with-threads --with-file-aio --with-http_ssl_module --with-http_realip_module --with-http_v2_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_secure_link_module --with-pcre --with-compat --with-stream" "libnl-devel libnl3-devel libnfnetlink-devel"
    如安装有些参数不需要用 "" 表示
    F_DEPLOY "" "nginx" "--user=nginx --group=nginx --with-threads --with-file-aio --with-http_ssl_module --with-http_realip_module --with-http_v2_module --with-http_image_filter_module --with-http_sub_module --with-http_dav_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_auth_request_module --with-http_secure_link_module --with-pcre --with-compat --with-stream" "libnl-devel libnl3-devel libnfnetlink-devel"
    3、保存文件执行。

脚本逻辑：
    
      进入脚本目录---提取"安装的软件关键字"找到相应软件---删除上次解压目录-解压软件---通过"安装的软件关键字"和"确认软件安装目录"和"部署目录"找到软件安装目录
    ---删除上次软件安装目录---执行编译前动作---执行编译安装---执行编译后动作---修改安装软件权限
 
