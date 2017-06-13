FROM ruby:2.4.0
RUN apt update -qy && apt install net-tools -yq
RUN mkdir -p /simple-actuator/
ADD . /simple-actuator/
WORKDIR /simple-actuator/
RUN bundle install
CMD [ "bundle", "exec", "rackup", "-p", "9292", "--host", "0.0.0.0" ]
