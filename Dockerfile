ARG OS_NAME
ARG OS_VERSION

FROM ${OS_NAME}:${OS_VERSION} as frr-builder

ARG FRR_TAG
ARG RTR_TAG
ARG LIBYANG_VERSION
ARG LIBYANG_BUILD
ARG LIBYANG_BUILD_ID

ENV LIBYANG_URL=https://ci1.netdef.org/artifact/LIBYANG-YANGRELEASE/shared \
    LIBYANG_DEV_PKG=libyang-dev_${LIBYANG_VERSION}.${LIBYANG_BUILD_ID}_amd64.deb \
    LIBYANG_PKG=libyang${LIBYANG_VERSION}_${LIBYANG_VERSION}.${LIBYANG_BUILD_ID}_amd64.deb \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /artifacts
RUN set -ex \
 && apt-get update --quiet=2 \
 && apt-get install --quiet=2 --no-install-recommends ca-certificates curl \
 && curl -fLOOS ${LIBYANG_URL}/build-${LIBYANG_BUILD}/Debian-AMD64-Packages/${LIBYANG_DEV_PKG} \
 && curl -fLOOS ${LIBYANG_URL}/build-${LIBYANG_BUILD}/Debian-AMD64-Packages/${LIBYANG_PKG} \
 && apt-get install --quiet --quiet --no-install-recommends \
    debhelper \
    devscripts \
    equivs \
   ./${LIBYANG_DEV_PKG} \
   ./${LIBYANG_PKG} \
    fakeroot \
    git

RUN set -ex \
 && git clone https://github.com/rtrlib/rtrlib.git \
 && cd rtrlib \
 && git checkout ${RTR_TAG} \
 && echo "yes" | mk-build-deps --install debian/control \
 && dpkg-buildpackage 1>/dev/null \
 && cd - \
 && apt-get install --quiet=2 ./librtr0*.deb ./librtr-dev*.deb
# Package Debian as of:
# http://docs.frrouting.org/projects/dev-guide/en/latest/packaging-debian.html
# Activated build flags can be checked later on with: bash -c 'vtysh -c "show version"'

WORKDIR /artifacts
RUN set -ex \
 && git clone https://github.com/frrouting/frr.git frr \
 && cd frr \
 && git checkout ${FRR_TAG} \
 && echo "yes" | mk-build-deps --install debian/control \
 && sed -i '/--enable-bgp-vnc/a --enable-cumulus=yes \\' debian/rules \
 && sed -i '/--enable-bgp-vnc/a --enable-datacenter=yes \\' debian/rules \
 && git config --global user.email "ci@metal-stack.io" \
 && git config --global user.name "metal stack" \
 && git commit -m "Activate cumulus datacenter defaults." debian/rules \
 && ./tools/tarsource.sh -V \
 && dpkg-buildpackage 1>/dev/null

FROM scratch
WORKDIR /artifacts
COPY --from=frr-builder /artifacts/*.deb /artifacts/
