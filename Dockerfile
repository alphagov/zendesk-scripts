FROM ruby:2.6.4-slim-stretch

WORKDIR /usr/src/app

# RUN apt-get install bash
RUN apt-get update
RUN apt-get -y install git

RUN cd $WORKDIR
RUN pwd

RUN git clone https://github.com/alphagov/zendesk-scripts.git .

# RUN bundle install
