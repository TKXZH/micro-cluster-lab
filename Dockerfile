FROM ubuntu:bionic

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV SPARK_HOME /opt/spark
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"
ENV HADOOP_VERSION 2.7.0


RUN apt-get update && \
    apt-get install -y wget nano openjdk-8-jdk ssh openssh-server

RUN wget -P /tmp/ https://archive.apache.org/dist/hadoop/common/hadoop-2.7.0/hadoop-2.7.0.tar.gz
RUN tar xvf /tmp/hadoop-2.7.0.tar.gz -C /tmp && \
	mv /tmp/hadoop-2.7.0 /opt/hadoop

RUN wget -P /tmp/ https://downloads.apache.org/spark/spark-2.4.7/spark-2.4.7-bin-hadoop2.7.tgz
RUN tar xvf /tmp/spark-2.4.7-bin-hadoop2.7.tgz -C /tmp && \
    mv /tmp/spark-2.4.7-bin-hadoop2.7 ${SPARK_HOME}

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
	chmod 600 ~/.ssh/authorized_keys
COPY /confs/config /root/.ssh
RUN chmod 600 /root/.ssh/config

COPY /confs/*.xml /opt/hadoop/etc/hadoop/
COPY /confs/slaves /opt/hadoop/etc/hadoop/
COPY /script_files/bootstrap.sh /
COPY /confs/spark-defaults.conf ${SPARK_HOME}/conf

RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment

EXPOSE 9000
EXPOSE 7077
EXPOSE 4040
EXPOSE 8020
EXPOSE 22

RUN mkdir lab

COPY datasets /root/lab/datasets

ENTRYPOINT ["/bin/bash", "bootstrap.sh"]
