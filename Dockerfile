# Use alpine parent image
FROM alpine:3.7
LABEL maintainer="Jithin Pavithran <jithinpavithran.public@gmail.com>"
# Expose port for squid
EXPOSE 3128/tcp
# install openvpn and bash and squid
# bash: openvpn need bash in some confiurations)
# squid: Ref: https://wiki.alpinelinux.org/wiki/Setting_up_Explicit_Squid_Proxy
# squid: To check logs: tail -f /var/log/squid/access.log
RUN apk add openvpn && apk add bash && apk add --no-cache --update squid
# Update squid config
RUN  sed -i -e 's/http_access deny all/http_access allow all/g' /etc/squid/squid.conf
# Starting script
COPY start.sh /sbin/start.sh
RUN chmod 755 /sbin/start.sh
CMD /sbin/start.sh
