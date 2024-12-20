FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG FIREFOX_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE=Firefox
ENV DOCKER_MODS=linuxserver/mods:universal-package-install
ENV INSTALL_PACKAGES=fonts-noto-cjk

# prevent Ubuntu's firefox stub from being installed
COPY /root/etc/apt/preferences.d/firefox-no-snap /etc/apt/preferences.d/firefox-no-snap
# disable private browsing
COPY /distribution/policies.json /usr/lib/firefox/distribution/policies.json

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/firefox-logo.png && \
  echo "**** install packages ****" && \
  apt-key adv \
    --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 738BEB9321D1AAEC13EA9391AEBDF4819BE21867 && \
  echo \
    "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu noble main" > \
    /etc/apt/sources.list.d/firefox.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    firefox \
    ^firefox-locale && \
  echo "**** default firefox settings ****" && \
  FIREFOX_SETTING="/usr/lib/firefox/browser/defaults/preferences/firefox.js" && \
  echo 'pref("datareporting.policy.firstRunURL", "");' > ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.policy.dataSubmissionEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.service.enabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("datareporting.healthreport.uploadEnabled", false);' >> ${FIREFOX_SETTING} && \
  echo 'pref("trailhead.firstrun.branches", "nofirstrun-empty");' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.aboutwelcome.enabled", false);' >> ${FIREFOX_SETTING} && \
  # dark mode
  echo 'pref("extensions.activeThemeID", "firefox-compact-dark@mozilla.org");' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.theme.toolbar-theme", 1);' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.theme.content-theme", 1);' >> ${FIREFOX_SETTING} && \
  echo 'pref("browser.in-content.dark-theme", true);' >> ${FIREFOX_SETTING} && \

  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3000

VOLUME /config
