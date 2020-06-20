ARG nginx_version=1.18.0
ARG node_version=14.3.0

FROM node:${node_version} as build

# Install dependencies
COPY ./frontend/package.json ./frontend/yarn.lock /app/

WORKDIR /app

RUN yarn install

# Build app
COPY ./frontend /app

RUN yarn test:unit \
 && yarn build

# Final
FROM survivorbat/nginx-jinja2:${nginx_version}

WORKDIR /var/www/html

COPY ./nginx /etc/nginx/temp
COPY --from=build /app/dist /var/www/html
