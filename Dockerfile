FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY ./src/index.html /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
