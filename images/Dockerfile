#> SPHINX Python 2.7

FROM python:2.7-alpine3.7 AS do-sphinx__py2-min
COPY py_min_requirements.txt /
RUN apk --no-cache -U upgrade && apk --no-cache add git curl \
  && pip install -r /py_min_requirements.txt
WORKDIR /src

#---

FROM do-sphinx__py2-min AS do-sphinx__py2-base
COPY py_base_requirements.txt /
RUN pip install -r /py_base_requirements.txt

#---

FROM do-sphinx__py2-base AS do-sphinx__py2-featured
COPY py_featured_requirements.txt /
RUN pip install -r /py_featured_requirements.txt

#> SPHINX Python 3.6

FROM python:3.6-alpine3.7 AS do-sphinx__py3-min
COPY py_min_requirements.txt /
RUN apk --no-cache -U upgrade && apk --no-cache add git curl \
  && pip install -r /py_min_requirements.txt
WORKDIR /src

#---

FROM do-sphinx__py3-min AS do-sphinx__py3-base
COPY py_base_requirements.txt /
RUN pip install -r /py_base_requirements.txt

#---

FROM do-sphinx__py3-base AS do-sphinx__py3-featured
COPY py_featured_requirements.txt /
RUN pip install -r /py_featured_requirements.txt

#> LATEX

FROM debian:stretch-slim AS do-latex
RUN apt-get update -y && apt-get -y install texlive-full texlive-fonts-recommended texlive-latex-extra-doc
WORKDIR /src

#> PANDOC

FROM do-latex AS do-pandoc
RUN apt-get update -y && apt-get -y install pandoc

#> HUGO Python 3.6
# TODO https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8

FROM python:3.6-alpine3.7 AS do-hugo
RUN apk --no-cache -U upgrade && apk --no-cache add ca-certificates curl py3-docutils git \
  && pip3 install rst2html5 \
  && curl -L https://github.com/gohugoio/hugo/releases/download/v0.36.1/hugo_0.36.1_Linux-64bit.tar.gz | tar zxvf - hugo -C /usr/local/bin
WORKDIR /src
EXPOSE 1313
ENTRYPOINT ["hugo"]
