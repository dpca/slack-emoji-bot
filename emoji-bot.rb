#!/usr/bin/env ruby

# frozen_string_literal: true

require 'logger'
require 'rubygems'
require 'bundler'
Bundler.require(:default)

Dotenv.load

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end

Log = Logger.new(STDOUT)

# Saves and loads local emoji to/from emoji.txt
class LocalEmoji
  def self.load
    Set.new(File.readlines(file).map(&:strip))
  end

  def self.save(emoji)
    File.open(file, 'w') do |f|
      f.puts emoji.to_a
    end
  end

  def self.exists?
    File.exist?(file)
  end

  def self.file
    "#{__dir__}/emoji.txt"
  end
end

# Loads emoji from Slack
class SlackEmoji
  attr_reader :client

  def initialize(slack_client)
    @client = slack_client
  end

  def ok?
    response.ok
  end

  def emoji
    Set.new(response.emoji.keys)
  end

  def response
    @_response ||= client.emoji_list
  end
end

class Responses
  def self.random
    File.readlines(file).map(&:strip).sample
  end

  def self.file
    "#{__dir__}/responses.txt"
  end
end

# Messages Slack about new emoji
class SlackMessager
  attr_reader :client

  def initialize(slack_client)
    @client = slack_client
  end

  def send(new_emoji)
    client.chat_postMessage(
      channel: ENV['SLACK_CHANNEL'],
      text: channel_text(new_emoji),
      as_user: false,
      username: 'emoji-bot',
      icon_emoji: ':parrot:',
    )
  end

  private

  def channel_text(emojis)
    "#{Responses.random}  #{emojis.to_a.map { |txt| text_to_emoji(txt) }.join(' ')}"
  end

  def text_to_emoji(txt)
    ":#{txt}:"
  end
end

# Main object to tie everything together
class Bot
  attr_reader :client

  def initialize(slack_client)
    @client = slack_client
  end

  def run
    Log.info("Connection: #{client.auth_test}")
    if slack_emoji.ok?
      if new_emoji.any?
        Log.info("Messaging slack with new emoji: #{new_emoji.to_a.join(', ')}")
        message_slack
        Log.info('Saving emoji')
        save_emoji
      else
        Log.info('No new emoji')
      end
    else
      Log.warn("Oops, response from Slack was not ok: #{slack_emoji.response}")
    end
  end

  def save_emoji
    LocalEmoji.save(slack_emoji.emoji)
  end

  private

  def slack_emoji
    @_slack_emoji ||= SlackEmoji.new(client)
  end

  def new_emoji
    slack_emoji.emoji - LocalEmoji.load
  end

  def message_slack
    SlackMessager.new(client).send(new_emoji)
  end
end

# Use OptionParser to allow for initial setup where we just save emoji
options = {}

OptionParser.new do |opts|
  opts.banner = 'Usage ./emoji-bot.rb [options]'

  opts.on('-s', '--setup', 'Save initial set of emoji') do
    options[:setup] = true
  end

  opts.on('-h', '--help', 'Displays help') do
    puts opts
    exit
  end
end.parse!

bot = Bot.new(Slack::Web::Client.new)

if options[:setup]
  Log.info('Saving emoji')
  bot.save_emoji
elsif !LocalEmoji.exists?
  Log.warn('Oops! You need to run `./emoji-bot.rb --setup`')
else
  bot.run
end
