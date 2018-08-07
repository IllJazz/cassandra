FROM ruby:2.4.1

RUN gem install cassandra-web

RUN apt-get update && apt-get install dnsutils -y

ADD entrypoint.sh /

RUN chmod a+x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]