FROM rocker/rstudio:4.4.1

RUN apt update && apt install -y \
    libmagick++-dev \
    tk \
    locales \
    openssh-client \
    libxt-dev \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# locale & timezone
ENV LANG ja_JP.UTF-8
ENV LC_ALL ja_JP.UTF-8
RUN sed -i '$d' /etc/locale.gen \
    && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen ja_JP.UTF-8 \
    && /usr/sbin/update-locale LANG=ja_JP.UTF-8 LANGUAGE="ja_JP:ja"
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

COPY --chown=rstudio:rstudio .config/.rstudio/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
COPY --chown=rstudio:rstudio /.vscode/_settings.json /home/rstudio/.vscode-server/data/Machine/settings.json

# R Package
RUN R -e "install.packages(c('renv'))"

# Julia
ENV JULIA_MINOR_VERSION=1.11
ENV JULIA_PATCH_VERSION=1

RUN wget https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_MINOR_VERSION}/julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    tar xvf julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    rm julia-${JULIA_MINOR_VERSION}.${JULIA_PATCH_VERSION}-linux-x86_64.tar.gz && \
    ln -s $(pwd)/julia-$JULIA_MINOR_VERSION.$JULIA_PATCH_VERSION/bin/julia /usr/bin/julia

# DVC Path
ENV PATH $PATH:~/.cache/pip/bin

# Quarto
ENV QUARTO_MINOR_VERSION=1.6
ENV QUARTO_PATCH_VERSION=30

RUN wget -O quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}/quarto-${QUARTO_MINOR_VERSION}.${QUARTO_PATCH_VERSION}-linux-amd64.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# Package Cahce & Permission
RUN cd /home/rstudio && mkdir .cache .TinyTeX && \
    chown rstudio:rstudio .cache .TinyTeX
