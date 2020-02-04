
# FRR

This project intentionally was created to be independent of the official apt repository at [https://deb.frrouting.org/](https://deb.frrouting.org/) that had a lot of downtimes in the past. Additionally there was the requirement to build from frr dev branch to have all EVPN features enabled that are required in metal environment to support dynamic route leaking.

## Consumers

These artifacts are used for:

- testing [metal-networker](https://github.com/metal-stack/metal-networker)
- building [metal images](https://github.com/metal-stack/metal-images)

The current build includes:

```yaml
- name: FRR-7.1 for Ubuntu 19.10
  build-args:
  - FRR_TAG=33abf43a3aadee243f704b7e8911b8e469c00338
  tags:
  - 7.1-ubuntu-19.10
  - 7-ubuntu-19.10

- name: FRR-7.2 for Ubuntu 19.10
  build-args:
  - FRR_TAG=frr-7.2.1
  tags:
  - 7.2.1-ubuntu-19.10
  - 7.2-ubuntu-19.10

- name: FRR-7.2 for Ubuntu 20.04
  build-args:
  - FRR_TAG=frr-7.2.1
  tags:
  - 7.2.1-ubuntu-20.04
  - 7.2-ubuntu-20.04

- name: FRR-7.2 for Debian 10
  build-args:
  - FRR_TAG=frr-7.2.1
  tags:
  - 7.2.1-debian-10
  - 7.2-debian-10
  - 7-debian-10
```
