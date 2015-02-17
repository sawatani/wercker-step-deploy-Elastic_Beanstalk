# Playframework-aws_eb
[![wercker status](https://app.wercker.com/status/f194882a1558f65c3cf8d493a813c78e/m "wercker status")](https://app.wercker.com/project/bykey/f194882a1558f65c3cf8d493a813c78e)

Wercker Step for deploy [Playframework](http://playframework.com) application to [AWS Elastic Beanstalk](http://aws.amazon.com/jp/elasticbeanstalk) and making app to run on [Netty](http://netty.io) by using [Docker](http://docker.io)

# Requirement

This step assumes that application is already be packaged by "sbt dist" command.

# Usage

## Arguments

| Name | Required | Default Value / Example | Description |
|---|:-:|---|---|
| port | N | 80 | Port number which listen to |
| java_opts | N | -Xmx512 | pass to Netty launcher |
| java_version | Y | 8 | Version tag for [Docker Java](https://registry.hub.docker.com/_/java/) |
| region | Y | us-east-1 | Region name which you want deploy |
| application-name | Y | TritonNote | Name of application in Elastic Beanstalk. |
| environment-name | Y | tritonnote-test | Environment name of application in Elastic Beanstalk.|
| acdess-key | Y | ASG9Q34QGA... | Credential to access Elastic Beanstalk |
| secret-key | Y | aljLIUoq3t+3tk... | Credential to access Elastic Beanstalk |
