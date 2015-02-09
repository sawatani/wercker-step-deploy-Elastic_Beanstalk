echo 'Installing Python...'
sudo apt-get update -y
sudo apt-get install python -y

echo 'Installing the AWS EB CLI...'
sudo pip install awsebcli

eb --version
