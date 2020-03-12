#!/bin/bash

set -ex

## Configuration
#################################################################
ARCH=amd64
DISCOVER_TAG_VALUE=${discover_tag_value}
DATACENTER=${datacenter}
NOMAD_VERSION=${nomad_version}
CONSUL_VERSION=${consul_version}

# Hardening options
ENABLE_CONSUL_DNS=${enable_consul_dns}
PROTECT_CONSUL_API=${protect_consul_api}
PROTECT_HOST_SSH=${protect_host_ssh}
PROTECT_AWS_META=${protect_aws_metadata}
PROTECT_SERVICES=${protect_services}

# Client specific
NOMAD_NODECLASS=${nomad_nodeclass}
ECR_HOST=${aws_ecr_host}