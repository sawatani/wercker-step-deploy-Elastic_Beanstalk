type eb || (\
	echo 'Installing Python...' &&\
	sudo apt-get update -y &&\
	sudo apt-get install python-pip -y &&\
	sudo pip install awsebcli \
)
eb --version

type unzip || (\
	echo 'Installing unzip...' &&\
	sudo apt-get update -y &&\
	sudo apt-get install unzip -y \
)

echo; echo 'Packaging...'
cd target/universal
unzip *.zip
cd $(find . -maxdepth 1 -mindepth 1 -type d | grep -v tmp)

rm -rf share/doc/
rm -vf bin/*.bat
exec_name="$(basename $(find bin/ -type f | head -n1))"
mv -vf bin/"$exec_name" bin/run

name="$(basename $(pwd))"
version="${WERCKER_GIT_COMMIT:0:7}${name:${#exec_name}}"

port=${WERCKER_PLAYFRAMEWORK_AWS_EB_PORT:-80}

cat<<EOF > Dockerfile
FROM java:$WERCKER_PLAYFRAMEWORK_AWS_EB_JAVA_VERSION

ADD . /play

ENV JAVA_OPTS ${WERCKER_PLAYFRAMEWORK_AWS_EB_JAVA_OPTS:--Xmx512m}

EXPOSE $port
CMD ["/play/bin/run", "-Dhttp.port=$port"]
EOF

echo; echo 'Prepared Dockerfile'
cat Dockerfile

echo; echo 'Preparing eb cli'
mkdir -vp .elasticbeanstalk
cat<<EOF > .elasticbeanstalk/config.yml
branch-defaults:
  default:
    environment: $WERCKER_PLAYFRAMEWORK_AWS_EB_ENVIRONMENT_NAME
global:
  application_name: $WERCKER_PLAYFRAMEWORK_AWS_EB_APPLICATION_NAME
  default_region: $WERCKER_PLAYFRAMEWORK_AWS_EB_REGION
EOF

export AWS_ACCESS_KEY_ID="$WERCKER_PLAYFRAMEWORK_AWS_EB_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="$WERCKER_PLAYFRAMEWORK_AWS_EB_SECRET_KEY"

eb list -v
eb status -v

echo; echo 'Deploy...'
eb deploy -v --label "$version" --message "Deployed by Wercker: $WERCKER_DEPLOY_URL"
eb status -v
