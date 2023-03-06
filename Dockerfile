
FROM debian:stable-slim

ENV TERRAGRUNT_VERSION="0.36.1"
ENV TERRAFORM_VERSION="1.1.6"

RUN apt-get update \
  && apt-get install -y \
    automake \
    g++ \
    gcc \
    git \
    libffi-dev \
    lsb-release \
    make \
    python3 \
    python3-dev \
    python3-pip \
    unzip \
    wget \
  && apt-get -y autoremove \
  && apt-get -y clean

RUN echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
  && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
  && apt-get update \
  && apt-get install -y libpq-dev

# AWSCLI
RUN pip3 install awscli --upgrade

# TERRAFORM
RUN cd /tmp \
  && wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && mv terraform /bin/terraform \
  && chmod +x /bin/terraform \
  && terraform version

# TERRAGRUNT
RUN wget "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
  && mv terragrunt_linux_amd64 /bin/terragrunt \
  && chmod +x /bin/terragrunt \
  && terragrunt --version

ENTRYPOINT ["terragrunt"]