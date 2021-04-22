FROM centos:latest

ENV JAVA_VERSION 8u162
ENV BUILD_VERSION b12
ENV JAVA_HOME /usr/java/latest
ENV RUN_AS_USER collabnet

# Upgrading system
RUN yum -y update && \
    yum -y install wget epel-release && \
    yum install -y net-tools python-setuptools hostname inotify-tools yum-utils && \
    wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=xxx; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u162-b12/0da788060d494f5095bf8624735fa2f1/jre-8u162-linux-x64.rpm" -O /tmp/jre-8-linux-x64.rpm && \
    yum -y install /tmp/jre-8-linux-x64.rpm && \
    rm -f /tmp/jre-8-linux-x64.rpm && \
    yum clean all \
    easy_install supervisor

RUN wget -q https://www.collab.net/sites/default/files/downloads/CollabNetSubversionEdge-5.2.4_linux-x86_64.tar.gz -O /tmp/csvn.tgz && \
    mkdir -p /opt/csvn && \
    tar -xzf /tmp/csvn.tgz -C /opt/csvn --strip=1 && \
    rm -rf /tmp/csvn.tgz

RUN useradd collabnet && \
    chown -R collabnet.collabnet /opt/csvn && \
    cd /opt/csvn && \
    ./bin/csvn install && \
    mkdir -p ./data-initial && \
    cp -r ./data/* ./data-initial

#update system timezone & application timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" >> /etc/timezone

EXPOSE 3343 4434 18080

ADD files /

VOLUME /opt/csvn/data

WORKDIR /opt/csvn

ENTRYPOINT ["/config/bootstrap.sh"]
