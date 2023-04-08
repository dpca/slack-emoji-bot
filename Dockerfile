FROM ruby:3.2-alpine

RUN gem install bundler:2.4.10

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock /usr/src/app
RUN bundle install

COPY cron /var/spool/cron/crontabs/root
COPY entrypoint.sh emoji-bot.rb responses.txt /usr/src/app

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
CMD ["crond", "-f"]
