#!/bin/bash

if [ ! -f /etc/haproxy/haproxy.cfg ]; then

  # Install haproxy
  yum -y install haproxy
  yum -y install keepalived
  chkconfig haproxy on
  chkconfig keepalived on
  service iptables save
  service iptables stop
  chkconfig iptables off

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
    server web1 172.28.33.13:80 maxconn 32 check
    server web2 172.28.33.14:80 maxconn 32 check
    server web3 172.28.33.15:80 maxconn 32 check
    server web4 172.28.33.16:80 maxconn 32 check

listen admin
    bind *:8080
    stats enable
EOD

  cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
  /sbin/service haproxy restart

  cat > /etc/keepalived/keepalived.conf <<EOD
! Configuration File for keepalived

global_defs {
#   notification_email {
#     luther.barnum@gmail.com
#   }
#   notification_email_from Luther.Barnum@gmail.com
#   smtp_server 192.168.200.1
#   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    virtual_ipaddress {
        172.28.33.10
    }
}

virtual_server 172.28.33.10 80 {
    delay_loop 6
    lb_algo rr
    #lb_kind NAT
    persistence_timeout 50
    protocol TCP
   # sorry_server 192.168.200.200 1358

    real_server 172.28.33.11 80 {
        weight 1
        HTTP_GET {
            url {
              path /hello.php
              connect_timeout 3
            #  digest 640205b7b0fc66c1ea91c463fac6334d
            }
        }
    }

    real_server 172.28.33.12 80 {
        weight 1
        HTTP_GET {
            url {
              path /hello.php
              connect_timeout 3
            #  digest 640205b7b0fc66c1ea91c463fac6334c
            }
        }
    }
}

EOD

service keepalived restart

  cat > /etc/sysctl.conf <<EOD

net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 15000    61000
net.ipv4.tcp_fin_timeout = 15

EOD

sysctl -p

fi
