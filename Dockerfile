FROM ruby:2.2.1-onbuild
RUN apt-get update && apt-get install -y nodejs

CMD jekyll serve --host 0.0.0.0
