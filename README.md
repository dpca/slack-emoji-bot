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
