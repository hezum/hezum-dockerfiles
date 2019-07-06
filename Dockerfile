FROM circleci/elixir:1.9-node

# Update Base
RUN sudo apt-get update \
  && sudo apt-get upgrade -y --no-install-recommends

# Ansible
RUN sudo apt-get install -y python-setuptools python-pip
RUN sudo easy_install pip
RUN sudo pip install ansible

# Imagemagick
RUN sudo apt-get install -y imagemagick libmagick++-dev

# Ghostscript
RUN sudo apt-get install -y ghostscript

# Postgres Client
RUN sudo touch /etc/apt/sources.list.d/pgdg.list && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | sudo tee -a /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN sudo apt-get update
RUN sudo apt-get install -y postgresql-client-11

# wkhtmltopdf
RUN sudo apt-get install -y ca-certificates wget fontconfig libfreetype6 libjpeg62-turbo libpng16-16 libx11-6 libxcb1 libxext6 libxrender1 xfonts-75dpi xfonts-base
RUN sudo wget -nv https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN sudo dpkg -i wkhtmltox_0.12.5-1.stretch_amd64.deb
RUN sudo apt-get purge -y --auto-remove wget xz-utils \
	&& sudo rm -rf /var/lib/apt/lists/* \
	&& sudo rm wkhtmltox_0.12.5-1.stretch_amd64.deb

# Hex + Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Sobelow
RUN mix archive.install hex sobelow --force

# Google Cloud SDK
RUN curl -sSL https://sdk.cloud.google.com | bash

ENV PATH /home/circleci/google-cloud-sdk/bin:$PATH
RUN gcloud config set core/disable_usage_reporting true && \
  gcloud config set component_manager/disable_update_check true && \
  gcloud config set metrics/environment github_docker_image && \
  gcloud --version
