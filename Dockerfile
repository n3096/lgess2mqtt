FROM amd64/alpine:latest

WORKDIR /usr/share
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base \
        py3-pip \
        python3 \
     && pip install pyess

COPY docker/run.sh /
RUN ["ls", "/"]
RUN ["chmod", "+x", "/run.sh"]
CMD [ "/run.sh" ]