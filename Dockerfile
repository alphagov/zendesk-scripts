FROM ruby:2.6.4-slim-stretch

WORKDIR /usr/src/app

RUN apt-get update && \
    apt-get -y install git && \
    apt-get clean

RUN cd $WORKDIR

RUN git clone https://github.com/alphagov/zendesk-scripts.git .
