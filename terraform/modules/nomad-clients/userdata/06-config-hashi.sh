INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

## Consul
#################################################################
cat > /tmp/consul/consul.conf <<- EOF
data_dir           = "/var/lib/consul"
bind_addr          = "${PRIVATE_IP}"
leave_on_terminate = true
datacenter         = "${DATACENTER}"
node_name          = "${INSTANCE_ID}"

server             = false
retry_join         = ["provider=aws tag_key=nomad:discover tag_value=${DISCOVER_TAG_VALUE} addr_type=private_v4"]
EOF
sudo install -o consul -g consul -m 700 -d /var/lib/consul
sudo install -o root -g root -m 644 /tmp/consul/consul.conf /etc/consul.conf

## Nomad
#################################################################
cat > /tmp/nomad/nomad.conf <<- EOF
data_dir           = "/var/lib/nomad"
bind_addr          = "${PRIVATE_IP}"
enable_syslog      = false
leave_on_interrupt = true
leave_on_terminate = true
datacenter         = "${DATACENTER}"
region             = "${REGION}"
name               = "${INSTANCE_ID}"

client {
  enabled    = true
  node_class = "${NOMAD_NODECLASS}"
  server_join {
    retry_join = ["provider=aws tag_key=nomad:discover tag_value=${DISCOVER_TAG_VALUE} addr_type=private_v4"]
  }
  options   = {
    "docker.auth.config"     = "/etc/docker/auth-config.json"
    "docker.auth.helper"     = "ecr-login"
  }
}
EOF
sudo install -o root -g root -m 700 -d /var/lib/nomad
sudo install -o root -g root -m 644 /tmp/nomad/nomad.conf /etc/nomad.conf