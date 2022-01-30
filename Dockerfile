# Base image providing the basic dependencies
# extended by the builder and final image
FROM ubuntu:16.04 as base

MAINTAINER "Sebastian Wilzbach <seb@wilzba.ch>"

RUN apt-get update && apt-get install --no-install-recommends -y \
	aria2 \
	ca-certificates \
	curl \
	gcc \
	libc-dev

# Temporary environment to build the tools
FROM base as builder

RUN apt-get install --no-install-recommends -y \
	gnupg \
	libxml2 \
	make \
	patch \
	xz-utils \
 && curl -L -O https://dlang.org/install.sh \
 && bash install.sh -p /work install ldc-1.26.0

COPY ae /work/build/ae
COPY misc /work/build/misc
COPY har /work/build/har
COPY Makefile *.patch /work/build/

RUN . /work/ldc*/activate \
 && make -C /work/build \
 && mkdir -p /dlang \
 && cp /work/build/bin/dver /dlang/dver \
 && cp /work/build/bin/dreg /dlang/dreg \
 && cp /work/build/bin/har /dlang/har \
# If required by further steps
#  && mv /work/ldc* /ldc \
#  && chmod a=+rx /ldc \
 && rm -rf /work

# Final image providing the collection of different compiler versions
FROM base as final

# ENV PATH=/ldc/bin:${PATH}

COPY --from=builder /dlang /dlang
COPY VERSIONS.txt ./

RUN while read -r ver ; do \
		/dlang/dver -d $ver echo downloaded $ver ; \
	done < VERSIONS.txt \
	&& find /dlang -name "*.zip" | xargs rm -rf \
 	&& find /dlang \( -type d -and \! -type l -and -path "*/bin32" -or -path "*/lib32" -or -path "*/html" \) | xargs rm -rf \
	&& find /dlang -name "dustmite" | xargs rm -rf \
	&& find /dlang -name "obj2asm" | xargs rm -rf \
	&& find /dlang -name "dub" | xargs rm -rf \
	&& find /dlang -name "dman" | xargs rm -rf \
	&& find /dlang -name "rdmd" | xargs rm -rf \
	&& find /dlang -name "ddemangle" | xargs rm -rf \
	&& find /dlang -name "dumpobj" | xargs rm -rf \
	&& apt-get auto-remove -y curl ca-certificates aria2

ENV PATH=/dlang:${PATH}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN mkdir /sandbox && chown nobody:nogroup /sandbox
USER nobody

ENTRYPOINT [ "/entrypoint.sh" ]
