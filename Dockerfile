FROM ubuntu:16.04

MAINTAINER "Sebastian Wilzbach <seb@wilzba.ch>"

RUN apt-get update && apt-get install --no-install-recommends -y \
	aria2 \
	ca-certificates \
	curl \
	gcc \
	gnupg \
	libc-dev \
	libxml2 \
	make \
	patch \
	xz-utils \
 && curl -L -O https://dlang.org/install.sh \
 && bash install.sh -p /work install ldc-1.26.0

COPY ae /work/build/ae
COPY misc /work/build/misc
COPY Makefile *.patch /work/build/

RUN . /work/ldc*/activate \
 && make -C /work/build \
 && mkdir -p /dlang \
 && cp /work/build/bin/dver /dlang/dver \
 && cp /work/build/bin/dreg /dlang/dreg \
# If required by further steps
#  && mv /work/ldc* /ldc \
#  && chmod a=+rx /ldc \
 && rm -rf /work \
 && apt-get remove -y \
	make \
	patch

# ENV PATH=/ldc/bin:${PATH}

RUN for ver in \
		#2.051 2.052 2.053 2.054 2.055 2.056 2.057 2.058 2.059 \
		2.060 2.061 2.062 2.063 2.064 2.065.0 2.066.0 2.067.1 2.068.2 2.069.2 \
		2.070.2 2.071.2 2.072.2 2.073.2 2.074.1 2.075.1 2.076.1 2.077.1 2.078.1 2.079.1 \
		2.080.1 2.081.2 2.082.1 2.083.1 2.084.1 2.085.1 2.086.1 2.087.1 2.088.1 2.089.1 \
		2.090.1 2.091.1 2.092.1 2.093.1 2.094.1 2.095.1 2.096.1 2.097.0 \
	; do /dlang/dver -d $ver echo downloaded $ver ; done \
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
