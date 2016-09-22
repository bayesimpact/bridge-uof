FROM ruby:2.2.3

MAINTAINER everett.wetchler@bayesimpact.org

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev
RUN gem install mailcatcher

EXPOSE 1025
EXPOSE 1080
#CMD ["/usr/local/bundle/bin/mailcatcher", "-f", "--ip", "0.0.0.0", "--http-ip", "0.0.0.0"]
CMD ["/usr/local/bundle/bin/mailcatcher", "-f"]
