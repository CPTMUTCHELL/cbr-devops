FROM jenkins/jenkins:2.387.1-lts
USER root
RUN apt-get update && apt-get install -y maven && apt-get clean
RUN apt-get -y update && \
   apt-get -y install \
   apt-transport-https \
   ca-certificates \
   curl \
   gnupg \
   lsb-release \
   software-properties-common \
   nano

RUN curl -s https://deb.nodesource.com/setup_16.x | bash \
    && apt install nodejs -y

RUN npm install -g yarn
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"


RUN apt-get -y update && \
 apt-get -y install \
   docker-ce \
   docker-ce-cli \
   containerd.io

USER jenkins


ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
COPY plugins.txt /usr/share/jenkins/plugins.txt

RUN jenkins-plugin-cli -f /usr/share/jenkins/plugins.txt
COPY jenkins-casc.yaml /usr/local/jenkins-casc.yaml
ENV CASC_JENKINS_CONFIG /usr/local/jenkins-casc.yaml
