FROM alpine

RUN apk add openssh jq

RUN ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa

RUN echo "root:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 36 ; echo '')" | chpasswd

RUN touch /var/log/btmp
RUN chmod 600 /var/log/btmp

RUN ssh-keygen -f /etc/ssh/ssh_host_ecdsa_key -N '' -t ecdsa
RUN ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -N '' -t ed25519

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/usr/sbin/sshd", "-D", "-e"]
ENTRYPOINT ["/entrypoint.sh"]
