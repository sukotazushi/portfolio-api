FROM ruby:4.0.1-slim

# RUN apt-get update -qq && apt-get install -y --no-install-recommends \
#   git \
#   build-essential \
#   default-libmysqlclient-dev \
#   pkg-config \
#   && rm -rf /var/lib/apt/lists/*
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git \
  build-essential \
  default-libmysqlclient-dev \
  pkg-config \
  libyaml-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install

COPY . .
