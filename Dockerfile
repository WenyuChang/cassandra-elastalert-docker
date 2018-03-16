# Elastalert Docker image running on Centos7.
# This image is especially for monitoring Cassandra logs
# The WORKDIR instructions are deliberately left, as it is recommended to use WORKDIR over the cd command.

FROM centos:centos7
MAINTAINER Wenyu Chang


ENV ELASTALERT_VERSION 0.1.29
ENV SET_CONTAINER_TIMEZONE false
ENV CONTAINER_TIMEZONE UTC
ENV ELASTALERT_URL https://github.com/Yelp/elastalert/archive/v${ELASTALERT_VERSION}.zip
ENV CONFIG_DIR /etc/elastalert/conf
ENV RULES_DIRECTORY /etc/elastalert/rules
ENV ELASTALERT_CONFIG ${CONFIG_DIR}/elastalert_config.yaml
ENV LOG_DIR /var/log/elastalert
ENV ELASTALERT_DIRECTORY_NAME elastalert
ENV ELASTALERT_HOME /opt/${ELASTALERT_DIRECTORY_NAME}
ENV ELASTALERT_SUPERVISOR_CONF ${CONFIG_DIR}/elastalert_supervisord.conf
ENV ELASTICSEARCH_HOST elasticsearchhost
ENV ELASTICSEARCH_PORT 9200
ENV ELASTICSEARCH_CASSANDRA_INDEX index-*
ENV SLACK_WEBHOOK_URL https://hooks.slack.com/services/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


# Copy the script used to launch the Elastalert when a container is started.
COPY ./files/start-elastalert.sh /opt/start-elastalert.sh
COPY ./files/elastalert_config.conf ${ELASTALERT_CONFIG}
COPY ./files/rule-large-partition-error.yaml ${RULES_DIRECTORY}/large-partition-error.yaml
COPY ./files/rule-large-partition-warning.yaml ${RULES_DIRECTORY}/large-partition-warning.yaml
COPY ./files/rule-exception.yaml ${RULES_DIRECTORY}/exception.yaml
COPY ./files/rule-jvm-crash.yaml ${RULES_DIRECTORY}/jvm-crash.yaml
COPY ./files/rule-slow-query.yaml ${RULES_DIRECTORY}/slow-query.yaml


# Create directories. The /var/empty directory is used by openntpd.
RUN mkdir -p ${CONFIG_DIR}; \
    mkdir -p ${RULES_DIRECTORY}; \
    mkdir -p ${LOG_DIR}; \
    mkdir -p /var/empty;

# Install software required for Elastalert and NTP for time synchronization.
RUN yum install -y unzip wget ntp.x86_64 openssl-devel.x86_64 openssl.x86_64 \
                   libffi.x86_64 libffi-devel.x86_64 python-devel.x86_64 gcc.x86_64 \
                   compat-gcc-44.x86_64 libgcc.x86_64 tzdata.noarch; \
    rm -rf /var/cache/yum/*;

# Install pip - required for installation of Elastalert.
RUN wget https://bootstrap.pypa.io/get-pip.py; \
    python get-pip.py; \
    rm -rf get-pip.py;

# Download and unpack Elastalert.
RUN wget -O elastalert.zip ${ELASTALERT_URL}; \
    unzip elastalert.zip; \
    rm -rf elastalert.zip; \
    mv elastalert-${ELASTALERT_VERSION} ${ELASTALERT_HOME}

WORKDIR ${ELASTALERT_HOME}

# Install Elastalert.
RUN pip uninstall twilio --yes; \
    pip install twilio==6.0.0; \
    pip install python-dateutil==2.6.0; \
    python setup.py install;

# Install Supervisor.
RUN easy_install supervisor;

# Copy default configuration files to configuration directory.
RUN cp ${ELASTALERT_HOME}/supervisord.conf.example ${ELASTALERT_SUPERVISOR_CONF};

# Make the start-script executable.
RUN chmod +x /opt/start-elastalert.sh;

# Define mount points.
VOLUME [ "${CONFIG_DIR}", "${LOG_DIR}"]

# Launch Elastalert when a container is started.
CMD ["/opt/start-elastalert.sh"]
