# Docker container for Android / Oculus Compliation
# 
# Mike Christopher <mchristopher (at) gmail>
#

# Load Ubuntu by default
FROM ubuntu:trusty

# Install Java and 32-bit tools for compiling Android
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y software-properties-common libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 p7zip-full python build-essential dos2unix wget && \
    wget -qO- https://deb.nodesource.com/setup_5.x | bash - && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer nodejs && \
    apt-get remove software-properties-common -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/oracle-jdk8-installer/* && \
    rm -rf /usr/lib/jvm/java-8-oracle/*.zip && \
    apt-get autoremove -y && \
    apt-get clean

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Installs Ant
ENV ANT_VERSION 1.9.4
ENV ANT_HOME /opt/ant
RUN cd && \
    wget -q http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz

# Installs Gradle
ENV GRADLE_VERSION 2.11
ENV GRADLE_HOME /opt/gradle
RUN cd && \
    wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip && \
    7z x -y gradle-${GRADLE_VERSION}-bin.zip > /dev/null && \
    mv gradle-${GRADLE_VERSION} /opt/gradle && \
    rm gradle-${GRADLE_VERSION}-bin.zip

# Installs Android SDK & NDK
ENV ANDROID_API_LEVELS android-19
ENV ANDROID_BUILD_TOOLS_VERSION 22.0.1
ENV ANDROID_HOME /opt/android-sdk-linux
RUN cd /opt && \
    wget -q https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
    tar -xzf android-sdk_r24.4.1-linux.tgz && \
    rm android-sdk_r24.4.1-linux.tgz && \
    echo y | ${ANDROID_HOME}/tools/android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    rm -fr ~/.android && rm -fr ~/.oracle_jre_usage

# Installs Android NDK
ENV ANDROID_NDK_VERSION r10e
ENV ANDROID_NDK /opt/android-ndk-${ANDROID_NDK_VERSION}
RUN cd /opt && \
    wget -q https://dl.google.com/android/ndk/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.bin && \
    7z x -y android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.bin > /dev/null && \
    rm android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.bin

# Install Oculus SDK
ENV OCULUS_SDK_VERSION 1.0.0.0
ENV OCULUS_SDK_HOME /opt/oculus-sdk
RUN mkdir -p ${OCULUS_SDK_HOME} && cd ${OCULUS_SDK_HOME} && \
    wget -q https://static.oculus.com/sdk-downloads/ovr_sdk_mobile_${OCULUS_SDK_VERSION}.zip && \
    7z x -y ovr_sdk_mobile_${OCULUS_SDK_VERSION}.zip > /dev/null && \
    rm ovr_sdk_mobile_${OCULUS_SDK_VERSION}.zip && \
    rm -fr ${OCULUS_SDK_HOME}/SourceAssets && \
    rm -fr ${OCULUS_SDK_HOME}/sdcard_SDK && \
    rm -fr ${OCULUS_SDK_HOME}/VrSamples && \
    rm -fr ${OCULUS_SDK_HOME}/*.apk && \
    touch ${OCULUS_SDK_HOME}/local.properties && \
    chmod a+x ${OCULUS_SDK_HOME}/gradlew && \
    dos2unix ${OCULUS_SDK_HOME}/gradlew && \
    dos2unix ${OCULUS_SDK_HOME}/*.py && \
    dos2unix ${OCULUS_SDK_HOME}/*.gradle && \
    dos2unix ${OCULUS_SDK_HOME}/*.mk

# Update PATH variables
ENV PATH ${PATH}:${ANT_HOME}/bin:${GRADLE_HOME}/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_NDK}
