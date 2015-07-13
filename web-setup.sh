#!/bin/bash


  # Install apache
  yum -y install httpd
  service iptables save
  service iptables stop
  chkconfig iptables off
  chkconfig httpd on
  cat > /var/www/index.html <<EOD
<html><head><title>${HOSTNAME}</title></head><body><h1>${HOSTNAME}</h1>
<p>This is the default web page for ${HOSTNAME}.</p>
</body></html>
EOD

  # Log the X-Forwarded-For
  perl -pi -e  's/^LogFormat "\%h (.* combined)$/LogFormat "%h %{X-Forwarded-For}i $1/' /etc/httpd/conf/httpd.conf
  /sbin/service httpd restart

SERVER=`uname -n`
cat > /var/www/html/index.html <<EOD
<!DOCTYPE html>
<html>
<head>
<title>Page Title</title>
</head>
<body>

<h1>${SERVER} Test Page</h1>

</body>
</html>
EOD

cat > /var/www/html/hello.php <<EOD
<html>
 <head>
  <title>PHP Test</title>
 </head>
 <body>
 <?php echo '<p>Hello World</p>'; ?> 
 </body>
</html>
EOD
