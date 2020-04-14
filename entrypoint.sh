#!/bin/sh

[ -z "${PUBLIC_KEYS}" ] && echo "There are no registered public keys, nobody can ever login, exiting" && exit 1

SHELL_PORT=$(echo ${SHELL_PORT} | sed 's/[^0-9]*//g')
[ -z "${SHELL_PORT}" ] && echo "The SHELL_PORT variable must contain a numeric value, exiting" && exit 1

echo "Configuring SSH with shell access or just port forwarding"
echo "Writing Basic SSHD Config"
cat <<EOF > /etc/ssh/sshd_config
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
Port ${SHELL_PORT}
EOF

JSON_KEYS=$(echo "${PUBLIC_KEYS}" | base64 -d)

for user in $(echo "${JSON_KEYS}" | jq -r 'keys[]'); do
  echo "Processing user '${user}'"

  echo "Create user and adjust permissions"
  adduser --disabled-password ${user}
  echo "${user}:$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 36 ; echo '')" | chpasswd

  mkdir /home/${user}/.ssh
  chmod 700 /home/${user}/.ssh

  file=/home/${user}/.ssh/authorized_keys
  touch ${file}
  chmod 600 ${file}

  chown -R ${user}:root /home/${user}

  echo "Writing user keys to file '${file}'"
  is_array=$(echo "${JSON_KEYS}" | jq -r '.'$user'.key[]' &>/dev/null; echo $?)

  [ "${is_array}" = 0 ] && echo "${JSON_KEYS}" | jq -r '.'$user'.key[]' > ${file}
  [ "${is_array}" != 0 ] && echo "${JSON_KEYS}" | jq -r '.'$user'.key' > ${file}

  if [ "${DEBUG_KEYS}" = "true" ]; then
    echo "Debug Keys: Show keys for user '${user}'"
    cat ${file}
  fi

  if [ "$(echo "${JSON_KEYS}" | jq -r '.'$user'.shell')" = "true" ]; then
    echo "Shell access: 'enabled'"
  else
    echo "Shell access: 'disabled'"
    append_restriction="ForceCommand /bin/false"
  fi

  cat <<EOF >> /etc/ssh/sshd_config

Match User ${user}
  AuthorizedKeysFile ${file}
  AllowTcpForwarding yes
  X11Forwarding no
  AllowAgentForwarding no
  ${append_restriction}
EOF

  echo -e "Complete!\n"
done

if [ "${DEBUG_CONFIG}" = "true" ]; then
  echo "Debug Config: Show SSHD Config"
  cat /etc/ssh/sshd_config
fi

command="$@"
if [ "${DEBUG_SSH}" = "true" ]; then
  command="$@ -ddd"
fi

echo "Executing command '${command}'"
exec ${command}

