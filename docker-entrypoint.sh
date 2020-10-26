#!/usr/bin/env bash

AWS_DEFAULT_REGION=${FOUNDRYVTT_DATA_S3_BUCKET_REGION}

if [ -n "${FOUNDRYVTT_DATA_S3_ACCESS_KEY_ID}" ] && [ -n "${FOUNDRYVTT_DATA_S3_SECRET_ACCESS_KEY}" ]; then
    echo "${FOUNDRYVTT_DATA_S3_ACCESS_KEY_ID}:${FOUNDRYVTT_DATA_S3_SECRET_ACCESS_KEY}" > /foundrvtt/.passwd-s3fs
    chmod 600 /foundrvtt/.passwd-s3fs
    S3FS_EXTRA_ARGS="-o passwd_file=/foundrvtt/.passwd-s3fs"
fi

if [ -n "${FOUNDRYVTT_DATA_S3_BUCKET_NAME}" ]; then
    s3fs ${FOUNDRYVTT_DATA_S3_BUCKET_NAME} /foundrvtt/data ${S3FS_EXTRA_ARGS}
else
    mkdir -p /foundrvtt/data
fi

${@}