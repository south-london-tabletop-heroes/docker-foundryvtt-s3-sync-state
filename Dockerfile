FROM debian:buster-slim

ARG FOUNDRYVTT_UID=1000
ARG FOUNDRYVTT_GID=1000

ENV FOUNDRYVTT_DATA_S3_ACCESS_KEY_ID="" \
    FOUNDRYVTT_DATA_S3_SECRET_ACCESS_KEY="" \
    FOUNDRYVTT_DATA_S3_BUCKET_NAME="" \
    FOUNDRYVTT_DATA_S3_BUCKET_REGION=""

RUN groupadd -g ${FOUNDRYVTT_GID} foundryvtt && \
    useradd -r -u ${FOUNDRYVTT_UID} -g foundryvtt foundryvtt

RUN apt-get update \
    && apt-get install -y \
       curl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y \
       nodejs \
       unzip \
       s3fs \
    && rm -rf /var/lib/apt/lists/*

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR /foundrvtt/home

COPY ./foundryvtt-*.zip ./foundryvtt.zip

RUN unzip ./foundryvtt.zip \
    && rm -f ./foundryvtt.zip

RUN chown -R foundryvtt:foundryvtt /foundrvtt

EXPOSE 30000

USER foundryvtt

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "node", "/foundrvtt/home/resources/app/main.js", "--port=30000", "--headless", "--noupdate", "--dataPath=/foundrvtt/data" ]