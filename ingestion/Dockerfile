FROM amazoncorretto:8-alpine-jdk
RUN apk --no-cache add curl

WORKDIR /opt/embulk
ENV EMBULK_HOME=/opt/embulk

COPY entrypoint.sh gem_plugins.txt ./

RUN curl -o embulk -L "https://github.com/embulk/embulk/releases/download/v0.11.5/embulk-0.11.5.jar" && chmod +x ./embulk
RUN curl -OL https://repo1.maven.org/maven2/org/jruby/jruby-complete/9.4.14.0/jruby-complete-9.4.14.0.jar
RUN echo "jruby=file:///opt/embulk/jruby-complete-9.4.14.0.jar" >> embulk.properties

RUN ./embulk gem install embulk && ./embulk gem install msgpack
RUN ./embulk gem install -g ./gem_plugins.txt --clear-sources
RUN curl --create-dirs -L -o ./drivers/postgresql-42.7.3.jar https://jdbc.postgresql.org/download/postgresql-42.7.3.jar

RUN chmod +x entrypoint.sh

ENTRYPOINT ["sh", "entrypoint.sh"]