## Emacs, make this -*- mode: sh; -*-

## start with the Docker 'base R' Debian-based image
FROM r-base:latest

LABEL org.label-schema.license="GPL-2.0" \
      org.label-schema.vcs-url="https://github.com/rocker-org/drp" \
      org.label-schema.vendor="Rocker Project" \
      maintainer="Dirk Eddelbuettel <edd@debian.org>"

## Remain current
RUN apt-get update -qq && apt-get dist-upgrade -y

## From the Build-Depends of the Debian R package, plus subversion
## Check out R-patched
## Build and install according the standard 'recipe' I emailed/posted years ago
## Set Renviron.site to get libs from base R install
## Clean up
## -- all in one command to get a single AUFS layer
RUN apt-get update -qq && \
        apt-get install -y -t unstable --no-install-recommends \
                bash-completion \
                bison \
                debhelper \
                default-jdk \
                g++ \
                gcc \
                gfortran \
                groff-base \
                libblas-dev \
                libbz2-dev \
                libcairo2-dev/unstable \
                libcurl4-openssl-dev/unstable \
                libfreetype6-dev/unstable \
    		libharfbuzz-dev/unstable \
                libjpeg-dev \
                liblapack-dev \
                liblzma-dev \
                libncurses5-dev \
                libpango1.0-dev/unstable \
                libpcre3-dev \
                libpng-dev \
                libreadline-dev \
                libtiff5-dev/unstable \
                libx11-dev \
                libxcb1-dev/unstable \
                libxdmcp-dev/unstable \
                libxt-dev \
                mpack \
                subversion \
                tcl8.6-dev \
                texinfo \
                texlive-base \
                texlive-fonts-recommended \
                texlive-generic-recommended \
                texlive-latex-base \
                texlive-latex-recommended \
                tk8.6-dev \
                x11proto-core-dev \
                xauth \
                xdg-utils \
                xfonts-base \
                xvfb \
                zlib1g-dev \
        && cd /tmp \
        && wget -q https://stat.ethz.ch/R/daily/R-patched.tar.bz2 \
        && tar xaf R-patched.tar.bz2 \
        && rm R-patched.tar.bz2

RUN  cd /tmp/R-patched && \
                R_PAPERSIZE=letter \
                R_BATCHSAVE="--no-save --no-restore" \
                R_BROWSER=xdg-open \
                PAGER=/usr/bin/pager \
                PERL=/usr/bin/perl \
                R_UNZIPCMD=/usr/bin/unzip \
                R_ZIPCMD=/usr/bin/zip \
                R_PRINTCMD=/usr/bin/lpr \
                LIBnn=lib \
                AWK=/usr/bin/awk \
                CFLAGS="$(R CMD config CFLAGS)" \
                CXXFLAGS="$(R CMD config CXXFLAGS)" \
                FFLAGS="$(R CMD config FFLAGS)" \
                ./configure --enable-R-shlib \
                	--enable-memory-profiling \
                        --with-blas \
                        --with-lapack \
                        --with-readline \
                        --without-recommended-packages \
                        --program-suffix=dev && \
                cd /tmp/R-patched && \
                make && \
                make install && \
                rm -rf /tmp/R-devel /tmp/downloaded_packages/ /tmp/*.rds

RUN echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" >> /usr/local/lib/R/etc/Renviron \
        && echo 'options("repos"="https://cloud.r-project.org")' >> /usr/local/lib/R/etc/Rprofile.site \
        && cd /usr/local/bin \
        && mv R Rpatched \
        && mv Rscript Rscriptpatched \
        && ln -s Rpatched RP \
        && ln -s Rscriptpatched RPscript

RUN dpkg --purge  \
     		dh-r \
                libblas-dev \
                libbz2-dev  \
                libcairo2-dev \
                libfontconfig1-dev \
                libfreetype6-dev \
                libjpeg-dev \
                liblapack-dev  \
                libncurses5-dev \
                libpango1.0-dev \
                libpng-dev \
                libreadline-dev \
                libtiff5-dev \
                libxft-dev \
                r-base-dev \
                tcl8.6-dev \
                texlive-base \
                texlive-fonts-recommended \
                texlive-generic-recommended \
                texlive-latex-base \
                texlive-latex-recommended \
                texlive-plain-generic \
                tk8.6-dev \
        && apt-get autoremove -qy \
        && rm -rf /tmp/R-patched

## Launch R-patched by defailt
CMD ["RP"]
