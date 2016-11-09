#!/usr/bin/env bash

SERVICE_STATUS_OK=0
SERVICE_STATUS_ERROR=1
SERVICE_STATUS_INFO=2
SERVICE_STATUS_WARNING=3
SERVICE_STATUS_AVG=4
SERVICE_STATUS_HIGH=5
SERVICE_STATUS_DISASTER=6

check_swift_service_status_with_swift_init(){

    if ((`swift-init $1 status | grep -c "No"` >= 1)); then
        echo $SERVICE_STATUS_ERROR
    else
        echo $SERVICE_STATUS_OK
    fi
}

check_swift_service_status(){
    service_flag=`service $1 status > /dev/null 2>&1; echo $?`
   echo $> $service_flag
    if [ "$service_flag" == "0" ]; then
        check_swift_service_status_with_swift_init $2
    else
        echo "-1"
    fi

}


check_disk_status(){
    mounted_or_not=`swift-recon -u | grep -c 'Not mounted'`
    umounted_disks=`swift-recon -u | grep 'Not mounted'|awk '{print $3}'`
}

check_disk_stat(){
    check_disk_status
    if [ $mounted_or_not -le 0 ] ; then 
          echo '0'
    else
         echo $mounted_or_not
    fi
}

output_disk_umounted_list(){
    check_disk_status
    if [ $mounted_or_not -le 0 ] ; then 
          echo 'NOMAL'
    else
         echo $umounted_disks
    fi
}

update_old(){
   local old_time=`swift-recon -r | grep -E 'O'|awk '{print $4 OFS $5}'`
   local old_ip=`swift-recon -r | grep -E 'O'|awk '{print $10}'`

   echo "$old_ip $old_time"
}

update_recent(){
   local recent_time=`swift-recon -r | grep -E 'M'|awk '{print $5 OFS $6}'`
   local recent_ip=`swift-recon -r | grep -E 'M'|awk '{print $11}'`

   echo "$recent_ip $recent_time"
}


total_disk_write(){
    sp=`iostat |grep 'sd'|awk '{sum+=$4} END {print sum}'`
    echo $sp
}

total_disk_read(){
    sp=`iostat |grep 'sd'|awk '{sum+=$3} END {print sum}'`
    echo $sp
}

cluster_total_disk_capacity(){
    ctdc=`swift-recon -d | grep "Disk usage: space used" | awk '{ print $7 }'`
    echo $ctdc
}

cluster_total_disk_usage(){
    ctdu=`swift-recon -d | grep "Disk usage: space used" | awk '{ print $5 }'`
    echo $ctdu
}

cluster_total_disk_free(){
    ctdf=`swift-recon -d | grep "Disk usage: space free" | awk '{ print $5 }'`
    echo $ctdf
}
cluster_total_disk_percentage(){
    ctdp=`swift-recon -d | grep "Disk usage: lowest" | awk '{ print $8 }' | awk -F'%' '{ print $1 }'`
    echo $ctdp
}

node_CPU_pusage(){
    ncp=`zabbix_get -s 127.0.0.1 -k system.cpu.util[,idle]`
    #"options; expression" | bc
     echo "100 - $ncp" | bc
}


$1 $2 $3 $4 $5 $6 $7 $8




