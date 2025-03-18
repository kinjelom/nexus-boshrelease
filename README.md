# BOSH Release for Nexus Repository Manager

Forked from [making/nexus-boshrelease](https://github.com/making/nexus-boshrelease), thanks!

Nexus Repository and Java versions: [blobs-versions.env](src/meta-info/blobs-versions.env)

## Configuring the Runtime Environment

```yaml
---
instance_groups:
- name: nexus-repo
  jobs:
  - name: nexus-repo
    release: nexus
    properties:
      nexus_repo:
        secrets:
          active_key: secret_1
          keys:
            secret_1: ((nexus_repo_encryption_secret_1))
        additional_nexus_vmoptions:
          - "-Dnexus.datastore.enabled=true"
          - "-Dnexus.datastore.nexus.username=((nexus_db_user))"
          - "-Dnexus.datastore.nexus.password=((nexus_db_password))"
          - "-Dnexus.datastore.nexus.jdbcUrl=((nexus_jdbc_url))"
        envs:
          TEST_ENV1: abc
        java_util_logging_properties:
          ".level": INFO
variables:
  - name: nexus_repo_encryption_secret_1
    type: password
    options:
      length: 32
```
For more details, see:
- https://help.sonatype.com/en/configuring-the-runtime-environment.html
- [nexus-repo spec](jobs/nexus-repo/spec)
- [deployment manifests example](example/manifests/nexus.yml)

## TODO

- BBR
- Docker Registry UI using https://github.com/Joxit/docker-registry-ui
- Nexus IQ
- HA / PostgreSQL
