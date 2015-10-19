node  /haproxy1/ {
  class { 'haproxy':
        global_options => {
          'daemon'     => '',
          'maxconn'    => '4000',
        },
        defaults_options => {
          'mode'         => 'http',
          'timeout'      => [
          'connect 5000ms',
          'client 50000ms',
          'server 50000ms',
          ],
        }
  }

  haproxy::frontend { 'http-in':
    bind    => { "$::ipaddress_eth1:80" => [] },
    options => [
      { 'default_backend' => 'webservers'  }
    ]
  }

  haproxy::backend { 'webservers':
    options  => [
      { option   => [ 'http-server-close', 'httpchk', 'forwardfor' ] },
      { balance  => 'roundrobin' },
      { server   => [
      'web1 172.28.33.13:80 check inter 5000',
      'web2 172.28.33.14:80 check inter 5000',
      'web3 172.28.33.15:80 check inter 5000',
      'web4 172.28.33.16:80 check inter 5000',
    ]
    }
     ] 
  }

  haproxy::listen { 'admin':
    bind    => { "$::ipaddress_eth1:8080" => [] },
    options => [
      { 'stats' => 'enable'  }
    ]
  }

  include keepalived
  keepalived::vrrp::instance { 'VI_1':
    interface         => 'eth1',
    state             => 'MASTER',
    virtual_router_id => '50',
    priority          => '101',
    advert_int        => '1',
    virtual_ipaddress => [ '172.28.33.10' ],
    track_interface   => ['eth1'], # optional, monitor these interfaces.
  }

}
node  /haproxy2/ {
  class { 'haproxy':
        global_options => {
          'daemon'     => '',
          'maxconn'    => '4000',
        },
        defaults_options => {
          'mode'         => 'http',
          'timeout'      => [
          'connect 5000ms',
          'client 50000ms',
          'server 50000ms',
          ],
        }
  }

  haproxy::frontend { 'http-in':
    bind    => { "$::ipaddress_eth1:80" => [] },
    options => [
      { 'default_backend' => 'webservers'  }
    ]
  }

  haproxy::backend { 'webservers':
    options  => [
      { option   => [ 'http-server-close', 'httpchk', 'forwardfor' ] },
      { balance  => 'roundrobin' },
      { server   => [
      'web1 172.28.33.13:80 check inter 5000',
      'web2 172.28.33.14:80 check inter 5000',
      'web3 172.28.33.15:80 check inter 5000',
      'web4 172.28.33.16:80 check inter 5000',
    ]
    }
     ] 
  }

  haproxy::listen { 'admin':
    bind    => { "$::ipaddress_eth1:8080" => [] },
    options => [
      { 'stats' => 'enable'  }
    ]
  }

  include keepalived
  keepalived::vrrp::instance { 'VI_1':
    interface         => 'eth1',
    state             => 'BACKUP',
    virtual_router_id => '50',
    priority          => '100',
    advert_int        => '1',
    virtual_ipaddress => [ '172.28.33.10' ],
    track_interface   => ['eth1'], # optional, monitor these interfaces.
  }

}
