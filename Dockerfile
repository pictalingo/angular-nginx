FROM ubuntu:18.04

MAINTAINER Dan Oleynik <dan@pictalingo.com>

RUN apt-get update

RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:nginx/stable
RUN apt-get install --no-install-recommends -y sudo nano curl nginx
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -

RUN apt-get update

RUN apt-get -y install nodejs
RUN npm install -g npm@latest

RUN apt-get remove -y software-properties-common
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm cache clean --force
RUN npm install typescript@3.9.6 --save
RUN npm install -g @angular/cli@10.0.1
RUN npm install --no-optional --no-shrinkwrap --no-package-lock

COPY . .

RUN ng build --prod

COPY ./nginx_default_settings /etc/nginx/sites-available/default

WORKDIR /var/www/html

RUN rm -r /usr/src/app

RUN npm cache clean --force
RUN apt-get -y remove nodejs

RUN rm -r /usr/lib/node_modules

RUN apt-get -y autoremove

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
