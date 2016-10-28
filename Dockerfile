# Build this Container by running from this dir:
#   docker build -t bayesimpact/ursus .
FROM ruby:2.2.3

MAINTAINER everett.wetchler@bayesimpact.org

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /bridge
WORKDIR /bridge
COPY Gemfile /bridge/Gemfile
COPY Gemfile.lock /bridge/Gemfile.lock
RUN bundle install

COPY . /bridge
RUN sed -i -e "s/localhost:/db:/" /bridge/config/aws.yml
EXPOSE 80
CMD ["./precompile_and_serve.sh", "-b", "0.0.0.0", "-p", "80"]

# Label the image with the git commit.
ARG GIT_SHA1=non-git
LABEL org.bayesimpact.git=$GIT_SHA1
