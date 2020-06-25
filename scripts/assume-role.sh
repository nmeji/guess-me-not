#!/bin/sh
"/opt/app/scripts/set-creds.sh"
aws sts assume-role --role-arn "arn:aws:iam::$AWS_ACCOUNT_ID:role/$AWS_ROLE" \
	--role-session-name AWSCLI-Session | egrep 'AccessKeyId|SecretAccessKey|SessionToken' \
	| awk '{ print $2 }' | sed -e 's/,$//' | sed -e :begin -e '$!N;s/\n/ /; tbegin' \
	| sed -E 's/(\S+)\s(\S+)\s(\S+)/export AWS_ACCESS_KEY_ID=\1\nexport AWS_SECRET_ACCESS_KEY=\2\nexport AWS_SESSION_TOKEN=\3/' \
  > ~/.aws_session
