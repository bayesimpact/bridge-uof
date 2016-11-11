FROM bayesimpact/ruby-2.2.3-phantomjs

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /bridge-uof
WORKDIR /bridge-uof
COPY Gemfile /bridge-uof/Gemfile
COPY Gemfile.lock /bridge-uof/Gemfile.lock
RUN bundle install --with=test

COPY . /bridge-uof
RUN sed -i -e "s/localhost:/testdb:/" /bridge-uof/config/aws.yml
ENTRYPOINT ["bundle", "exec", "rspec", "--profile", "15", "--format", "documentation"]
