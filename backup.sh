#!/bin/sh
set -e

rclone_s3() {
    rclone \
        --s3-endpoint "$S3_ENDPOINT" \
        --s3-region "$S3_REGION" \
        --s3-access-key-id "$S3_ACCESS_KEY_ID" \
        --s3-secret-access-key "$S3_SECRET_ACCESS_KEY" \
        --s3-no-head \
        --s3-no-check-bucket \
        --s3-disable-http2 \
        --s3-disable-checksum \
        --s3-chunk-size 1G \
        --s3-upload-concurrency 16 \
        --ignore-times \
        --fast-list \
        --links \
        --checkers=32 \
        --transfers=128 \
        --stats-log-level NOTICE \
        --stats=10s \
        $@
}

TIMESTAMP=$(date '+%Y-%-m-%d')
remote_path=":s3:${S3_BUCKET:-"bucket"}/$APP_NAME/$DB_INSTANCE_NAME/$DB_NAME/$TIMESTAMP"

PGPASSWORD=$DB_PASSWORD pg_dump \
    -h $DB_HOST \
    --no-publications \
    --no-owner \
    -U $DB_USERNAME \
    -O -x -Fc $DB_NAME |
    rclone_s3 rcat "$remote_path"
