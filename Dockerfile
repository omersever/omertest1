FROM websphere-liberty:webProfile7
MAINTAINER IBM Java engineering at IBM Cloud
COPY /target/liberty/wlp/usr/servers/defaultServer /config/
COPY /target/liberty/wlp/usr/shared/resources /config/resources/
COPY /src/main/liberty/config/jvmbx.options /config/jvm.options

CMD echo "omer-tools1" > /tmp/omer2
RUN echo "omer-tools2" > /tmp/omer2

RUN echo "<settings><mirrors><mirror><id>akbank-repo1</id><mirrorOf>*</mirrorOf><name>Akbank Maven Repository Manager</name><url>http://172.16.22.65:8081/repository/maven-central</url></mirror></mirrors></settings>" > /root/.m2/settings.xml
CMD echo "<settings><mirrors><mirror><id>akbank-repo2</id><mirrorOf>*</mirrorOf><name>Akbank Maven Repository Manager</name><url>http://172.16.22.65:8081/repository/maven-central</url></mirror></mirrors></settings>" > /root/.m2/settings.xml

# Install required features if not present, install APM Data Collector
RUN installUtility install --acceptLicense defaultServer && installUtility install --acceptLicense apmDataCollector-7.4
RUN /opt/ibm/wlp/usr/extension/liberty_dc/bin/config_liberty_dc.sh -silent /opt/ibm/wlp/usr/extension/liberty_dc/bin/silent_config_liberty_dc.txt
# Upgrade to production license if URL to JAR provided
ARG LICENSE_JAR_URL
RUN \ 
  if [ $LICENSE_JAR_URL ]; then \
    wget $LICENSE_JAR_URL -O /tmp/license.jar \
    && java -jar /tmp/license.jar -acceptLicense /opt/ibm \
    && rm /tmp/license.jar; \
  fi
