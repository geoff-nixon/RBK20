#!/bin/sh

file_path="/tmp/hyd_mac_list"

(echo "td s2"; sleep 2)| hyt | awk '/#/{print $0}'  |  grep -oE '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}' > $file_path
