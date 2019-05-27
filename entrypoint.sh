#!/bin/bash

echo 'export HIVE_VERSION=2.3.2' >> ~/.bashrc
echo 'export BDLCL_VERSION=0.12.1' >> ~/.bashrc
echo 'export HADOOP_VERSION=2.7.6' >> ~/.bashrc

echo 'export HIVE_HOME=/opt/apache-hive-$HIVE_VERSION-bin' >> ~/.bashrc
echo 'export HADOOP_HOME=/opt/hadoop-$HADOOP_HOME' >> ~/.bashrc
echo 'export BDLCL_HOME=/opt/bigstepdatalake-$BDLCL_VERSION' >> ~/.bashrc
echo 'export JAVA_HOME=/usr' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME:$HIVE_HOME/bin:$BDLCL_HOME/bin:$JAVA_HOME' >> ~/.bashrc
echo 'export JAVA_CLASSPATH="/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/"' >> ~/.bashrc
echo 'export JAVA_OPTS="-Dsun.security.krb5.debug=true -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=256M"' >> ~/.bashrc
echo 'alias python=python3.6' >> ~/.bashrc
source ~/.bashrc

# Setting defaults for spark and Hive parameters -> RPC error
if [ "$DYNAMIC_PARTITION_VALUE" == "" ]; then
  DYNAMIC_PARTITION_VALUE='true'
fi
if [ "$DYNAMIC_PARTITION_MODE" == "" ]; then
  DYNAMIC_PARTITION_MODE='nonstrict'
fi
if [ "$NR_MAX_DYNAMIC_PARTITIONS" == "" ]; then
  NR_MAX_DYNAMIC_PARTITIONS=1000
fi
if [ "$MAX_DYNAMIC_PARTITIONS_PER_NODE" == "" ]; then
  MAX_DYNAMIC_PARTITIONS_PER_NODE=100
fi

#Configure core-site.xml based on the configured authentication method
if [ "$AUTH_METHOD" == "apikey" ]; then
	mv $HIVE_HOME/conf/core-site.xml.apiKey $HADOOP_HOME/etc/hadoop/core-site.xml
	if [ "$AUTH_APIKEY" != "" ]; then
		sed "s/AUTH_APIKEY/$AUTH_APIKEY/" $HADOOP_HOME/etc/hadoop/core-site.xml >> $HADOOP_HOME/etc/hadoop/core-site.xml.tmp && \
		mv $HADOOP_HOME/etc/hadoop/core-site.xml.tmp $HADOOP_HOME/etc/hadoop/core-site.xml
	fi
	if [ "$API_ENDPOINT" != "" ]; then
		sed "s/API_ENDPOINT/${API_ENDPOINT//\//\\/}/" $HADOOP_HOME/etc/hadoop/core-site.xml >> $HADOOP_HOME/etc/hadoop/core-site.xml.tmp && \
		mv $HADOOP_HOME/etc/hadoop/core-site.xml.tmp $HADOOP_HOME/etc/hadoop/core-site.xml
	fi
	if [ "$BDL_DEFAULT_PATH" != "" ]; then
		sed "s/BDL_DEFAULT_PATH/${BDL_DEFAULT_PATH//\//\\/}/" $SPARK_HOME/conf/core-site.xml >> $SPARK_HOME/conf/core-site.xml.tmp && \
		mv $SPARK_HOME/conf/core-site.xml.tmp $SPARK_HOME/conf/core-site.xml
	fi
	cp $HADOOP_HOME/etc/hadoop/core-site.xml $BDLCL_HOME/conf/
fi

if [ "$DB_TYPE" == "postgresql" ]; then
	# Add metadata support
	if [ "$POSTGRES_HOSTNAME" != "" ]; then
		sed "s/POSTGRES_HOSTNAME/$POSTGRES_HOSTNAME/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	if [ "$POSTGRES_PORT" != "" ]; then
		sed "s/POSTGRES_PORT/$POSTGRES_PORT/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	if [ "$DB_NAME" != "" ]; then
		sed "s/SPARK_POSTGRES_DB/$DB_NAME/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	if [ "$DB_USER" != "" ]; then
		sed "s/SPARK_POSTGRES_USER/$DB_USER/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi


	if [ "$DYNAMIC_PARTITION_VALUE" != "" ]; then
		sed "s/DYNAMIC_PARTITION_VALUE/$DYNAMIC_PARTITION_VALUE/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	if [ "$DYNAMIC_PARTITION_MODE" != "" ]; then
		sed "s/DYNAMIC_PARTITION_MODE/$DYNAMIC_PARTITION_MODE/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	if [ "$NR_MAX_DYNAMIC_PARTITIONS" != "" ]; then
		sed "s/NR_MAX_DYNAMIC_PARTITIONS/$NR_MAX_DYNAMIC_PARTITIONS/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	if [ "$MAX_DYNAMIC_PARTITIONS_PER_NODE" != "" ]; then
		sed "s/MAX_DYNAMIC_PARTITIONS_PER_NODE/$MAX_DYNAMIC_PARTITIONS_PER_NODE/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
		mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml
	fi

	sed "s/SPARK_POSTGRES_PASSWORD/$DB_PASSWORD/" $HIVE_HOME/conf/hive-site.xml >> $HIVE_HOME/conf/hive-site.xml.tmp && \
	mv $HIVE_HOME/conf/hive-site.xml.tmp $HIVE_HOME/conf/hive-site.xml

	export PGPASSWORD=$DB_PASSWORD

	#psql -h $POSTGRES_HOSTNAME -p $POSTGRES_PORT  -U  $DB_USER -d $DB_NAME -f $SPARK_HOME/jars/hive-schema-1.2.0.postgres.sql
	cp $HIVE_HOME/conf/hive-site.xml $HIVE_HOME/conf/hive-default.xml
	cp $HIVE_HOME/conf/hive-site.xml $HADOOP_HOME/etc/hadoop/hive-site.xml
	
	#this will be optional until we update the projects or data pool code
	schematool -dbType postgres -upgradeSchema
fi

#Fix python not found file/directory issues
rm -rf /usr/bin/python
ln -s /usr/local/bin/python3.6 /usr/bin/python

rm -rf /opt/bigstepdatalake-$BDLCL_VERSION/conf/core-site.xml
cp $HADOOP_HOME/etc/hadoop/core-site.xml $BDLCL_HOME/conf/

rm $HIVE_HOME/lib/disruptor-3.3.0.jar 

mkdir /tmp/hive 
chmod -R 777 /tmp/hive

if [ "$MODE" == "" ]; then
MODE=$1
fi

if [ "$MODE" == "hive" ]; then 
	hive --service metastore
fi
