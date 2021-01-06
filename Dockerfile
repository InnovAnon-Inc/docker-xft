FROM innovanon/doom-base as builder-02
USER root
COPY --from=innovanon/zlib       /tmp/zlib.txz       /tmp/
COPY --from=innovanon/bzip2      /tmp/bzip2.txz      /tmp/
COPY --from=innovanon/xz         /tmp/xz.txz         /tmp/
COPY --from=innovanon/libpng     /tmp/libpng.txz     /tmp/
COPY --from=innovanon/jpeg-turbo /tmp/jpeg-turbo.txz /tmp/
COPY --from=innovanon/xft        /tmp/xft.txz        /tmp/
RUN cat   /tmp/*.txz  \
  | tar Jxf - -i -C / \
 && rm -v /tmp/*.txz

FROM builder-02 as xft
ARG LFS=/mnt/lfs
USER lfs
RUN sleep 31 \
 && git clone --depth=1 --recursive       \
      https://gitlab.freedesktop.org/xorg/lib/libxft.git \
 && cd                      xft          \
 && ./autogen.sh                          \
 && ./configure                           \
 && make                                  \
 && make DESTDIR=/tmp/xft install        \
 && cd           /tmp/xft                \
 && tar acf        ../xft.txz .          \
 && rm -rf        $LFS/sources/xft

FROM scratch as final
COPY --from=xft /tmp/xft.txz /tmp/

