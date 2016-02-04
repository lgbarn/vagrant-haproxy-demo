#!/bin/bash

if [ ! -f /etc/haproxy/haproxy.cfg ]; then

  # Install haproxy
  yum -y install haproxy
  yum -y install keepalived
  yum -y install nc
  yum -y install openssl
  rpm -e irqbalance
  rpm -ivh http://pkgs.repoforge.org/socat/socat-1.7.2.4-1.el6.rf.x86_64.rpm
  chkconfig haproxy on
  chkconfig keepalived on
  service iptables save
  service iptables stop
  chkconfig iptables off
  mkdir -p /etc/ssl/private/
  cp /vagrant/cert.pem /etc/ssl/private/cert.pem

  # Configure haproxy
  cat > /etc/default/haproxy <<EOD
# Set ENABLED to 1 if you want the init script to start haproxy.
ENABLED=1
# Add extra flags here.
#EXTRAOPTS="-de -m 16"
EOD

mkdir -p /etc/haproxy/errors
touch /etc/haproxy/errors/400.http
touch /etc/haproxy/errors/403.http
touch /etc/haproxy/errors/408.http
touch /etc/haproxy/errors/500.http
touch /etc/haproxy/errors/502.http
touch /etc/haproxy/errors/503.http
touch /etc/haproxy/errors/504.http

  cat > /etc/haproxy/haproxy.cfg <<EOD
global
    daemon
    maxconn 4096
    stats socket /var/run/haproxy.sock level admin
    tune.ssl.default-dh-param 2048

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

frontend http-in
    bind *:80
    default_backend webservers

frontend https-in
    bind *:443 ssl crt /etc/ssl/private/cert.pem
    reqadd X-Forwarded-Proto:\ https
    default_backend webservers

backend webservers
    balance roundrobin
    # Poor-man's sticky
    # balance source
    # JSP SessionID Sticky
    # appsession JSESSIONID len 52 timeout 3h
#    redirect scheme https if !{ ssl_fc }
    option httpchk
    option forwardfor
    option http-server-close
    server web1 172.28.33.13:80 check inter 5000
    server web2 172.28.33.14:80 check inter 5000
    server web3 172.28.33.15:80 check inter 5000
    server web4 172.28.33.16:80 check inter 5000

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
    interface eth1
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
    lb_kind DR
    persistence_timeout 50
    protocol TCP
   # sorry_server 192.168.200.200 1358

    real_server 172.28.33.11 80 {
        weight 1
        HTTP_GET {
            url {
              path /hello.php
              digest 1490068c61809bc997ea3186b247ef93
            }
            connect_timeout 3
            nb_ger_retry 3
            delay_before_retry 2
        }
    }

    real_server 172.28.33.12 80 {
        weight 1
        HTTP_GET {
            url {
              path /hello.php
              digest 1490068c61809bc997ea3186b247ef93
            }
            connect_timeout 3
            nb_ger_retry 3
            delay_before_retry 2
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
net.ipv4.tcp_max_tw_buckets = 524288

EOD

sysctl -p

fi
