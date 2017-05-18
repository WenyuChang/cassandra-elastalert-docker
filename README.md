# Elastalert Docker Image

Docker image with Elastalert on Centos7

Requires a link to a Docker container running Elasticsearch using the "elasticsearchhost" alias.
Assumes the use of port 9200 when communicating with Elasticsearch.<br/>
In order for the time of the container to be synchronized (ntpd), it must be run with the SYS_TIME capability.
In addition you may want to add the SYS_NICE capability, in order for ntpd to be able to modify its priority.

# Volumes
- `/var/log/elastalert`     - Elastalert and Supervisord logs will be written to this directory.
- `/etc/elastalert/config`  - Elastalert (elastalert_config.yaml) and Supervisord (elastalert_supervisord.conf) configuration files.
- `/etc/elastalert/rules`   - Contains Elastalert rules.<br/>

# Environment
- `SET_CONTAINER_TIMEZONE` - Set to "true" (without quotes) to set the tiemzone when starting a container. Default is false.
- `CONTAINER_TIMEZONE` - Timezone to use in container. Default is Europe/Stockholm.
- `ELASTICSEARCH_HOST` - Alias, DNS or IP of Elasticsearch host to be queried by Elastalert.
- `ELASTICSEARCH_PORT` - Port on above Elasticsearch host.
- `ELASTICSEARCH_CASSANDRA_INDEX` - ElasticSearch index name for Cassandra logs
- `SLACK_WEBHOOK_URL` - Slack webhook url. Default is Wenyu's Slack

# Supported Alert Rules
- **Cassandra large partition logs** - "Compacting large partition" in Cassandra2x and "Writing large partition" in Cassandra3x
- **Cassandra Exception logs** - Any exception related error
