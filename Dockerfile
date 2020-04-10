FROM alpine

RUN apk add openssh jq

RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

RUN echo "root:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 36 ; echo '')" | chpasswd

COPY sshd_config /etc/ssh/sshd_config

RUN mkdir ~/.ssh \
	&& chmod 0700 ~/.ssh \
	&& touch ~/.ssh/authorized_keys \
	&& chmod 0600 ~/.ssh/authorized_keys

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
ENTRYPOINT ["/entrypoint.sh"]
