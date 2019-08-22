FROM ubuntu:16.04

ENV HIVE_VERSION 2.3.2
ENV BDLCL_VERSION 0.13.3
ENV HADOOP_VERSION 2.9.2

ENV HIVE_HOME /opt/apache-hive-$HIVE_VERSION-bin
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION
ENV BDLCL_HOME /opt/bigstepdatalake-$BDLCL_VERSION
ENV JAVA_HOME /usr
ENV PATH=$PATH:$HADOOP_HOME:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME:$HIVE_HOME/bin:$BDLCL_HOME/bin:$JAVA_HOME

RUN apt-get -y update && \
    apt-get install -y wget openjdk-8-jre vim
    
RUN cd /opt && \
    #Install hadoop
    wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    tar xzvf hadoop-$HADOOP_VERSION.tar.gz && \
    rm -rf hadoop-$HADOOP_VERSION.tar.gz && \
    
    #Install bdl client libraries
    wget https://repo.lentiq.com/bigstepdatalake-$BDLCL_VERSION-bin.tar.gz && \
    tar xzvf bigstepdatalake-$BDLCL_VERSION-bin.tar.gz && \
    rm -rf bigstepdatalake-$BDLCL_VERSION-bin.tar.gz && \
    
    #Install hive
    wget https://archive.apache.org/dist/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz && \
    tar xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
    rm -rf apache-hive-$HIVE_VERSION-bin.tar.gz && \

    #make sure all libraries are in the correct classpath
    cp $BDLCL_HOME/lib/* $HIVE_HOME/lib/ && \
    wget https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar -P $HIVE_HOME/lib/ && \
    cp $BDLCL_HOME/lib/* $HADOOP_HOME/share/hadoop/common/lib/ && \
    wget http://central.maven.org/maven2/com/lmax/disruptor/3.3.4/disruptor-3.3.4.jar && \
    cp /opt/disruptor-3.3.4.jar $BDLCL_HOME/lib/ && \
    cp /opt/disruptor-3.3.4.jar $HIVE_HOME/lib/ && \
    cp /opt/disruptor-3.3.4.jar $HADOOP_HOME/share/hadoop/common/lib/ && \
    
    #make sure all properties files are ok configured
    cp $HIVE_HOME/conf/hive-log4j2.properties.template $HIVE_HOME/conf/hive-log4j2.properties

#Add configuration files
ADD log4j2.xml.default $HADOOP_HOME/etc/hadoop/log4j2.xml
ADD core-site.xml.apiKey $HIVE_HOME/conf/core-site.xml.apiKey
ADD hive-site.xml $HIVE_HOME/conf/hive-site.xml
ADD entrypoint.sh /

RUN chmod 777 /entrypoint.sh

#        Hive Port  
EXPOSE    9083

ENTRYPOINT ["/entrypoint.sh"]
