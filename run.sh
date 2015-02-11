echo 'Installing Python...'
sudo apt-get update -y
sudo apt-get install python unzip -y

echo 'Installing the AWS EB CLI...'
sudo pip install awsebcli

eb --version

echo 'Packaging...'
sbt dist

cd target/universal
unzip *.zip
cd $(find . -maxdepth 1 -mindepth 1 -type d | grep -v tmp)
rm -rf share/doc/

rm -vf bin/*.bat
exe_name=$(basename $(find bin/ -type f | head -n1))

java_version=${JAVA_VERSION:-8}
java_opts=${JAVA_OPTS:--Xmx512m}
port=${PORT:-80}

cat<<EOF > Dockerfile
FROM java:$java_version

ADD . /usr/local/play

ENV JAVA_OPTS $java_opts

EXPOSE $port
CMD ["/usr/local/play/bin/$exe_name", "-Dhttp.port=$port"]
EOF

echo 'Prepared Dockerfile'
cat Dockerfile

echo 'Preparing eb cli'
mkdir -vp .elasticbeanstalk
cat<<EOF > .elasticbeanstalk/config.yml
branch-defaults:
  default:
    environment: $ENVIRONMENT_NAME
global:
  application_name: $APPLICATION_NAME
  default_region: $AWS_REGION
  profile: default
EOF

mkdir -vp ~/.aws
cat<<EOF > ~/.aws/credentials
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_KEY
EOF

eb list -v
eb status -v

echo 'Deploy...'
eb deploy -v -m "Deploy from Wercker: $WERCKER_DEPLOY_URL"
eb status -v
