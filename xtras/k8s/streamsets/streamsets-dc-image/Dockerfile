FROM streamsets/datacollector:latest
# My custom configured sdc.properties
COPY sdc.properties /etc/sdc/sdc.properties

RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-jdbc-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-azure-keyvault-credentialstore-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-azure-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-bigtable-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-cyberark-credentialstore-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-google-cloud-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-jms-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-mongodb_3-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-mysql-binlog-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-tensorflow-lib
RUN /opt/streamsets-datacollector-3*/bin/streamsets stagelibs -install=streamsets-datacollector-vault-credentialstore-lib

EXPOSE 18630
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["dc", "-exec"]