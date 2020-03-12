## Consul
#################################################################
cat > /tmp/consul/consul.service <<- EOF
[Unit]
Description="HashiCorp Consul Server"
Wants=network-online.target
After=network-online.target

[Service]
ExecReload=/usr/local/bin/consul reload
KillMode=process
KillSignal=SIGTERM
TimeoutStopSec=60
LimitNOFILE=65536
Restart=on-failure
Type=notify
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent -config-file=/etc/consul.conf -config-format=hcl

[Install]
WantedBy=multi-user.target
EOF
sudo install -o root -g root -m 644 /tmp/consul/consul.service /etc/systemd/system/consul.service
sudo systemctl daemon-reload
sudo systemctl enable consul
sudo systemctl start consul

## Nomad
#################################################################
cat > /tmp/nomad/nomad.service <<- EOF
[Unit]
Description=HashiCorp Nomad Server
Wants=network-online.target
After=consul.service

[Service]
ExecReload=/bin/kill -HUP $MAINPID
ExecStartPre=-/sbin/iptables-restore /etc/iptables.harden
ExecStart=/usr/local/bin/nomad agent -config=/etc/nomad.conf
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=60
LimitNOFILE=infinity
LimitNPROC=infinity
Restart=on-failure
RestartSec=2
StartLimitBurst=3
TasksMax=infinity

[Install]
WantedBy=multi-user.target
EOF
sudo install -o root -g root -m 644 /tmp/nomad/nomad.service /etc/systemd/system/nomad.service
sudo systemctl daemon-reload
sudo systemctl enable nomad
sudo systemctl start nomad