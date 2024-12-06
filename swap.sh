#!/bin/bash
 
if [ -z "$1" ]; then
    echo "Usage: $0 vuser.txt"
    exit 1
fi
 
server_list=$1
 
if [ ! -f "$server_list" ]; then
    echo "File $server_list not found!"
    exit 1
fi
 
print_table() {
    printf "%-10s %-20s %-10s %-10s %-s\n" "PID" "USER" "SWAP(GB/MB)" "COMMAND"
    printf "%-10s %-20s %-10s %-10s %-s\n" "--------" "--------------------" "--------" "-------------------------"
}
 
for server_name in $(cat "$server_list"); do
    echo "---------------------------------------------"
    echo "Checking swap utilization on $server_name"
    echo "---------------------------------------------"
    
    ssh -q "$server_name" '
        print_table() {
            printf "%-10s %-20s %-10s %-10s %-s\n" "PID" "USER" "SWAP(GB/MB)" "COMMAND"
            printf "%-10s %-20s %-10s %-10s %-s\n" "--------" "--------------------" "--------" "-------------------------"
        }
        print_table
        for pid in $(ps -e -o pid --no-headers); do
            swap=$(grep -H Swap /proc/$pid/smaps 2>/dev/null | awk "{sum+=\$2} END {print sum}")
            if [[ $swap -gt 0 ]]; then
                pname=$(ps -p $pid -o comm --no-headers)
                user=$(ps -p $pid -o user --no-headers)
                cmd=$(ps -p $pid -o args --no-headers)
                echo "$swap $pid $user $cmd"
            fi
        done | sort -nrk1 | head -5 | while read swap pid user cmd; do
            if [[ $swap -ge 1048576 ]]; then
                swap_in_gb=$(bc <<< "scale=2; $swap/1048576")
                printf "%-10s %-20s %-10s %-10s %-s\n" "$pid" "$user" "${swap_in_gb}GB" "$cmd"
            else
                swap_in_mb=$(bc <<< "scale=2; $swap/1024")
                printf "%-10s %-20s %-10s %-10s %-s\n" "$pid" "$user" "${swap_in_mb}MB" "$cmd"
            fi
        done
    '
    
done
