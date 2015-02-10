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

rm -vf bin/*.bat
exe_name=$(basename $(find bin/ -type f | head -n1))

port=${PORT:-80}
exe_options=${EXE_OPTIONS:--Dhttp.port=$port}

cat<<EOF > Dockerfile
FROM java:8

ADD . /usr/local/play

ENV JAVA_OPTS $JAVA_OPTS

EXPOSE $port
CMD ["/usr/local/play/bin/$exe_name", "$exe_options"]
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
  application_name: $WERCKER_PLAYFRAMEWORK_AWS_EB_APPLICATION_NAME
  default_region: $AWS_REGION
  profile: default
EOF

mkdir -vp ~/.aws
cat<<EOF > ~/.aws/credentials
[default]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_KEY
EOF

echo ".elasticbeanstalk/config.yml"
cat .elasticbeanstalk/config.yml
echo
echo "~/.aws/credentials"
cat ~/.aws/credentials

eb list -v
eb status -v

echo 'Deploy...'
[ -x bin/$exe_name ] || exit 1
eb deploy -v
