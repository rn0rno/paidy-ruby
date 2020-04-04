FROM ruby:2.6.6
RUN apt-get update -qq && apt-get install -y build-essential

RUN mkdir /paidy
WORKDIR /paidy

ADD Gemfile /paidy/Gemfile
ADD paidy.gemspec /paidy/paidy.gemspec
ADD lib/paidy/version.rb /paidy/lib/paidy/version.rb

RUN gem install bundler
RUN bundle install
