FROM alpine:3.10 as crystalbuilder
RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories
RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories
RUN apk add --update --no-cache --force-overwrite \
        crystal@edge \
        shards@edge \
        g++ \
        gc-dev \
        libunwind-dev \
        libxml2-dev \
        llvm8 \
        llvm8-dev \
        llvm8-libs \
        llvm8-static \
        make \
        musl-dev \
        openssl-dev \
        pcre-dev \
        readline-dev \
        yaml-dev \
        zlib-dev

WORKDIR /src

ADD . /src
COPY .env.dist /src/.env

RUN shards
RUN crystal build src/bot.cr --release --static -o bot
RUN crystal build src/api.cr --release --static -o api

# production environment

FROM nginx:mainline-alpine

RUN apk add --no-cache --update --force-overwrite \
	bash \
	supervisor

RUN rm -rf /tmp/* /var/cache/apk/*

ADD ./supervisord.conf /etc/

COPY --from=crystalbuilder /src/bot /app/bot
COPY --from=crystalbuilder /src/api /app/api

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]