FROM rocker/ml-gpu
RUN userdel nobody
RUN groupadd --gid 99 nobody
RUN useradd nobody --uid 99 --home /home/nobody/ --create-home --groups nobody --gid nobody --shell /bin/bash
RUN echo "nobody ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV \

    # Change the locale
    LANG=fr_FR.UTF-8 


RUN \
    # Add Shiny support
    export ADD=shiny \
    && bash /etc/cont-init.d/add \
    
    # Install system librairies
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends apt-utils software-properties-common \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        openssh-client \
        libpng++-dev \
        libudunits2-dev \
        libgdal-dev \
        curl \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | apt-key add - \
    && add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/ \
    && sudo apt update -y \
    && apt install -y adoptopenjdk-8-hotspot \

    # Handle localization
    && cp /usr/share/zoneinfo/Europe/Paris /etc/localtime \
    && sed -i -e 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=fr_FR.UTF-8


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
        SparkR
    
    
VOLUME ["/home"]
