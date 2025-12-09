#!/bin/bash 
echo "System Report" > system_report.txt 
echo "Generated on: $(date)" >> system_report.txt 
echo "" >> system_report.txt 
echo "Logged-in Users:" >> system_report.txt 
who >> system_report.txt 
echo "" >> system_report.txt 
echo "System Uptime:" >> system_report.txt 
uptime >> system_report.txt 
echo "System report generated: system_report.txt"

