vagrant-haproxy-demo
====================

Demo of HAProxy using Vagrant

This is the toolset I used to present on load balancers at University of Nebraska at Kearney on 2/19/14.

# What does the Vagrantfile do?
* It sets up a 3 VM mini-network inside Virtualbox.  The three hosts are haproxy (172.28.33.1), web1 (172.28.33.11), and web2 (172.28.33.12)
* It sets up the following port forwards between your host's external interface and the internal VM's:

| Host port | Guest machine | Guest port | Notes
------------|---------------|------------|---
| 8080 | haproxy | 8080 | HAProxy Admin Interface
| 8081 | haproxy | 80 | Load Balanced Apache
* It installs Apache on the two web servers, and configures it with a index page that identifies which host you're viewing the page on.
* It installs HAProxy on the haproxy host, and drops a configuration file in place with the two webservers pre-configured.  It doesn't require HAProxy to be the default gateway because it NAT's the source IP as well as the destination IP.

# Prerequisites
1.  Install [Vagrant](http://www.vagrantup.com/downloads.html)
2.  Install [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
3.  Either clone this repo with ``` git clone https://github.com/justintime/vagrant-haproxy-demo.git ``` or just download the [current zip file](https://github.com/justintime/vagrant-haproxy-demo/archive/master.zip) and extract it in an empty directory.

# Getting started
1.  Open 6 terminal windows -- one for each host.  Change to the directory containing the Vagrantfile from step 3 above.
2.  In terminal #1, run ``` vagrant up haproxy1 && vagrant ssh haproxy1 ```
3.  In terminal #2, run ``` vagrant up haproxy2 && vagrant ssh haproxy2 ```
4.  In terminal #3, run ``` vagrant up web1 && vagrant ssh web1 ```
5.  In terminal #4, run ``` vagrant up web2 && vagrant ssh web2 ```
6.  In terminal #5, run ``` vagrant up web3 && vagrant ssh web3 ```
7.  In terminal #6, run ``` vagrant up web4 && vagrant ssh web4 ```
8.  Open up [http://localhost:8080/haproxy?stat](http://localhost:8080/haproxy?stats) in your host's browser.  This is the HAProxy admin interface.
9.  Open up [http://localhost:8081/](http://localhost:8081/) in your host's browser.  This is the load balanced interface to the two web servers.  **Note** this is port forwarded via your actual host, and will be accessible via your externally accessible IP address - you can access test the load balancer from another workstation if you wish.
10.  Open up [http://172.28.33.11:8081/](http://172.28.33.11:8080/haproxy?stats) in your host's browser.  This is the load balanced interface for Haproxy1.
11.  Open up [http://172.28.33.12:8081/](http://172.28.33.12:8080/haproxy?stats) in your host's browser.  This is the load balanced interface for Haproxy2.
12.  Open up [http://172.28.33.13/](http://172.28.33.13/) in a browser to see if web1's Apache is working.
13.  Open up [http://172.28.33.14/](http://172.28.33.14/) in a browser to see if web2's Apache is working.
14.  Open up [http://172.28.33.15/](http://172.28.33.15/) in a browser to see if web3's Apache is working.
15.  Open up [http://172.28.33.16/](http://172.28.33.16/) in a browser to see if web4's Apache is working.
15.  Open up [http://172.28.33.10/](http://172.28.33.10/) in a browser to see if Keepalived is working.
16.  To see the Apache access logs on web1 and web2, run ``` sudo tail -f /var/log/apache2/access.log ```  If you'd like to filter out the "pings" from the load balancer, run ``` sudo tail -f /var/log/apache2/access.log | grep -v OPTIONS ```
17.  To stop Apache on one of the webservers to simulate an outage, run ``` sudo service apache2 stop ```  To start it again, run ``` sudo service apache2 start ```
18.  To make changes to haproxy, edit the config file with ``` sudo nano /etc/haproxy/haproxy.cfg ```  When you want to apply the changes, run ``` sudo service haproxy reload ```  If you break things and want to reset back, just run ``` sudo cp /etc/haproxy/haproxy.cfg.orig /etc/haproxy/haproxy.cfg && sudo service haproxy reload ```
19.  When you're all done, type ``` exit ``` at the shell to get back to your local terminal.
20.  To shut down the VM's, run ``` vagrant halt web1 web2 web3 web4 haproxy1 haproxy2
21.  To remove the VM's from your hard drive, run ``` vagrant destroy web1 web2 web3 web4 haproxy1 haproxy2 ```

# Reference material
* [Vagrant](http://vagrantup.com)
* [VirtualBox](http://www.virtualbox.org)
* [HAProxy](http://haproxy.1wt.eu/)
* [How to run HAProxy with TProxy for half-NAT  setups](http://blog.loadbalancer.org/configure-haproxy-with-tproxy-kernel-for-full-transparent-proxy/)

