#!/bin/bash

start_setter() {
    if [ -e /tmp/.setter_start_mark ]; then
        /etc/init.d/bbox-bdsetter start || true
    else
        /opt/bitdefender/bin/bdsetter -start || true
    fi
}

stop_setter() {
    if [ ! -e /tmp/.setter_start_mark ]; then
        /opt/bitdefender/bin/bdsetter -stop || true
        killall -9 bdsetter
    fi
    touch /tmp/.setter_start_mark
}

get_key() {
    local r=0
    /opt/bitdefender/bin/bdsett -get-key "$1" || r="$?"
    return $r
}

set_key() {
    local r=0
    /opt/bitdefender/bin/bdsett -set-key "$1" -to-string "$2" || r="$?"
    return $r
}

del_key() {
    local r=0
    /opt/bitdefender/bin/bdsett -del-key "$1" || r="$?"
    return $?
}
