FROM node:15-buster-slim as base

FROM base as builder

WORKDIR /foundryvtt/app

COPY ./foundryvtt-*.zip ./foundryvtt.zip

RUN apt-get update \
    && apt-get -y install unzip \
    && unzip ./foundryvtt.zip \
    && rm -f ./foundryvtt.zip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /foundryvtt

COPY ./docker-entrypoint.sh ./

WORKDIR /foundryvtt/state

FROM base as runtime

ARG FOUNDRYVTT_UID=999
ARG FOUNDRYVTT_GID=999

ENV AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="" \
    AWS_S3_STATE="false" \
    AWS_S3_STATE_BUCKET_NAME="" \
    AWS_S3_MEDIA="false"

WORKDIR /foundryvtt

RUN groupadd -g ${FOUNDRYVTT_GID} foundryvtt \
    && useradd -r -u ${FOUNDRYVTT_UID} -g foundryvtt foundryvtt

COPY ./requirements.txt ./

RUN apt-get update \
    && apt-get -y install python3 \
                          python3-pip \
    && pip3 install -r ./requirements.txt \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder \
     --chown=${FOUNDRYVTT_UID}:${FOUNDRYVTT_GID} \
     /foundryvtt ./

EXPOSE 30000

USER foundryvtt

ENTRYPOINT [ "./docker-entrypoint.sh" ]

CMD [ "node", "./app/resources/app/main.js", "--port=30000", "--headless", "--noupdate", "--dataPath=./state" ]