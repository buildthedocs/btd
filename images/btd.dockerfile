FROM python:alpine

COPY ./btd/requirements.txt /tmp/requirements.txt

RUN apk --no-cache -U upgrade \
 && apk --no-cache add ca-certificates curl dos2unix git zip \
 && curl -fsSL https://download.docker.com/linux/static/edge/x86_64/docker-18.06.3-ce.tgz | tar xvz --strip-components=1 docker/docker -C /usr/bin \
 && chmod +x /usr/bin/docker \
 && pip install -r /tmp/requirements.txt
