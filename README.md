[![Code Climate](https://codeclimate.com/github/dpca/slack-emoji-bot/badges/gpa.svg)](https://codeclimate.com/github/dpca/slack-emoji-bot)

* * *

# slack-emoji-bot

Simple bot that detects new Slack emoji added through
https://my.slack.com/customize/emoji and notifies a channel about them.
Intended to run on a schedule, such as every hour, using cron.

[Emoji-bot](emoji-bot.rb) uses the
[slack-ruby-client](https://github.com/slack-ruby/slack-ruby-client) gem to
easily interact with the Slack API. On initial run, the
[emoji.list](https://api.slack.com/methods/emoji.list) method is called and the
list of all emoji is saved in an `emoji.txt` file. Every subsequent time the
script is run, it asks Slack for the emoji list again and compares the existing
emoji and the new list. If any new emoji are found, the
[chat.postMessage](https://api.slack.com/methods/chat.postMessage) method is
called with a random response from `responses.txt` and the new emoji. Finally,
the new list of emoji are saved in `emoji.txt`.

## Running with Docker

The simplest way to run is with [docker](https://www.docker.com/), which will
check every hour for new emoji in a container:

```bash
docker build -t emoji-bot .
docker run -it -d \
  -e SLACK_API_TOKEN="$TOKEN" \
  -e SLACK_CHANNEL="#emojis" \
  -e SLACK_USERNAME="emoji-bot" \
  -e SLACK_ICON_EMOJI=":parrot:" \
  --name emoji-bot \
  emoji-bot
```

You can see if the container is up by using `docker ps`, and check its logs
with `docker logs emoji-bot`. Omit the `-d` option to run the docker container
in the foreground for development purposes.

You can request a token for testing purposes from
https://api.slack.com/docs/oauth-test-tokens but should use a bot token from
https://my.slack.com/services/new/bot for a real deployment. Read more about
bot users here: https://api.slack.com/bot-users

If not provided, SLACK_USERNAME defaults to "emoji-bot" and SLACK_ICON_EMOJI
defaults to [":parrot:"](http://cultofthepartyparrot.com/).

## Running locally

### Setup

First, you need to set your `SLACK_API_TOKEN` and `SLACK_CHANNEL` to message in
`.env`. Then, save initial emoji:

```
bundle install
./emoji-bot.rb --setup
```

### Run

```
./emoji-bot.rb
```

### Cron

You can run the emoji-bot automatically by adding something like the following
to your crontab (`crontab -e`):

```
0 * * * * cd /home/USER/slack-emoji-bot && /usr/local/bin/ruby emoji-bot.rb >> /home/USER/slack-emoji-bot/cronOutput.txt 2>&1
```
