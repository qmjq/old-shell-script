#!bin/bash
#git:https://github.com/QMJQ
#blog:http://www.opsxyz.com 
#     http://qiaomiao.blog.51cto.com
#date: 20181211 v2.0
#author:QMJQ
#description: inital openstack  env  and kernel arg

DATE=$(date +%Y%d%m_%H%M%S)
ROOT_PASS="Pw2018"
HOSTNAME="libravms_$DATE"

# set hostname timezone and password
  hostnamectl set-hostname  ${HOSTNAME}
  timedatectl set-timezone  Asia/Shanghai
  passwd root<<EOF
  ${ROOT_PASS}
  ${ROOT_PASS}
EOF
# set kernel args
echo "
	
# add by qmjq www.opsxyz.com

	 *       soft    nofile  65536 
 	 *       hard    nofile  65536 
	 *       soft    nproc   65536 
	 *       hard    nproc   65536 
	 *       soft    core    unlimited 
	 *       hard    core    unlimited  " >>  /etc/security/limits.conf
echo "  
# add by qmjq www.opsxyz.com 
	fs.file-max=655360           
	vm.max_map_count=655360
	net.core.somaxconn = 10240
	vm.overcommit_memory = 1  
# For more information, see sysctl.conf(5) and sysctl.d(5).
	    #net.ipv6.conf.all.disable_ipv6 = 1
	    #net.ipv6.conf.default.disable_ipv6 = 1
	    #net.ipv6.conf.lo.disable_ipv6 = 1
	    vm.swappiness = 10
	    net.ipv4.neigh.default.gc_stale_time=120

	    net.ipv4.conf.all.rp_filter=0
	    net.ipv4.conf.default.rp_filter=0
	    net.ipv4.conf.default.arp_announce = 2
	    net.ipv4.conf.lo.arp_announce=2
	    net.ipv4.conf.all.arp_announce=2

	    net.ipv4.tcp_max_tw_buckets = 5000
	    #net.ipv4.tcp_tw_reuse = 1    #Allow TIME-WAIT sockets to be reused for new TCP connections
	    net.ipv4.tcp_syncookies = 1
	    net.ipv4.tcp_max_syn_backlog = 10240
	    net.ipv4.tcp_synack_retries = 2
	    net.ipv4.tcp_syn_retries = 3
	    kernel.sysrq=1           " >>  /etc/sysctl.conf

sysctl -p && ulimit -a

# MongoDB 、Redis 、Oracle 、HDFS 
   echo "
   	# at MongoDB 、Redis 、Oracle 、HDFS uncomment 
   	#echo never >>  /sys/kernel/mm/transparent_hugepage/enabled 
   	#echo never >>  /sys/kernel/mm/transparent_hugepage/defrag  " >> /etc/rc.local
# modfied network service
   sed -i 's/HWADDR/#HWADDR/g' /etc/sysconfig/network-scripts/ifcfg-eth0 && systemctl restart network 

# modfied sshd service
   sed -i '65d' /etc/ssh/sshd_config && sed -i '64a PasswordAuthentication yes' /etc/ssh/sshd_config && systemctl restart sshd


# end

