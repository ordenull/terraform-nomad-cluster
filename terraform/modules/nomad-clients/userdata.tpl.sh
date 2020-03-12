#!/bin/bash

set -ex

## Configuration
#################################################################
NOMAD_VERSION=${nomad_version}
NOMAD_ARCH=amd64
NOMAD_DATACENTER=${nomad_datacenter}
NOMAD_DISCOVER=${nomad_discover}
NOMAD_EXPECT=${nomad_expect}

## UGLY: Below this line all bash variable interpolations are
## expressed with double dollar $$ signs to avoid conflicting
## with terraform's template syntax.

## Static data
#################################################################
mkdir -p /tmp/static
cat > /tmp/static/hashcorp.asc <<- EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mQENBFMORM0BCADBRyKO1MhCirazOSVwcfTr1xUxjPvfxD3hjUwHtjsOy/bT6p9f
W2mRPfwnq2JB5As+paL3UGDsSRDnK9KAxQb0NNF4+eVhr/EJ18s3wwXXDMjpIifq
fIm2WyH3G+aRLTLPIpscUNKDyxFOUbsmgXAmJ46Re1fn8uKxKRHbfa39aeuEYWFA
3drdL1WoUngvED7f+RnKBK2G6ZEpO+LDovQk19xGjiMTtPJrjMjZJ3QXqPvx5wca
KSZLr4lMTuoTI/ZXyZy5bD4tShiZz6KcyX27cD70q2iRcEZ0poLKHyEIDAi3TM5k
SwbbWBFd5RNPOR0qzrb/0p9ksKK48IIfH2FvABEBAAG0K0hhc2hpQ29ycCBTZWN1
cml0eSA8c2VjdXJpdHlAaGFzaGljb3JwLmNvbT6JATgEEwECACIFAlMORM0CGwMG
CwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEFGFLYc0j/xMyWIIAIPhcVqiQ59n
Jc07gjUX0SWBJAxEG1lKxfzS4Xp+57h2xxTpdotGQ1fZwsihaIqow337YHQI3q0i
SqV534Ms+j/tU7X8sq11xFJIeEVG8PASRCwmryUwghFKPlHETQ8jJ+Y8+1asRydi
psP3B/5Mjhqv/uOK+Vy3zAyIpyDOMtIpOVfjSpCplVRdtSTFWBu9Em7j5I2HMn1w
sJZnJgXKpybpibGiiTtmnFLOwibmprSu04rsnP4ncdC2XRD4wIjoyA+4PKgX3sCO
klEzKryWYBmLkJOMDdo52LttP3279s7XrkLEE7ia0fXa2c12EQ0f0DQ1tGUvyVEW
WmJVccm5bq25AQ0EUw5EzQEIANaPUY04/g7AmYkOMjaCZ6iTp9hB5Rsj/4ee/ln9
wArzRO9+3eejLWh53FoN1rO+su7tiXJA5YAzVy6tuolrqjM8DBztPxdLBbEi4V+j
2tK0dATdBQBHEh3OJApO2UBtcjaZBT31zrG9K55D+CrcgIVEHAKY8Cb4kLBkb5wM
skn+DrASKU0BNIV1qRsxfiUdQHZfSqtp004nrql1lbFMLFEuiY8FZrkkQ9qduixo
mTT6f34/oiY+Jam3zCK7RDN/OjuWheIPGj/Qbx9JuNiwgX6yRj7OE1tjUx6d8g9y
0H1fmLJbb3WZZbuuGFnK6qrE3bGeY8+AWaJAZ37wpWh1p0cAEQEAAYkBHwQYAQIA
CQUCUw5EzQIbDAAKCRBRhS2HNI/8TJntCAClU7TOO/X053eKF1jqNW4A1qpxctVc
z8eTcY8Om5O4f6a/rfxfNFKn9Qyja/OG1xWNobETy7MiMXYjaa8uUx5iFy6kMVaP
0BXJ59NLZjMARGw6lVTYDTIvzqqqwLxgliSDfSnqUhubGwvykANPO+93BBx89MRG
unNoYGXtPlhNFrAsB1VR8+EyKLv2HQtGCPSFBhrjuzH3gxGibNDDdFQLxxuJWepJ
EK1UbTS4ms0NgZ2Uknqn1WRU1Ki7rE4sTy68iZtWpKQXZEJa0IGnuI2sSINGcXCJ
oEIgXTMyCILo34Fa/C6VCm2WBgz9zZO8/rHIiQm1J5zqz0DrDwKBUM9C
=LYpS
-----END PGP PUBLIC KEY BLOCK-----
EOF
gpg --import /tmp/static/hashcorp.asc

## Nomad
#################################################################
mkdir -p /tmp/nomad
pushd /tmp/nomad

# TODO: Use a local mirror
curl -Os https://releases.hashicorp.com/nomad/$${NOMAD_VERSION}/nomad_$${NOMAD_VERSION}_linux_$${NOMAD_ARCH}.zip
curl -Os https://releases.hashicorp.com/nomad/$${NOMAD_VERSION}/nomad_$${NOMAD_VERSION}_SHA256SUMS
curl -Os https://releases.hashicorp.com/nomad/$${NOMAD_VERSION}/nomad_$${NOMAD_VERSION}_SHA256SUMS.sig

# Verify the signature of the nomad distribution
set -e
gpg --verify nomad_$${NOMAD_VERSION}_SHA256SUMS.sig nomad_$${NOMAD_VERSION}_SHA256SUMS
grep "nomad_$${NOMAD_VERSION}_linux_$${NOMAD_ARCH}.zip" nomad_$${NOMAD_VERSION}_SHA256SUMS >> nomad_$${NOMAD_VERSION}_SHA256SUMS_relevant
sha256sum -c nomad_$${NOMAD_VERSION}_SHA256SUMS_relevant

# Unzip and install the binary
mkdir bin
pushd bin
unzip ../nomad_$${NOMAD_VERSION}_linux_$${NOMAD_ARCH}.zip
sudo install -o root -g root -m 755 nomad /usr/local/bin/nomad

# Generate the server configuration
sudo yum install -y jq
INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_AZ=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
cat > /tmp/nomad/nomad.conf <<- EOF
data_dir           = "/var/lib/nomad"
bind_addr          = "0.0.0.0"
enable_syslog      = false

# TODO: Enable for production
#leave_on_terminate = true

datacenter         = "$${NOMAD_DATACENTER}"
region             = "$${REGION}"
name               = "$${INSTANCE_ID}"

server {
  enabled          = true
  bootstrap_expect = $${NOMAD_EXPECT}
  server_join {
    retry_join = ["provider=aws tag_key=nomad:discover tag_value=$${NOMAD_DISCOVER} addr_type=private_v4"]
  }
}
EOF
sudo install -o root -g root -m 700 -d /var/lib/nomad
sudo install -o root -g root -m 700 /tmp/nomad/nomad.conf /etc/nomad.conf

# Generate the systemd service
cat > /tmp/nomad/nomad.service <<- EOF
[Unit]
Description=HashiCorp Nomad Server
After=network.target

[Service]
Type=simple
Restart=always
RestartSec=10
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.conf

[Install]
WantedBy=multi-user.target
EOF
sudo install -o root -g root -m 644 /tmp/nomad/nomad.service /etc/systemd/system/nomad.service
sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl start nomad
