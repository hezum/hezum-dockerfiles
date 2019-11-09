FROM elixir:1.9

# Update Base
RUN apt-get update \
  && apt-get upgrade -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

# Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Imagemagick
RUN apt-get update \
  && apt-get install -y ghostscript \
  && rm -rf /var/lib/apt/lists/*

# Ghostscript
RUN apt-get update \
  && apt-get install -y ghostscript \
  && rm -rf /var/lib/apt/lists/*

# Postgres Client
RUN touch /etc/apt/sources.list.d/pgdg.list && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update \
  && apt-get install -y postgresql-client-11 \ 
  && rm -rf /var/lib/apt/lists/*

# wkhtmltopdf
RUN apt-get update \
  && apt-get install -y \
    ca-certificates \
    wget \
    fontconfig \
    libfreetype6 \
    libjpeg62-turbo \
    libpng16-16 \
    libx11-6 \
    libxcb1 \
    libxext6 \
    libxrender1 \
    xfonts-75dpi \
    xfonts-base \
  && rm -rf /var/lib/apt/lists/*
RUN wget -nv https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN apt-get purge -y --auto-remove wget xz-utils \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm wkhtmltox_0.12.5-1.stretch_amd64.deb

# Sobelow
RUN mix archive.install hex sobelow --force

# Node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get update \
  && apt-get install -y \
    nodejs \
    gcc \
    g++ \
    make \
  && rm -rf /var/lib/apt/lists/*

# Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt update \
  && apt install -y yarn \
  && rm -rf /var/lib/apt/lists/*

# Google Cloud SDK
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH /root/google-cloud-sdk/bin:$PATH
RUN gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image && \
  gcloud --version