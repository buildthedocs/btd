FROM python:3.6-slim-stretch AS do-sphinx

RUN apt-get update -y && apt-get install -y git vim software-properties-common

# Install requirements
RUN apt-get -y install \
    git-core libpq-dev libxml2-dev libxslt-dev \
    libxslt1-dev build-essential curl \
    doxygen g++ graphviz-dev libfreetype6 libbz2-dev libcairo2-dev \
    libenchant1c2a libevent-dev libffi-dev libfreetype6-dev \
    libgraphviz-dev libjpeg62-turbo-dev liblcms2-dev libreadline-dev \
    libsqlite3-dev libtiff5-dev libwebp-dev pandoc pkg-config zlib1g-dev \
  && pip3 install sphinx recommonmark sphinx_rtd_theme

WORKDIR /src


FROM debian:stretch-slim AS do-latex

#texlive-fonts-extra texlive-latex-extra-doc texlive-publishers-doc texlive-pictures-doc texlive-lang-english texlive-lang-japanese

RUN apt-get update -y && apt-get -y install texlive-full texlive-fonts-recommended texlive-latex-extra-doc

WORKDIR /src
