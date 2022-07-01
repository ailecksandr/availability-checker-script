# Availability Checker Script

Simple script for cron job that checks if something rare became available.

Imagine the situation that you want to go on some basketball match, but all tickets are already SOLD OUT.
You can either decline the idea to go at all or monitor the availability regularly by youself.
Such kind of script helps you to avoid sitting nearby the laptop & let the machine do this work instead.

**NB.** I have no goal to make it abstract, configurable, tested & polished, like generic Ruby gem. 
I did this only for my concrete life situation. 
In my head it sounded like a domestic problem, so I decided to create a repository for that.

Here I'll leave a few recommendations, about the usage & development of such stuff. 
Feel free to fork and modify up to your own needs.

## Prerequisites

- Your need to create a telegram bot - [using this bot](https://telegram.me/BotFather). 

    You need to get `API_TOKEN` of the bot.

- You need to create a telegram group.

    Bot should be added there and have admin rights. 
    You need to get `CHAT_ID` of the group - [using this bot](https://telegram.me/getidsbot).

- Ruby 3.0.2

- Chromedriver installed

## Setup locally

```bash
bundle install
MY_SITE_URL=X API_TOKEN=Y CHAT_ID=Z bundle exec ruby main.rb
```

## Advices & remarks

- Of course, take care about possible Captcha defense on your target website. 

    This is a curse of all scrappers & bots.

- Do not forget about rate limiting. Most likely you would need to avoid making checks instantly one by one.

    Investigate appropriate delay for you target website. 
    Start from the small delay, like 5 minutes, and increase it if website start blocking your requests.

- You can deploy script wherever you want.

    You can even define crontab on your own laptop. 
    I did it on Heroku to save money & do not kill my laptop by not turning it off at nights.

- If you have no control over the cron job intervals - the smallest interval and handle it manually.

    It happened to me with Heroku Scheduler add-on. In my case it was 10 minutes interval and I defined 
    to run the script only at `0-10 and 40-50 minutes` and skip full execution at other minutes.

## Setup on Heroku

Heroku provides you the server instance hours for free. We're going to use them.

- Create project on Heroku

- Setup necessary buildpacks (noted my list below)

- Setup necessary add-ons (noted my list below)

- Set environment variables

- Deploy your script to Heroku

- Scale down `web` dyno to 0. 

    We're going to use only scheduled job, main dyno is not needed for us to waste our free hours.

### Heroku Buildpacks

- heroku/ruby

- https://github.com/heroku/heroku-buildpack-google-chrome.git

### Heroku Add-Ons

- [Heroku Scheduler](https://elements.heroku.com/addons/scheduler)

    Takes care about cron jobs scheduling; has limited variations of delay & its delay is not reliable. 
    THOUGH it does not use extra dyno hours as Heroku Clock dyno would do. 
    Just for script execution and no more, that's what we need.

- [Papertrail](https://elements.heroku.com/addons/papertrail)

    Logger, helps to debug ambiguous situations and log what's really happening on script execution. 
    It's free, so why not.

## License

The code is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
