FROM debian:buster-slim AS latex
RUN apt-get update -y && apt-get -y install make texlive-full texlive-fonts-recommended texlive-latex-extra-doc
WORKDIR /src

#---

FROM latex AS texstudio
RUN apt-get update -y && apt-get -y install texstudio
WORKDIR /src

#---

FROM latex AS pandoc
RUN apt-get update -y && apt-get -y install pandoc pandoc-citeproc
