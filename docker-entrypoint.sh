#!/usr/bin/env sh

sync_down() {
    echo "$(date) - Running sync down from S3"; aws s3 sync --delete s3://${AWS_S3_STATE_BUCKET_NAME}/ "/foundryvtt/state" > /dev/stdout 2>&1
}

sync_up() {
    echo "$(date) - Running sync up to S3"; aws s3 sync --delete "/foundryvtt/state/" s3://${AWS_S3_STATE_BUCKET_NAME} > /dev/stdout 2>&1
}

# if AWS_S3_STATE == true, set up sync from and to AWS_S3_STATE_BUCKET_NAME
if [ "${AWS_S3_STATE}" = "true" ]
then
    # initial download state from S3
    sync_down
    # schedule upload state to S3
    while sleep 30; do sync_up; done &
    # trap shutdown signals and upload state to S3
    trap 'sync_up' TERM INT HUP
fi

# if AWS_S3_MEDIA == true, set up FoundryVTT S3 File Storage Integration
if [ "${AWS_S3_MEDIA}" = "true" ]
then
    echo "$(date) - Create awsConfig.json"
    echo "{
      \"accessKeyId\": \"${AWS_ACCESS_KEY_ID}\",
      \"secretAccessKey\": \"${AWS_SECRET_ACCESS_KEY}\",
      \"region\": \"${AWS_DEFAULT_REGION}\"
    }" > /foundryvtt/state/Config/awsConfig.json
    echo "$(date) - Reconfigure options.json"
    sed -i 's/\("awsConfig":\s\)[^,]*/\1"awsConfig.json"/g' /foundryvtt/state/Config/options.json
fi

# execute the FoundryVTT server and send to the bg
exec "${@}" &

# wait for FoundryVTT server to exit
wait ${!}

# final upload state to S3 before close
if [ "${AWS_S3_STATE}" = "true" ]
then
    sync_up
fi