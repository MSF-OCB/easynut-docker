#!/bin/bash
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
echo never > /sys/kernel/mm/transparent_hugepage/enabled
sed -i -e '$i \echo never > /sys/kernel/mm/transparent_hugepage/enabled\n' rc.local
