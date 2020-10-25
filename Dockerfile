FROM debian:buster-slim

ARG FOUNDRYVTT_UID=1000
ARG FOUNDRYVTT_GID=1000
ARG FOUNDRYVTT_PATH=/foundryvtt
ARG FOUNDRYVTT_RELEASE_URL=dummy-url

ENV FOUNDRYVTT_PATH=${FOUNDRYVTT_PATH} \
    FOUNDRYVTT_DATA_S3_ACCESS_KEY_ID=dummy-access-key-id \
    FOUNDRYVTT_DATA_S3_SECRET_ACCESS_KEY=dummy-secret-access-key \
    FOUNDRYVTT_DATA_S3_BUCKET_NAME=dummy-bucket-name \
    FOUNDRYVTT_DATA_S3_BUCKET_REGION=dummy-bucket-region

RUN groupadd -g ${FOUNDRYVTT_GID} foundryvtt && \
    useradd -r -u ${FOUNDRYVTT_UID} -g foundryvtt foundryvtt

RUN apt-get update \
    && apt-get install -y \
       curl \
    && curl -sL  https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update \
    && apt-get install -y \
       nodejs \
       wget \
       unzip \
       s3fs

WORKDIR ${FOUNDRYVTT_PATH}/home

RUN wget -O ./foundryvtt.zip ${FOUNDRYVTT_RELEASE_URL} \
    && unzip ./foundryvtt.zip \
    && rm -f ./foundryvtt.zip

RUN chown -R foundryvtt:foundryvtt ${FOUNDRYVTT_PATH}

EXPOSE 30000

USER foundryvtt

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "${FOUNDRYVTT_PATH}/home/resources/app/main.js", "--port=30000", "--headless", "--noupdate", "--dataPath=${FOUNDRYVTT_PATH}/data" ]