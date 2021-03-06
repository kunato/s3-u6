#!/sbin/busybox sh
# Logging
/sbin/busybox cp /data/user.log /data/user.log.bak
/sbin/busybox rm /data/user.log
exec >>/data/user.log
exec 2>&1

echo $(date) START of post-init.sh

# Remount rootfs rw
  #/sbin/busybox mount rootfs -o remount,rw

##### Early-init phase #####

# Android Logger enable tweak
if /sbin/busybox [ "`/sbin/busybox grep ANDROIDLOGGER /system/etc/tweaks.conf`" ]; then
  insmod /lib/modules/logger.ko
fi

# IPv6 privacy tweak
#if /sbin/busybox [ "`/sbin/busybox grep IPV6PRIVACY /system/etc/tweaks.conf`" ]; then
  echo "2" > /proc/sys/net/ipv6/conf/all/use_tempaddr
#fi

# Enable CIFS tweak
#if /sbin/busybox [ "`/sbin/busybox grep CIFS /system/etc/tweaks.conf`" ]; then
#  /sbin/busybox insmod /lib/modules/cifs.ko
#else
#  /sbin/busybox rm /lib/modules/cifs.ko
#fi

# Remount all partitions with noatime
  for k in $(/sbin/busybox mount | /sbin/busybox grep relatime | /sbin/busybox cut -d " " -f3)
  do
        sync
        /sbin/busybox mount -o remount,noatime $k
  done

# Remount ext4 partitions with optimizations
  for k in $(/sbin/busybox mount | /sbin/busybox grep ext4 | /sbin/busybox cut -d " " -f3)
  do
        sync
        /sbin/busybox mount -o remount,commit=15 $k
  done

# boeffla tweak

# file system tweaks
  /sbin/busybox sysctl -w fs.inotify.max_queued_events=32000
  /sbin/busybox sysctl -w fs.file-max=524288
  /sbin/busybox sysctl -w fs.inotify.max_user_instances=256
  /sbin/busybox sysctl -w fs.inotify.max_user_watches=10240
  /sbin/busybox sysctl -w fs.lease-break-time=10

# kernel setting tweaks
  /sbin/busybox sysctl -w kernel.msgmax=65536
  /sbin/busybox sysctl -w kernel.msgmni=2048
  /sbin/busybox sysctl -w kernel.panic=10
  /sbin/busybox sysctl -w kernel.random.read_wakeup_threshold=128
  /sbin/busybox sysctl -w kernel.random.write_wakeup_threshold=256
  /sbin/busybox sysctl -w kernel.sched_latency_ns=18000000
  /sbin/busybox sysctl -w kernel.sched_wakeup_granularity_ns=3000000
  /sbin/busybox sysctl -w kernel.sched_min_granularity_ns=1500000
  /sbin/busybox sysctl -w kernel.sem='500 512000 64 2048'
  /sbin/busybox sysctl -w kernel.shmmax=268435456
  /sbin/busybox sysctl -w kernel.threads-max=524288

# Miscellaneous tweaks
  echo "12288" > /proc/sys/vm/min_free_kbytes
  echo "1500" > /proc/sys/vm/dirty_writeback_centisecs
  echo "200" > /proc/sys/vm/dirty_expire_centisecs
  echo "0" > /proc/sys/vm/swappiness

# CFS scheduler tweaks
  echo HRTICK > /sys/kernel/debug/sched_features

# Pegasus CPU hotplug tweaks
  echo "500000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_1_1
  echo "800000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_1
  echo "800000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_3_1
  echo "400000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_2_0
  echo "600000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_3_0
  echo "600000" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_freq_4_0

  echo "100" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_1_1
  echo "100" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_0
  echo "200" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_2_1
  echo "200" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_3_0
  echo "300" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_3_1
  echo "300" > /sys/devices/system/cpu/cpufreq/pegasusq/hotplug_rq_4_0

  echo "10" > /sys/devices/system/cpu/cpufreq/pegasusq/cpu_down_rate

# Tweak cfq io scheduler
#  for i in $(/sbin/busybox find /sys/block/mmc*)
#  do echo "0" > $i/queue/rotational
#    echo "0" > $i/queue/iostats
#    echo "8" > $i/queue/iosched/quantum
#    echo "4" > $i/queue/iosched/slice_async_rq
#    echo "1" > $i/queue/iosched/low_latency
#    echo "0" > $i/queue/iosched/slice_idle
#    echo "1" > $i/queue/iosched/back_seek_penalty
#    echo "1000000000" > $i/queue/iosched/back_seek_max
#  done

# SD cards (mmcblk) read ahead tweaks
  echo "256" > /sys/block/mmcblk0/bdi/read_ahead_kb
  echo "256" > /sys/block/mmcblk1/bdi/read_ahead_kb

# TCP tweaks
  echo "2" > /proc/sys/net/ipv4/tcp_syn_retries
  echo "2" > /proc/sys/net/ipv4/tcp_synack_retries
  echo "10" > /proc/sys/net/ipv4/tcp_fin_timeout
  

# SCHED_MC power savings level
  #echo "1" > /sys/devices/system/cpu/sched_mc_power_savings

# Turn off debugging for certain modules
  echo "0" > /sys/module/wakelock/parameters/debug_mask
  echo "0" > /sys/module/userwakelock/parameters/debug_mask
  echo "0" > /sys/module/earlysuspend/parameters/debug_mask
  echo "0" > /sys/module/alarm/parameters/debug_mask
  echo "0" > /sys/module/alarm_dev/parameters/debug_mask
  echo "0" > /sys/module/binder/parameters/debug_mask

  echo "0" > /sys/module/lowmemorykiller/parameters/debug_level
  echo "0" > /sys/module/mali/parameters/mali_debug_level
  echo "0" > /sys/module/ump/parameters/ump_debug_level

#vmtweak
  echo "110" > /proc/sys/vm/vfs_cache_pressure
  echo "40" > /proc/sys/vm/dirty_ratio
  echo "20" > /proc/sys/vm/dirty_background_ratio

##### Install SU #####

# Check for auto-root bypass config file

if [ -f /system/.noautoroot ] || [ -f /data/.noautoroot ];
then
	echo "File .noautoroot found. Auto-root will be bypassed."
else
# Start of auto-root section
if [ -f /system/xbin/su ] || [ -f /system/bin/su ];
then
	echo "su already exists"
else
	echo "Copying su binary"
	/sbin/busybox mount /system -o remount,rw
	/sbin/busybox rm /system/bin/su
	/sbin/busybox rm /system/xbin/su
	/sbin/busybox cp /res/misc/su /system/xbin/su
	/sbin/busybox chown 0.0 /system/xbin/su
	/sbin/busybox chmod 6755 /system/xbin/su
	/sbin/busybox mount /system -o remount,ro
fi

if [ -f /system/app/Superuser.apk ] || [ -f /data/app/Superuser.apk ];
then
	echo "Superuser.apk already exists"
else
	echo "Copying Superuser.apk"
	/sbin/busybox mount /system -o remount,rw
	/sbin/busybox rm /system/app/Superuser.apk
	/sbin/busybox rm /data/app/Superuser.apk
	/sbin/busybox cp /res/misc/Superuser.apk /system/app/Superuser.apk
	/sbin/busybox chown 0.0 /system/app/Superuser.apk
	/sbin/busybox chmod 644 /system/app/Superuser.apk
	/sbin/busybox mount /system -o remount,ro
fi
# End of auto-root section
fi

echo $(date) PRE-INIT DONE of post-init.sh
##### Post-init phase #####
sleep 12

# Cleanup busybox
  #/sbin/busybox rm /sbin/busybox
  #/sbin/busybox mount rootfs -o remount,ro

# init.d support
echo $(date) USER EARLY INIT START from /system/etc/init.d
if cd /system/etc/init.d >/dev/null 2>&1 ; then
    for file in E* ; do
        if ! cat "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER EARLY INIT DONE from /system/etc/init.d

echo $(date) USER EARLY INIT START from /data/init.d
if cd /data/init.d >/dev/null 2>&1 ; then
    for file in E* ; do
        if ! cat "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER EARLY INIT DONE from /data/init.d

echo $(date) USER INIT START from /system/etc/init.d
if cd /system/etc/init.d >/dev/null 2>&1 ; then
    for file in * ; do
        if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER INIT DONE from /system/etc/init.d

echo $(date) USER INIT START from /data/init.d
if cd /data/init.d >/dev/null 2>&1 ; then
    for file in * ; do
        if ! ls "$file" >/dev/null 2>&1 ; then continue ; fi
        echo "START '$file'"
        /system/bin/sh "$file"
        echo "EXIT '$file' ($?)"
    done
fi
echo $(date) USER INIT DONE from /data/init.d

echo $(date) END of post-init.sh
