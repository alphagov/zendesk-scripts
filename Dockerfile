FROM ruby:2.6.4-slim-stretch

WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get -y install vim build-essential git curl python3-pip && \
    apt-get clean && \
    pip3 install awscli && \
    git clone https://github.com/alphagov/zendesk-scripts.git . && \
    bundle install
