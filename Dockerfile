FROM hashicorp/terraform:latest

# install Docker CLI
# RUN apk update && \
#   apk add --no-cache docker-cli && \
#   apk add --no-cache docker-compose

# install glibc
ENV GLIBC_VER=2.34-r0
RUN apk --no-cache add binutils curl && \
  curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub && \
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
  curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
  apk add --no-cache --force-overwrite glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk

# install awscliv2
RUN curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
  unzip -q awscliv2.zip && \
  aws/install

# install npm
RUN apk add --update npm

# install openssl
RUN apk add openssl

# install zip
RUN apk add zip

# install git
RUN apk add git
