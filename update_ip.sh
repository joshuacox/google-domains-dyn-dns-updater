#!/bin/bash
### Update Google Domains DNS "Synthetic record"
### Google Dynamic DNS: https://support.google.com/domains/answer/6147083
### Synthetic Records: https://support.google.com/domains/answer/6069273
set -eu

config_checker () {
  # check if configs exist
  # if so source them
  CONFIG_TO_CHECK=$1
  if [ -f "$CONFIG_TO_CHECK" ]; then
    . "$CONFIG_TO_CHECK"
  fi
}

config_checker /etc/google_domains_dynamic/config
config_checker $HOME/.google_domains_dynamic/config

# Check update ip cache path and ensure it exists
: ${updater_ip_cache_path:=$HOME/.google_domains_dynamic}
mkdir -p $updater_ip_cache_path
: ${updater_ip_cache:=$updater_ip_cache_path/last_ip}

# Ensure our configs set these variables
if [[ -z "$GOOGLE_DOMAINS_USERNAME" ]]; then
  echo 'username not set, exiting'
  exit 1
fi
if [[ -z "$GOOGLE_DOMAINS_PASSWORD" ]]; then
  echo 'password not set, exiting'
  exit 1
fi
if [[ -z "$GOOGLE_DOMAINS_HOSTNAME" ]]; then
  echo 'hostname not set, exiting'
  exit 1
fi

# check our last_ip if it exists
if [[ -f "${updater_ip_cache}" ]]; then
  last_IP=$( cat ${updater_ip_cache})
else
  last_IP=none
fi

# Resolve current public IP
IP=$( dig +short myip.opendns.com @resolver1.opendns.com )

# Check the two IPs to see if they are equal
if [[ "$last_IP" != "$IP" ]]; then
  # They are not equal so update the IP
  echo "$IP" > ${updater_ip_cache_path}
  # Update Google DNS Record
  URL="https://${GOOGLE_DOMAINS_USERNAME}:${GOOGLE_DOMAINS_PASSWORD}@domains.google.com/nic/update?hostname=${GOOGLE_DOMAINS_HOSTNAME}&myip=${IP}"
  RESULT=$(curl -s $URL)
  if [[ "$RESULT" == "good $IP" ]]; then
    echo Successful Update -- $RESULT
  elif [[ "$RESULT" == "nochg $IP" ]]; then
    echo No Change -- $RESULT
  else
    echo "Failure result = $RESULT"
    exit 1
  fi
else
  echo No change in IP
fi
