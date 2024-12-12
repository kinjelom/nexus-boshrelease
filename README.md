# BOSH Release for Nexus Repository Manager

Forked from [making/nexus-boshrelease](https://github.com/making/nexus-boshrelease), thanks!

Nexus Repository and Java versions: [blobs-versions.env](src/meta-info/blobs-versions.env)

## Configuring the Runtime Environment

https://help.sonatype.com/en/configuring-the-runtime-environment.html

```yaml
---
instance_groups:
- name: nexus-repo
  jobs:
  - name: nexus-repo
    release: nexus
    properties:
      nexus_repo:
        nexus_properties:
          application-port: 8080
          application-host: 0.0.0.0
          nexus-context-path: /
        nexus_vmoptions:
          - "-XX:+UseG1GC"
          - "-XX:+UnlockExperimentalVMOptions"
        envs:
          TEST_ENV1: abc
        java.home: "/var/vcap/packages/openjdk-17"
        java.mem_percentage: "70"
        java_util_logging_properties:
          ".level": INFO
```
For more details, see:
- [nexus-repo spec](jobs/nexus-repo/spec)
- [deployment manifests example](example/manifests/nexus.yml)

## TODO

- HA
- Docker Registry UI using https://github.com/Joxit/docker-registry-ui