FROM rocker/ml

USER root

# Install common softwares
RUN apt-get -y update && \ 
    curl -s https://raw.githubusercontent.com/InseeFrLab/onyxia/main/resources/common-software-docker-images.sh | bash -s && \
    apt-get -y install tini && \
    rm -rf /var/lib/apt/lists/*

ENV \
    # Change the locale
    LANG=fr_FR.UTF-8 \
    # option for include s3 support in arrow package
    LIBARROW_MINIMAL=false

RUN \
    # Add Shiny support
    bash /rocker_scripts/install_shiny_server.sh \
    # Install system librairies
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils software-properties-common \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-client \
        libpng++-dev \
        libudunits2-dev \
        libgdal-dev \
        curl \
        jq \
        bash-completion \
        gnupg2 \
        unixodbc \
        unixodbc-dev \
        odbc-postgresql \
        libsqliteodbc \
        alien \
        libsodium-dev \
        libsecret-1-dev \
        libarchive-dev \
        libglpk-dev \
#        chromium \
        ghostscript \
        fontconfig \
        fonts-symbola \
        fonts-noto \
        fonts-freefont-ttf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Handle localization
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=fr_FR.UTF-8

RUN kubectl completion bash >/etc/bash_completion.d/kubectl

RUN \
    R -e "update.packages(ask = 'no')" \
    && install2.r --error \
        RPostgreSQL \
        RSQLite \
        odbc \
        keyring \
        aws.s3 \
        Rglpk \
        paws \
        vaultr \
	    arrow \
    && installGithub.r \
        inseeFrLab/doremifasol \
        `# pkgs for PROPRE reproducible publications:` \
        rstudio/pagedown \
        spyrales/gouvdown \
        spyrales/gouvdown.fonts \
    && R -e "devtools::install_github('apache/spark@v$SPARK_VERSION', subdir='R/pkg')" \
    && find /usr/local/lib/R/site-library/gouvdown.fonts -name "*.ttf" -exec cp '{}' /usr/local/share/fonts \; \
    && fc-cache \
    && Rscript -e "gouvdown::check_fonts_in_r()"

VOLUME ["/home"]
