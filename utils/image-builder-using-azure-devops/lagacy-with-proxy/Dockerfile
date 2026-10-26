# Use base image ...
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Following parameters are needed ...
#   Empower credentials ...
ARG EMPOWER_USERNAME
ARG EMPOWER_PASSWORD
ARG INSTALLER_URL
ARG RELEASE
ARG ADMIN_PASSWORD
ARG PRODUCTS
ARG PROXY

# Install basis software ...
#   if you use ubuntu:latest, enable ...
# RUN \
#   apt-get update                                && \
#   apt-get upgrade                            -y && \
#   apt-get install curl                       -y

# Create user ...
RUN useradd -ms /bin/bash sagadmin

# Create installation directory ...
RUN mkdir          /opt/softwareag && \
    chown sagadmin /opt/softwareag

# Change user context to ...
USER sagadmin

# Install IBM webMethods Installer ...
RUN \
  cd /opt/softwareag && \
  curl \
    ${INSTALLER_URL} \
    --proxy "${PROXY}" \
    -o installer.bin

# Create script for IBM webMethods Installer ...
#  SAG host=sdc-hq.softwareag.com
#  IBM host=sdc.webmethods.io
RUN \
    cd /opt/softwareag                                                                                                                       && \
    echo "ServerURL=https\://sdc.webmethods.io/cgi-bin/dataservewebM`echo ${RELEASE} | sed "s/\.//g"`.cgi"                > installer.script && \
    echo "selectedFixes=spro\:all"                                                                                       >> installer.script && \
    echo "InstallProducts=`for item in $(echo ${PRODUCTS} | sed "s/,/ /g");  do printf e2ei/11/.LATEST/*/$item, ; done`" >> installer.script && \ 
    echo "InstallDir=/opt/softwareag"                                                                                    >> installer.script && \
    echo "adminPassword=${ADMIN_PASSWORD}"                                                                               >> installer.script && \
    echo "Username=${EMPOWER_USERNAME}"                                                                                  >> installer.script && \
    echo "Password=${EMPOWER_PASSWORD}"                                                                                  >> installer.script && \
    echo "ProxyHttpHost=`echo "${PROXY}" | awk -F'[[:space:]="/:]+' '{print $2}'`"                                       >> installer.script && \
    echo "ProxyHttpPort=`echo "${PROXY}" | awk -F'[[:space:]="/:]+' '{print $3}'`"                                       >> installer.script && \
    echo "LicenseAgree=Accept"                                                                                           >> installer.script && \
    echo 'Debug Installer script: ' && echo && cat installer.script

# Install software ...
RUN \
    cd /opt/softwareag                                     && \
    sh installer.bin -readScript installer.script -console && \
    echo 'Debug installation log ...' && echo && find . -name "installLog.txt" | xargs cat

# Cleanup ...
RUN \ 
    cd /opt/softwareag                                     && \
    rm installer.bin installer.script
