## Application and container runtime (Docker)
#################################################################
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
#sudo usermod -a -G docker ssm-user
sudo systemctl enable docker
sudo systemctl start docker

sudo yum install amazon-ecr-credential-helper -y
mkdir -p /tmp/docker
cat > /tmp/docker/auth-config.json <<- EOF
{
  "credHelpers": {
    "${ECR_HOST}": "ecr-login"
  },
  "credsStore": "ecr-login"
}
EOF
sudo install -D -o root -g root -m 644 /tmp/docker/auth-config.json /etc/docker/auth-config.json
sudo install -D -o root -g root -m 644 /tmp/docker/auth-config.json /root/.docker/config.json
sudo install -o ec2-user -g ec2-user -d /home/ec2-user/.docker
sudo install -o ec2-user -g ec2-user -m 644 /tmp/docker/auth-config.json /home/ec2-user/.docker/config.json

## Consul DNS resolution for docker containers
#################################################################
if [ ${ENABLE_CONSUL_DNS} -eq 1 ]; then
  yum install dnsmasq -y
  mkdir -p /tmp/dns
  cat > /tmp/dns/dnsmasq.conf <<- EOF
interface=docker0
server=/consul/127.0.0.1#8600
EOF
  sudo install -o root -g root -m 644 /tmp/dns/dnsmasq.conf /etc/dnsmasq.d/00-consul
  sudo systemctl daemon-reload
  sudo systemctl restart dnsmasq
  cat > /tmp/dns/docker.json <<- EOF
{
  "dns": [
    "172.17.0.1"
  ],
  "dns-search": [
    "${DATACENTER}.consul.",
    "consul."
  ]
}
EOF
  sudo install -o root -g root -m 644 /tmp/dns/docker.json /etc/docker/daemon.json
  sudo systemctl daemon-reload
  sudo systemctl restart docker
fi

## Application and container runtime (Java)
#################################################################
sudo amazon-linux-extras enable corretto8
sudo yum install java-1.8.0-amazon-corretto -y