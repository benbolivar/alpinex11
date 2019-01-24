FROM openjdk:8u111-jre-alpine

ENV LANG=C.UTF-8 \
    DOCKER_VERSION=1.6.0 \
    DOCKER_BUCKET=get.docker.com \
    CHE_IN_CONTAINER=true \
    MAVEN_VERSION=3.3.9 \
    DISPLAY=:0.0 \
    DISPLAY_WIDTH=1024 \
    DISPLAY_HEIGHT=768
ENV M2_HOME=/usr/lib/apache-maven-$MAVEN_VERSION
ENV PATH=${PATH}:${M2_HOME}/bin

#    apk add --update sudo curl ca-certificates bash openssh unzip openssl shadow fluxbox git socat supervisor x11vnc xterm xvfb && \
#    git clone https://github.com/kanaka/noVNC.git /root/noVNC && \
#    git clone https://github.com/kanaka/websockify /root/noVNC/utils/websockify && \
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk add --upgrade apk-tools && \
    apk add --update sudo curl ca-certificates bash openssh unzip openssl shadow git && \
    curl -sSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}" -o /usr/bin/docker && \
    chmod +x /usr/bin/docker && \
    cd /tmp && \
    wget -q "http://apache.ip-connect.vn.ua/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    tar -xzf "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
    mv "/tmp/apache-maven-$MAVEN_VERSION" "/usr/lib" && \
    echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    rm -rf /tmp/* /var/cache/apk/* && \
    adduser -S user -h /home/user -s /bin/bash -G root -u 1000 && \
    echo "%root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
    usermod -p "*" user && \
    sudo git clone https://github.com/kanaka/noVNC.git /root/noVNC && \
    sudo git clone https://github.com/kanaka/websockify /root/noVNC/utils/websockify && \
    rm -rf /root/noVNC/.git && \
    rm -rf /root/noVNC/utils/websockify/.git && \
    apk del git && \
    sudo chown -R user /home/user/ && \
    sudo mkdir -p /home/user/.m2 && \
    sudo mkdir -p /home/user/jdtls/data && \
    sudo chgrp -R 0 ${HOME} && \
    sudo chmod -R g+rwX ${HOME} && \
    echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:X11]\n\
command=Xvfb :0 -screen 0 "%(ENV_DISPLAY_WIDTH)s"x"%(ENV_DISPLAY_HEIGHT)s"x24\n\
autorestart=true\n\
\n\
[program:x11vnc]\n\
command=/usr/bin/x11vnc\n\
autorestart=true\n\
\n\
[program:novnc]\n\
command=/root/noVNC/utils/launch.sh\n\
autorestart=true\n\
\n\
[program:socat]\n\
command=socat tcp-listen:6000,reuseaddr,fork unix:/tmp/.X11-unix/X0\n\
autorestart=true\n\
\n\
[program:fluxbox]\n\
command=fluxbox\n\
autorestart=true\n\
\n\
[program:demo]\n\
command=xterm\n\
autorestart=true' >> /dev/null #/etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 8000 8080 6080 32745

USER user

WORKDIR /projects

#CMD /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf & sleep 365d

CMD sudo /usr/bin/ssh-keygen -A && \
    sudo /usr/sbin/sshd -D && \
    sudo su - && \
    tail -f /dev/null
