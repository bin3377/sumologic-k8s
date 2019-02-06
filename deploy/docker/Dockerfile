FROM fluent/fluentd:v1.3-onbuild-1

# Use root account to use apk
USER root

RUN apk add --no-cache --update --virtual .build-deps sudo build-base ruby-dev \
       && gem install fluent-plugin-beats \
       && gem install fluent-plugin-sumologic_output \
       && gem sources --clear-all \
       && apk del .build-deps \
       && rm -rf /home/fluent/.gem/ruby/2.5.0/cache/*.gem

COPY ./plugins/* /fluentd/plugins/

USER fluent
