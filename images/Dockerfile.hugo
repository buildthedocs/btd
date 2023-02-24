FROM python:3.8-alpine3.10 AS hugo
RUN apk --no-cache -U upgrade && apk --no-cache add ca-certificates curl py3-docutils git \
  && pip3 install rst2html5 \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v0.62.2/hugo_extended_0.62.2_Linux-64bit.tar.gz | tar zxvf - hugo -C /usr/local/bin
WORKDIR /src
EXPOSE 1313
ENTRYPOINT ["hugo"]
