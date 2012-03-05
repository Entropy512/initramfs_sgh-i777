#!/sbin/sh

. /res/customconfig/customconfig-helper
read_defaults
read_config

#apply default config
(
sleep 5
/res/uci.sh apply
) &

