#!/usr/bin/env bash

# Carico il file di configurazione
CONFIG_FILE="/etc/alerting/config.conf"
source "$CONFIG_FILE"

# Variabili
HOST="${HOSTNAME_LABEL:-local}" # Se HOSTNAME_LABEL non è definito, usa "local"
NOW="$(date '+%Y-%m-%d %H:%M:%S')" # Timestamp formattato

# --- DISK ---
DISK_USAGE=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
[[ -z "$DISK_USAGE" ]] && DISK_USAGE=0

# --- LOAD ---
LOAD_AVG=$(uptime | awk -F'load average: ' '{print $2}' | cut -d',' -f1 | xargs)
[[ -z "$LOAD_AVG" ]] && LOAD_AVG="0.00"

# --- SERVICES (mock via pgrep) ---
SERVICES_SERIALIZED=""

for service in $MONITORED_SERVICES; do
  if pgrep "$service" >/dev/null; then
    status="ACTIVE"
  else
    status="DOWN"
  fi

  SERVICES_SERIALIZED+="${service}:${status},"
done

SERVICES_SERIALIZED="${SERVICES_SERIALIZED%,}"

# --- STATUS ---
OVERALL_STATUS="OK"

if (( DISK_USAGE >= DISK_USAGE_THRESHOLD )); then
  OVERALL_STATUS="CRITICAL"
fi

awk -v c="$LOAD_AVG" -v t="$LOAD_AVERAGE_THRESHOLD" 'BEGIN {exit !(c>=t)}'
if [[ $? -eq 0 && "$OVERALL_STATUS" == "OK" ]]; then
  OVERALL_STATUS="WARNING"
fi

# --- WRITE FILE ---
cat > /opt/alerting/variables.data <<EOF
HOST=$HOST
TIMESTAMP=$NOW
OVERALL_STATUS=$OVERALL_STATUS

DISK_USAGE=$DISK_USAGE
DISK_THRESHOLD=$DISK_USAGE_THRESHOLD

LOAD_AVG=$LOAD_AVG
LOAD_THRESHOLD=$LOAD_AVERAGE_THRESHOLD

SERVICES_STATUS=$SERVICES_SERIALIZED
EOF