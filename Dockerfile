FROM alpine:3.18 as build

ARG RCLONE_VER=v1.64.0
ARG LINKERD_AWAIT_VERSION=v0.2.7
WORKDIR /app
RUN apk update && apk add postgresql curl unzip
RUN curl -O https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-amd64.zip
RUN unzip rclone-${RCLONE_VER}-linux-amd64.zip && rm rclone-${RCLONE_VER}-linux-amd64.zip
RUN curl -sSLo /tmp/linkerd-await https://github.com/linkerd/linkerd-await/releases/download/release%2F${LINKERD_AWAIT_VERSION}/linkerd-await-${LINKERD_AWAIT_VERSION}-amd64 && \
    chmod 755 /tmp/linkerd-await

FROM alpine:3.18
ARG RCLONE_VER=v1.64.0
RUN apk update && apk add postgresql
COPY --from=build /app/rclone-${RCLONE_VER}-linux-amd64/rclone /usr/local/bin/
COPY --from=build /tmp/linkerd-await /usr/local/bin/
ENTRYPOINT ["linkerd-await", "--shutdown", "--"]
