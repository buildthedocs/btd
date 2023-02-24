FROM ubuntu:focal AS bookdown

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    libpng-dev \
    libssl-dev \
    libxml2-dev \
    netbase \
    r-base \
    wget

RUN Rscript -e "install.packages('tinytex')" \
 -e "tinytex::install_tinytex()" \
 -e "install.packages('bookdown')" \
 -e "tinytex::tlmgr_install('koma-script')" \
 -e 'install.packages("rticles")' \
 -e 'install.packages("distill")'

RUN apt install -y pandoc pandoc-citeproc pandoc-citeproc-preamble
#pandoc-crossref
