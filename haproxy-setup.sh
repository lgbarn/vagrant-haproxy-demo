#!/bin/bash

if [ ! -f /etc/haproxy/haproxy.cfg ]; then

  # Install haproxy
  yum -y install haproxy
  iptables -F

  # Configure haproxy
  cat > /etc/default/haproxy <<EOD
# Set ENABLED to 1 if you want the init script to start haproxy.
ENABLED=1
# Add extra flags here.
#EXTRAOPTS="-de -m 16"
EOD
  cat > /etc/haproxy/haproxy.cfg <<EOD
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http-in
    bind *:80
    default_backend webservers

backend webservers
    balance roundrobin
    # Poor-man's sticky
    # balance source
    # JSP SessionID Sticky
    # appsession JSESSIONID len 52 timeout 3h
    option httpchk
    option forwardfor
    option http-server-close
    server web1 10.175.32.150:80 maxconn 32 check
    server web2 10.175.32.151:80 maxconn 32 check
    server web3 10.175.32.152:80 maxconn 32 check
#    server web3 172.28.33.13:80 maxconn 32 check
#    server web4 172.28.33.14:80 maxconn 32 check

listen admin
    bind *:8080
    stats enable
EOD

  cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
  /sbin/service haproxy restart
fi
