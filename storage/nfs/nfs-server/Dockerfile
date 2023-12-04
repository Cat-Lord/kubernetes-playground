FROM debian:trixie

RUN apt update
RUN apt install -y nfs-kernel-server portmap
#RUN apt-get install -y systemd portmap nfs-common

COPY exports /etc/exports

EXPOSE 2049
EXPOSE 111

ADD run /usr/local/bin/run.sh
RUN chmod u+x /usr/local/bin/run.sh
ENTRYPOINT ["run.sh"]
