#!/bin/bash

deployment_name=nexus-rnd

bosh -d ${deployment_name} deploy manifests/nexus.yml \
  -v deployment_name=${deployment_name} \
  --vars-file=vars/${deployment_name}-vars.yml \
  --no-redact --fix


