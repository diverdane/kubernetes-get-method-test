FROM ruby:2.5.0
RUN gem update --system
RUN gem install kubeclient -v 3.1.2
RUN mkdir /src
COPY ./kubernetes_get_method.rb /src/
WORKDIR /src
ENTRYPOINT ["ruby", "/src/kubernetes_get_method.rb"]
