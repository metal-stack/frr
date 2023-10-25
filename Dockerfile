ARG OS_NAME
ARG OS_VERSION

FROM ${OS_NAME}:${OS_VERSION} as frr-builder

ARG FRR_TAG
ARG RTR_TAG
ARG LIBYANG_URL
ARG LIBYANG_DEV_PKG
ARG LIBYANG_PKG

ENV DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /artifacts
RUN set -ex \
 && apt-get update --quiet=2 \
 && apt-get install --quiet=2 --no-install-recommends ca-certificates curl \
 && curl -fLOOS ${LIBYANG_URL}/${LIBYANG_DEV_PKG} \
 && curl -fLOOS ${LIBYANG_URL}/${LIBYANG_PKG} \
 && apt-get install --quiet=2 --no-install-recommends \
    debhelper \
    devscripts \
    equivs \
   ./${LIBYANG_DEV_PKG} \
   ./${LIBYANG_PKG} \
    fakeroot \
    git \
    librtr-dev

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
 && (./tools/tarsource.sh -V || true) \
 # # FIX for
 # dh_install: warning: Cannot find (any matches for) "doc/user/_build/texinfo/*.png" (tried in ., debian/tmp)
 && mkdir -p  doc/user/_build/texinfo && touch doc/user/_build/texinfo/fake.png \
 && dpkg-buildpackage -b 1>/dev/null

FROM scratch
WORKDIR /artifacts
COPY --from=frr-builder /artifacts/*.deb /artifacts/
