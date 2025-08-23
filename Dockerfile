FROM ruby:3.3.0-slim

WORKDIR /usr/src/app

RUN apt-get update -qq && apt-get install -y build-essential

RUN gem install bundler

COPY Gemfile* ./

RUN bundle install

COPY . .

EXPOSE 9292