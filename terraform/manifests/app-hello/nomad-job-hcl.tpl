job "hello" {
  datacenters = ["${target_datacenter}"]
  region      = "us-east-2"
  type        = "service"

  constraint {
    attribute = "$${node.class}"
    value      = "${target_nodeclass}"
  }

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "main" {
    count = ${replicas}

    constraint {
      operator  = "distinct_hosts"
      value     = "true"
    }

    task "http" {
      driver = "docker"
      config {
        image      = "${ecr_host}/xeraweb/hello:${version}"
        force_pull = true
        logging {
          type = "syslog"
          config {
            tag = "hello"
          }
        }
      }

      service {
        port = "http"
        check {
          type     = "http"
          path     = "${health_path}"
          interval = "10s"
          timeout  = "3s"
        }
      }

      resources {
        cpu    = 50
        memory = 50
        network {
          mbits = 1
          port "http" {
            static = ${frontend_port}
          }
        }
      }

    }
  }
}