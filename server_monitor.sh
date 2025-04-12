#!/bin/bash

#################################################
# Simple Server Monitoring System with Telegram
# Author: Oleksandr Ovdiienko
#################################################


CONFIG_FILE="server_monitor.conf"
LOG_FILE="server_monitor.log"

TELEGRAM_TOKEN="INPUT_YOUR_TOKEN"  # Replace with your bot token
TELEGRAM_CHAT_ID="INPUT_YOUR_BOT_ID"  # Replace with your bot ID


DEFAULT_CPU_THRESHOLD=80
DEFAULT_MEMORY_THRESHOLD=80
DEFAULT_DISK_THRESHOLD=90


timestamp() {
    date "+%Y-%m-%d %H:%M:%S"
}


log() {
    echo "$(timestamp) - $1" | tee -a "$LOG_FILE"
}


send_telegram() {
    message="$1"
    
    
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML"
    
    log "Telegram notification sent"
}


load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        log "Loading configuration from $CONFIG_FILE"
        source "$CONFIG_FILE"
    else
        log "No configuration file found. Using default values."
        CPU_THRESHOLD=$DEFAULT_CPU_THRESHOLD
        MEMORY_THRESHOLD=$DEFAULT_MEMORY_THRESHOLD
        DISK_THRESHOLD=$DEFAULT_DISK_THRESHOLD
        
        
        cat > "$CONFIG_FILE" << EOF
# Server Monitor Configuration
CPU_THRESHOLD=$DEFAULT_CPU_THRESHOLD
MEMORY_THRESHOLD=$DEFAULT_MEMORY_THRESHOLD
DISK_THRESHOLD=$DEFAULT_DISK_THRESHOLD
EOF
        log "Created sample configuration file $CONFIG_FILE"
    fi
}


check_cpu() {
   
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100.0-$8}')
    
    echo "$cpu_usage"
}


check_memory() {
    memory_usage=$(free | grep Mem | awk '{print int($3/$2 * 100)}')
    echo "$memory_usage"
}


check_disk() {
    disk_usage=$(df -h / | grep / | awk '{print int($5)}')
    echo "$disk_usage"
}


generate_report() {
    cpu=$(check_cpu)
    memory=$(check_memory)
    disk=$(check_disk)
    
    
    report="<b>📊 SERVER MONITORING REPORT</b>
<i>Time: $(timestamp)</i>
<i>Hostname: $(hostname)</i>
<i>Uptime: $(uptime -p)</i>

<b>SYSTEM RESOURCES:</b>
• CPU Usage: <b>${cpu}%</b> (Threshold: ${CPU_THRESHOLD}%)
• Memory Usage: <b>${memory}%</b> (Threshold: ${MEMORY_THRESHOLD}%)
• Disk Usage: <b>${disk}%</b> (Threshold: ${DISK_THRESHOLD}%)

<b>TOP PROCESSES:</b>
$(ps aux --sort=-%cpu | head -4 | awk '{print "• " $11 " (CPU: " $3 "%, MEM: " $4 "%)" }')
"
    
    
    report_file="server_report_$(date +%Y%m%d_%H%M%S).txt"
   echo -e "${report//</}" > "$report_file"  
    
    log "Report generated: $report_file"
    
    
    send_telegram "$report"
    
   
    echo "$report_file"
}


check_thresholds() {
    cpu=$(check_cpu)
    memory=$(check_memory)
    disk=$(check_disk)
    
    alerts=0
    alert_message="<b>⚠️ ALERT: System resource threshold exceeded on $(hostname)</b>\n\n"
    
    
    cpu_int=${cpu%.*}
    
    if [ "$cpu_int" -gt "${CPU_THRESHOLD:-80}" ]; then
        alert_message+="• CPU usage is critical: <b>${cpu}%</b> (threshold: ${CPU_THRESHOLD}%)\n"
        log "WARNING: High CPU usage: ${cpu}%"
        ((alerts++))
    fi
    
    if [ "$memory" -gt "${MEMORY_THRESHOLD:-80}" ]; then
        alert_message+="• Memory usage is critical: <b>${memory}%</b> (threshold: ${MEMORY_THRESHOLD}%)\n"
        log "WARNING: High memory usage: ${memory}%"
        ((alerts++))
    fi
    
    if [ "$disk" -gt "${DISK_THRESHOLD:-90}" ]; then
        alert_message+="• Disk usage is critical: <b>${disk}%</b> (threshold: ${DISK_THRESHOLD}%)\n"
        log "WARNING: High disk usage: ${disk}%"
        ((alerts++))
    fi
    
    if (( alerts > 0 )); then
        
        send_telegram "$alert_message"
    else
        log "All metrics within normal parameters."
    fi
}


main() {
    log "Starting server monitoring..."
    
    
    load_config
    
   
    generate_report
    
    
    check_thresholds
    
    log "Monitoring completed."
}


main
