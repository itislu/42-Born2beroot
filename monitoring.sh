#!/bin/bash

# ARCHITECTURE
architecture=$(uname --all)

# CPU CORES
physical_cpu=$(grep 'core id' /proc/cpuinfo | sort --unique | wc --lines)
virtual_cpu=$(grep 'processor' /proc/cpuinfo | sort --unique | wc --lines)

# MEMORY
memory_used=$(free --mega | awk 'NR==2 {print $3}')
memory_total=$(free --mega | awk 'NR==2 {print $2}')
memory_usage=$(printf "%.2f" "$(echo "scale=4; $memory_used / $memory_total * 100" | bc)")

# DISK
disk_used=$(df --block-size=M | grep "/dev/" | grep --invert-match "/boot" | awk '{disk_u += $3} END {print disk_u}')
disk_total=$(df --block-size=M | grep "/dev/" | grep --invert-match "/boot" | awk '{disk_t += $2} END {printf ("%.1f"), disk_t / 1024}')
disk_usage=$(df --block-size=M | grep "/dev/" | grep --invert-match "/boot" | awk '{disk_u += $3} {disk_t+= $2} END {printf("%.0f"), disk_u / disk_t * 100}')

# CPU LOAD
cpu_idle=$(mpstat | tail -1 | awk '{printf $13}')
cpu_load=$(printf "%.1f" "$(echo "100 - $cpu_idle" | bc)")

# LAST BOOT
last_boot=$(who --boot | awk '{print $(NF-1), $NF}')

# LVM USE
lvm_status=$(if [ $(lsblk | grep "lvm" | wc --lines) > 0 ]; then echo yes; else echo no; fi)

# TCP CONNECTIONS
connections_tcp=$(ss --tcp --all | grep ESTAB | wc --lines)

# USERS
user_count=$(who | awk '{print $1}' | sort --unique | wc --lines)

# NETWORK
ipv4_address=$(hostname --all-ip-addresses | awk '{print $1}')
mac_address=$(ip link | grep "link/ether" | awk 'NR==1 {print $2}')

# SUDO
sudo_commands=$(journalctl --quiet _COMM=sudo | grep COMMAND | wc --lines)

# Display the information
wall "	#Architecture: $architecture
		#CPU physical: $physical_cpu
		#vCPU: $virtual_cpu
		#Memory Usage: $memory_used/${memory_total}MB ($memory_usage%)
		#Disk Usage: ${disk_used}MB/${disk_total}GB ($disk_usage%)
		#CPU load: $cpu_load%
		#Last boot: $last_boot
		#LVM use: $lvm_status
		#Connections TCP: $connections_tcp ESTABLISHED
		#User log: $user_count
		#Network: IP $ipv4_address ($mac_address)
		#Sudo: $sudo_commands cmd"

