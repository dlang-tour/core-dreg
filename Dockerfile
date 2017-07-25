FROM ubuntu:16.04

MAINTAINER "Sebastian Wilzbach <seb@wilzba.ch>"

COPY bin/dver /dlang/dver
COPY bin/dreg /dlang/dreg

# Every runs adds up to the execution time, so we don't run all old releases
RUN apt-get update && apt-get install --no-install-recommends -y \
	aria2 libc-dev gcc curl ca-certificates \ 
	&& for ver in \
		2.000 2.010 2.020 2.030 2.040 \
		2.050 2.052 2.054 2.056 2.058 \
		2.060 2.061 2.062 2.063 2.064 2.065.0 2.066.0 2.067.1 2.068.2 2.069.2 \
		2.070.2 2.071.2 2.072.2 2.073.2 2.074.1 2.075.0 \
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
