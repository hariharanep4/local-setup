#! /bin/bash

TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.gz"

sudo yum install java-1.8.0-openjdk git maven wget -y
wget $TOMCAT_URL -O tomcatbin.tar.gz

EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f 1`

sudo useradd --shell /sbin/nologin tomcat
sudo rsync -avzh $TOMDIR/ /usr/local/tomcat8/
sudo chown -R tomcat.tomcat /usr/local/tomcat8/

sudo rm -rf /etc/systemd/system/tomcat.service

cat <<EOT >> /etc/systemd/system/tomcat.service

[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
User=tomcat
Group=tomcat
workingDirectory=/usr/local/tomcat8/

# Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre

Environment=CATALINA_PID=/var/tomcat/%i/run/tomcat.pid
Environment=CATALINA_HOME=/usr/local/tomcat8
Environment=CATALINA_BASE=/usr/local/tomcat8

ExecStart=/usr/local/tomcat8/bin/startup.sh
ExecStop=/usr/local/tomcat8/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

EOT

sudo systemctl daemon-reload
sudo systemctl start tomcat
sudo systemctl enable tomcat

git clone -b local-setup https://github.com/devopshydclub/vprofile-project.git
cd vprofile-project
mvn install
sudo systemctl stop tomcat
sleep 60
sudo rm -rf /usr/local/tomcat8/webapps/ROOT*
sudo cp target/vprofile-project.war /usr/local/tomcat8/webapps/ROOT.war
sudo systemctl start tomcat
sleep 120
cp /vagrant/application.properties /usr/local/tomcat8/webapps/ROOT/WEB-INF/classes/application.properties
sudo systemctl restart tomcat