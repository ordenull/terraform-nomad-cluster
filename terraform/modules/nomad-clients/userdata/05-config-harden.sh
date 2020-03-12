## Ask SSH not to listen on the docker bridge
#################################################################
if [ $PROTECT_HOST_SSH -eq 1 ]; then
  PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
  sudo sed -i -e /ListenAddress/d /etc/ssh/sshd_config
  sudo sh -c "sudo echo ListenAddress ${PRIVATE_IP} >> /etc/ssh/sshd_config"
  sudo systemctl restart sshd
fi

## Sandbox docker containers
#################################################################
if [ ! -f /etc/iptables.haden ]; then
  if [ $PROTECT_AWS_META -eq 1 ]; then
    # Block access to the AWS metadata service from users that don't need it
    sudo iptables -A OUTPUT --proto tcp -d 169.254.169.254 --match owner --uid-owner root -j ACCEPT
    sudo iptables -A OUTPUT --proto tcp -d 169.254.169.254 --match owner --uid-owner consul -j ACCEPT
    sudo iptables -A OUTPUT --proto tcp -d 169.254.169.254 --match owner --uid-owner ec2-user -j ACCEPT
    sudo iptables -A OUTPUT --proto tcp -d 169.254.169.254 -j REJECT

    # Block access to the AWS metadata service from within docker containers
    sudo iptables -I DOCKER-USER -d 169.254.169.254 -j REJECT
  fi

  if [ $PROTECT_SERVICES -eq 1 ]; then
    # Block docker containers from accessing SSH on the host
    if [ $PROTECT_HOST_SSH -eq 1 ]; then
      iptables -A INPUT -i docker0 -p tcp --dport 22 -j REJECT   # SSH
    fi
    # Block docker containers from accessing system services on the host
    sudo iptables -A INPUT -i docker0 -p tcp --dport 111 -j REJECT  # RPC Bind
    sudo iptables -A INPUT -i docker0 -p tcp --dport 4647 -j REJECT # Nomad RPC
    sudo iptables -A INPUT -i docker0 -p tcp --dport 8300 -j REJECT # Consul RPC
    sudo iptables -A INPUT -i docker0 -p tcp --dport 8301 -j REJECT # Consul LAN Serf
    sudo iptables -A INPUT -i docker0 -p udp --dport 8301 -j REJECT # Consul LAN Serf

    # Block docker containers from accessing system services on the LAN
    MAC=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs | head -n1 | tr -d '/')
    VPC_CIDR=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/${MAC}/vpc-ipv4-cidr-block)
    sudo iptables -I DOCKER-USER -p tcp --dport 4647 -d ${VPC_CIDR} -j REJECT # Nomad RPC
    sudo iptables -I DOCKER-USER -p tcp --dport 8300 -d ${VPC_CIDR} -j REJECT # Consul RPC
  fi

  if [ $PROTECT_CONSUL_API -eq 1 ]; then
    iptables -A INPUT -i docker0 -p tcp --dport 8500 -j REJECT # Consul HTTP API (Required by some clients)
    iptables -A INPUT -i docker0 -p tcp --dport 8600 -j REJECT # Consul DNS (Handled natively via dnsmasq)
  fi

  # Make this persistent
  /sbin/iptables-save > /etc/iptables.harden
fi