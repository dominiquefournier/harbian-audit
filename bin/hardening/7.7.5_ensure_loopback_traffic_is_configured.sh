#!/bin/bash

#
# harbian audit 9 Hardening
#

#
# 7.7.5 Ensure loopback traffic is configured (Scored)
# Include ipv4 and ipv6
# Add this feature:Authors : Samson wen, Samson <sccxboy@gmail.com>
#

set -e # One error, it's over
set -u # One variable unset, it's over

HARDENING_LEVEL=2

IPS4=$(which iptables)
IPS6=$(which ip6tables)

# This function will be called if the script status is on enabled / audit mode
audit () {
	# Check the loopback interface to accept INPUT traffic.
	ensure_lo_traffic_input_is_accept()
	if [ $FNRET = 0 ]; then
		INPUT_ACCEPT=0
		ok "Iptables loopback traffic INPUT has configured!"
	else
		INPUT_ACCEPT=1
		crit "Iptables: loopback traffic INPUT is not configured!"
	fi 
	# Check the loopback interface to accept OUTPUT traffic.
	ensure_lo_traffic_output_is_accept()
	if [ $FNRET = 0 ]; then
		OUTPUT_ACCEPT=0
		ok "Iptables loopback traffic OUTPUT has configured!"
	else
		OUTPUT_ACCEPT=1
		crit "Iptables: loopback traffic OUTPUT is not configured!"
	fi 
	# all other interfaces to deny traffic to the loopback network.
	ensure_lo_traffic_other_if_input_is_deny()
	if [ $FNRET = 0 ]; then
		INPUT_DENY=0
		ok "Iptables loopback traffic INPUT deny from other interfaces has configured!"
	else
		INPUT_DENY=1
		crit "Iptables: loopback traffic INPUT deny from other interfaces is not configured!"
	fi 
}

# This function will be called if the script status is on enabled mode
apply () {
	if [ $INPUT_ACCEPT = 0 ]; then 
		ok "Iptables loopback traffic INPUT has configured!"
	else
        warn "Iptables/Ip6tables loopback traffic INPUT is not configured! need the administrator to manually add it. Howto set: iptables/ip6tables -A INPUT -i lo -j ACCEPT"
	fi

	if [ $OUTPUT_ACCEPT = 0 ]; then 
		ok "Iptables loopback traffic OUTPUT has configured!"
	else
        warn "Iptables/Ip6tables loopback traffic OUTPUT is not configured! need the administrator to manually add it. Howto set: iptables/ip6tables -A OUTPUT -o lo -j ACCEPT"
	fi

	if [ $INPUT_DENY = 0 ]; then 
		ok "Iptables loopback traffic INPUT deny from other interfaces has configured!"
	else
        warn "Iptables/Ip6tables loopback traffic INPUT deny from 127.0.0.0/8 is not configured! need the administrator to manually add it. Howto set: iptables/ip6tables -A INPUT -s 127.0.0.0/8 -j DROP"
	fi
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ -r /etc/default/cis-hardening ]; then
    . /etc/default/cis-hardening
fi
if [ -z "$CIS_ROOT_DIR" ]; then
     echo "There is no /etc/default/cis-hardening file nor cis-hardening directory in current environment."
     echo "Cannot source CIS_ROOT_DIR variable, aborting."
    exit 128
fi

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
if [ -r $CIS_ROOT_DIR/lib/main.sh ]; then
    . $CIS_ROOT_DIR/lib/main.sh
else
    echo "Cannot find main.sh, have you correctly defined your root directory? Current value is $CIS_ROOT_DIR in /etc/default/cis-hardening"
    exit 128
fi
