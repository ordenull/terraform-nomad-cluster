## Block access to the AWS metadata service from users that don't need it
#################################################################
if [ ! -f /etc/iptables.haden ]; then
  if [ $PROTECT_AWS_META -eq 1 ]; then
    sudo iptables --append OUTPUT --proto tcp --destination 169.254.169.254 --match owner --uid-owner root --jump ACCEPT
    sudo iptables --append OUTPUT --proto tcp --destination 169.254.169.254 --match owner --uid-owner consul --jump ACCEPT
    sudo iptables --append OUTPUT --proto tcp --destination 169.254.169.254 --match owner --uid-owner ec2-user --jump ACCEPT
    sudo iptables --append OUTPUT --proto tcp --destination 169.254.169.254 --jump REJECT
  fi

  # Make this persistent
  /sbin/iptables-save > /etc/iptables.harden
fi