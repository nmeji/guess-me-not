#!/bin/sh

mkdir ~/.aws && echo -e "[default]\n\
aws_access_key_id=$ACCESS_KEY_ID\n\
aws_secret_access_key=$SECRET_ACCESS_KEY" > \
~/.aws/credentials && echo -e "[default]\n\
region=$AWS_REGION" > ~/.aws/config
