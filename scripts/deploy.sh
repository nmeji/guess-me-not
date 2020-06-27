#!/bin/sh
source ~/.aws_session
sam deploy \
	--region $AWS_REGION \
	--stack-name fun-quizlet \
	--s3-bucket niknik-serverless-deployments \
	--s3-prefix fun-quizlet \
  --capabilities CAPABILITY_IAM \
	--no-fail-on-empty-changeset \
	--parameter-overrides \
		"AwsACMCert=$AWS_ACM_CERTIFICATE" \
		"DomainName=$DOMAIN_NAME" \
		"AwsHostedZone=$AWS_HOSTED_ZONE" \
		"QuizTable=$QUIZ_EVENTS_TABLE" \
	>/dev/null
