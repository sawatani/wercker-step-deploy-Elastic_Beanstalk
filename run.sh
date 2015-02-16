echo 'Installing Python...'
sudo apt-get update -y
sudo apt-get install python unzip -y

echo 'Installing the AWS EB CLI...'
sudo pip install awsebcli

eb --version

echo 'Packaging...'
java -version
sbt dist

cd target/universal
unzip *.zip
cd $(find . -maxdepth 1 -mindepth 1 -type d | grep -v tmp)
rm -rf share/doc/
rm -vf bin/*.bat
mv -vf "$(find bin/ -type f | head -n1)" bin/run

port=${WERCKER_PLAYFRAMEWORK_AWS_EB_PORT:-80}

cat<<EOF > Dockerfile
FROM java:$WERCKER_PLAYFRAMEWORK_AWS_EB_JAVA_VERSION

ADD . /usr/local/play

ENV JAVA_OPTS ${WERCKER_PLAYFRAMEWORK_AWS_EB_JAVA_OPTS:--Xmx512m}

EXPOSE $port
CMD ["/usr/local/play/bin/run", "-Dhttp.port=$port"]
EOF

echo 'Prepared Dockerfile'
cat Dockerfile

echo 'Preparing eb cli'
mkdir -vp .elasticbeanstalk
cat<<EOF > .elasticbeanstalk/config.yml
branch-defaults:
  default:
    environment: $WERCKER_PLAYFRAMEWORK_AWS_EB_ENVIRONMENT_NAME
global:
  application_name: $WERCKER_PLAYFRAMEWORK_AWS_EB_APPLICATION_NAME
  default_region: $WERCKER_PLAYFRAMEWORK_AWS_EB_REGION
  profile: default
EOF

export AWS_ACCESS_KEY_ID="$WERCKER_PLAYFRAMEWORK_AWS_EB_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$WERCKER_PLAYFRAMEWORK_AWS_EB_SECRET_KEY"

eb list -v
eb status -v

echo 'Deploy...'
eb deploy -v -m "Deployed by Wercker: $WERCKER_DEPLOY_URL"
eb status -v
