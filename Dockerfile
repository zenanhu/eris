FROM node:alpine

WORKDIR /home/node/app
COPY ./package.json /home/node/app/package.json

RUN pwd
RUN npm install

