[![Code Climate](https://codeclimate.com/github/dpca/slack-emoji-bot/badges/gpa.svg)](https://codeclimate.com/github/dpca/slack-emoji-bot)

* * *

# slack-emoji-bot

Detects new slack emoji and posts about them in a channel

## Setup

First, you need to set your `SLACK_API_TOKEN` and `SLACK_CHANNEL` to message in
`.env`. Then, save initial emoji:

```
bundle install
./emoji-bot.rb --setup
```

## Run

```
./emoji-bot.rb
```

## Cron

You can run the emoji-bot automatically by adding something like the following
to your crontab (`crontab -e`):

```
0 * * * * cd /home/USER/slack-emoji-bot && /usr/local/bin/ruby emoji-bot.rb >> /home/USER/slack-emoji-bot/cronOutput.txt 2>&1
```
