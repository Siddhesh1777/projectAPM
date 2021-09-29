#!/bin/bash

start_processes () {
    # Store passed IP address in IP variable
    IP1=$1

        tar -xzvf mini_project1.tar.gz
        chmod 755 APM1 APM2 APM3 APM4 APM5 APM6
        
        ./APM1 $IP1 & PIDAPM1=$!
        ./APM2 $IP1 & PIDAPM2=$!
        ./APM3 $IP1 & PIDAPM3=$!
        ./APM4 $IP1 & PIDAPM4=$!
        ./APM5 $IP1 & PIDAPM5=$!
        ./APM6 $IP1 & PIDAPM6=$!
        ifstat -d 1 &
}

# Collects CPU and MEM usage 
collect_process_info () {
    pInfo1=$( ps aux | egrep "$PIDAPM1" | awk '{print $3 " " $4}' )
    pInfo2=$( ps aux | egrep "$PIDAPM2" | awk '{print $3 " " $4}' )
    pInfo3=$( ps aux | egrep "$PIDAPM3" | awk '{print $3 " " $4}' )
    pInfo4=$( ps aux | egrep "$PIDAPM4" | awk '{print $3 " " $4}' )
    pInfo5=$( ps aux | egrep "$PIDAPM5" | awk '{print $3 " " $4}' )
    pInfo6=$( ps aux | egrep "$PIDAPM6" | awk '{print $3 " " $4}' )
    echo "Hello $pInfo1"
    CPU1=$( echo $pInfo1 | cut -f 1 -d " " )
    MEM1=$( echo $pInfo1 | awk '{print $2}' )
    CPU2=$( echo $pInfo2 | awk '{print $1}' )
    MEM2=$( echo $pInfo2 | awk '{print $2}' )
    CPU3=$( echo $pInfo3 | awk '{print $1}' )
    MEM3=$( echo $pInfo3 | awk '{print $2}' )
    CPU4=$( echo $pInfo4 | awk '{print $1}' )
    MEM4=$( echo $pInfo4 | awk '{print $2}' )
    CPU5=$( echo $pInfo5 | awk '{print $1}' )
    MEM5=$( echo $pInfo5 | awk '{print $2}' )
    CPU6=$( echo $pInfo6 | awk '{print $1}' )
    MEM6=$( echo $pInfo6 | awk '{print $2}' )
    
    echo "HI $CPU1"

    process_info "APM1" $CPU1 $MEM1
    process_info "APM2" $CPU2 $MEM2
    process_info "APM3" $CPU3 $MEM3
    process_info "APM4" $CPU4 $MEM4
    process_info "APM5" $CPU5 $MEM5
    process_info "APM6" $CPU6 $MEM6

}

# Function to write to csv
process_info () {
    time=$SECONDS
    PROCESS=$1
    CPU=$2
    MEM=$3

    echo "$time, $CPU, $MEM" >> "$PROCESS"_metrics.csv
}

collect_system_level(){
    # find hard disk writes
    harddiskwrites=$(iostat sda | awk '{print $4}' | sed -n 7p)
    # hard disk utilization
    harddiskutilization=$(df -m / | awk '{print $3}' | sed -n 2p)

    rxrate=$(ifstat ens33 | awk '{print $7}' | sed -n 4p | sed s'/.$//')
    txrate=$(ifstat ens33 | awk '{print $9}' | sed -n 4p | sed s'/.$//')

    system_info $rxrate $txrate $harddiskwrites $harddiskutilization
}

# Write to CSV
system_info (){
    time=$SECONDS
    rx=$1
    tx=$2
    write=$3
    util=$4

    echo "$time, $rx, $tx, $write, $util" >> system_metrics.csv
}

# Run processes every 5 seconds
function collect_info () {
    while (true)
    do
        collect_process_info
        collect_system_level
        sleep 5
    done
}

#kill processes
cleanup () {
    killall $PIDAPM1
    killall $PIDAPM2
    killall $PIDAPM3
    killall $PIDAPM4
    killall $PIDAPM5
    killall $PIDAPM6
    killall ifstat
}
trap cleanup EXIT

# Check if IP is entered

if [ $# -lt 1 ]
then
    echo "Error"
else
    start_processes $1
    collect_info
fi

