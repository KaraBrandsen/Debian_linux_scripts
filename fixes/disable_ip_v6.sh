#!/bin/bash

if grep -F "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf ; then
    echo "IPv6 already disabled"
else
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
    sysctl -p
fi
