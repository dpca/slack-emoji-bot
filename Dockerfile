FROM ruby:2.3-alpine

RUN apk add --update --no-cache build-base openssl

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app
COPY Gemfile.lock /usr/src/app
RUN bundle install

COPY cron /var/spool/cron/crontabs/root
COPY . /usr/src/app

ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
CMD ["crond", "-f"]
