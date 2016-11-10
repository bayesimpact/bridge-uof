# Build this Container by running from this dir:
#   docker build -t bayesimpact/bridge-uof .
FROM ruby:2.2.3

MAINTAINER everett.wetchler@bayesimpact.org

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /bridge-uof
WORKDIR /bridge-uof
COPY Gemfile /bridge-uof/Gemfile
COPY Gemfile.lock /bridge-uof/Gemfile.lock
RUN bundle install

COPY . /bridge-uof
RUN sed -i -e "s/localhost:/db:/" /bridge-uof/config/aws.yml
EXPOSE 80
CMD ["./precompile_and_serve.sh", "-b", "0.0.0.0", "-p", "80"]

# Label the image with the git commit.
ARG GIT_SHA1=non-git
LABEL org.bayesimpact.git=$GIT_SHA1
