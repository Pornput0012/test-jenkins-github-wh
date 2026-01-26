docker rm -f jenkins-blueocean && \
docker run --name jenkins-blueocean \
  --user root \
  --detach \
  --restart=on-failure \
  --network jenkins \
  --publish 8080:8080 --publish 50000:50000 \
  -v jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  myjenkins-blueocean:2.414.2
