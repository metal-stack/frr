
# FRR

This project intentionally was created to be independent of the official apt repository at [https://deb.frrouting.org/](https://deb.frrouting.org/) that had a lot of downtimes in the past. Additionally there was the requirement to build from frr dev branch to have all EVPN features enabled that are required in metal environment to support dynamic route leaking.

## Consumers

These artifacts are used for:

- testing [metal-networker](https://github.com/metal-stack/metal-networker)
- building [metal images](https://github.com/metal-stack/metal-images)

The current build includes:

```yaml
  - name: FRR 7.5.0 for Ubuntu 20.04
    tags:
      - 7.5.0-ubuntu-20.04
    build-args:
      - FRR_TAG=frr-7.5
  - name: FRR 7.5.1 for Ubuntu 20.04
    tags:
      - 7.5.1-ubuntu-20.04
    build-args:
      - FRR_TAG=frr-7.5.1
  - name: FRR 7.5.0 for Debian 10
    tags:
      - 7.5.0-debian-10
    build-args:
      - FRR_TAG=frr-7.5
  - name: FRR 7.5.1 for Debian 10
    tags:
      - 7.5.1-debian-10
    build-args:
      - FRR_TAG=frr-7.5.1
```
