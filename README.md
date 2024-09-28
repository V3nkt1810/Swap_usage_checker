#Swap Utilization Monitoring Script

This Bash script is designed to monitor the swap memory usage of multiple servers remotely using SSH. It reads a list of servers from a text file, connects to each server, and identifies the top 5 processes consuming the most swap memory. The output is formatted in a table with columns for PID, USER, SWAP(GB/MB), and COMMAND.

Features:

Reads server hostnames from a text file.
Connects to each server via SSH and retrieves swap memory utilization per process.
Displays the top 5 swap-consuming processes in a formatted table.
Automatically converts swap usage into GB or MB for easy readability.
Handles errors like missing input files and invalid PIDs.
