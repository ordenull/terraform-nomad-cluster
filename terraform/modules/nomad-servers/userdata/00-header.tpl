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
PROTECT_AWS_META=${protect_aws_metadata}

# Server specific
EXPECT_SERVERS=${expect_servers}
NOMAD_PORT_HTTP=${nomad_port_http}
CONSUL_PORT_HTTP=${consul_port_http}
NODE_GC_THRESHOLD=${node_gc_threshold}
JOB_GC_THRESHOLD=${job_gc_threshold}
