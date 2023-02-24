FROM ubuntu:focal AS bookdown

RUN apt-get update -qq \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    r-base \
    wget

RUN Rscript -e "install.packages('tinytex')" \
 && Rscript -e "tinytex::install_tinytex()" \
 && Rscript -e "install.packages('bookdown')" \
 && Rscript -e "tinytex::tlmgr_install('koma-script')"

RUN apt install -y pandoc pandoc-citeproc pandoc-citeproc-preamble
#pandoc-crossref
