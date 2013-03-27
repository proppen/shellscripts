#!/bin/sh
# Get the IP Addresses assigned to interfaces

/sbin/ifconfig -a | sed -n 's/.*inet addr:\([0-9.]*\).*/\1/p'|grep -v 127.0.0.1
