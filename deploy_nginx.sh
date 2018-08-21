#Please update and install devtools before running this script
echo ""
read -p "Do you want to deploy nginx? [y/n]: " -e -i n SETUPNGX
if [[ "$SETUPNGX" = 'y' ]]; then
yum -y install gcc gcc-c++ make zlib-devel pcre-devel openssl-devel
./configure \
--user=nginx                          \
--group=nginx                         \
--prefix=/etc/nginx                   \
--sbin-path=/usr/sbin/nginx           \
--conf-path=/etc/nginx/nginx.conf     \
--pid-path=/var/run/nginx.pid         \
--lock-path=/var/run/nginx.lock       \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-http_gzip_static_module        \
--with-http_stub_status_module        \
--with-http_ssl_module                \
--with-pcre                           \
--with-file-aio                       \
--with-http_realip_module   		  \
--with-stream					 \
--add-module=nginx-module-vts    \
--add-module=nginx-module-sts \
--add-module=nginx-module-stream-sts 
make
make install
if [[ ! -e /usr/share/nginx ]]; then
mkdir /usr/share/nginx && mkdir /usr/share/nginx/html
fi
cp status.html /usr/share/nginx/html/status.html
cat <<EOT>/usr/lib/systemd/system/nginx.service
[Unit]
Description=nginx - high performance web server
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID

[Install]
WantedBy=multi-user.target
EOT
yes | cp -f nginx.conf /etc/nginx
  			echo "First Web Server Backend IP and Port one per line"
                        read -p "IP: " -e SETUPIP
                        read -p "Port: " -e SETUPDPORT
#                        echo ""
#                        echo "Second Web Server Backend IP and Port"
#                        read -p "IP: " -e SETUPIP2
#                        read -p "Port: " -e SETUPDPORT2       
                        sed -i "/# server 111.111.111.111:80;/a \
                        server $SETUPIP:$SETUPDPORT;" /etc/nginx/nginx.conf
#                        sed -i "/# server 111.111.111.111:80;/a \
#                        server $SETUPIP2:$SETUPDPORT2;" /etc/nginx/nginx.conf
                        echo ""
useradd nginx
chown nginx:nginx /var/log/nginx
service nginx restart
chkconfig nginx on
echo ""
echo "Nginx Traffic Status"
echo "http://<IP>/status.html"
echo ""
fi

