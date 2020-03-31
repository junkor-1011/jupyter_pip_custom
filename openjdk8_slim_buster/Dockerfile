# (Args)
# ARG: BASE_IMAGE
# ARG: USER_UID
# ARG: PYTHON_VER


ARG BASE_IMAGE=openjdk:8u242-jre-slim-buster

FROM ${BASE_IMAGE}

# designate using-python
# 3.8はpysparkに対応していない様子
ARG PYTHON_VER=3.7
ENV PYTHON=python${PYTHON_VER}
# python3.8はdebianではまだデフォルトではそのままapt-get出来ない様子

# system update & package install
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get clean && \
    apt-get -y update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ${PYTHON} ${PYTHON}-dev python3-pip python3-setuptools \
    libpcre3 libpcre3-dev \
    zlib1g zlib1g-dev \
    openssl libssl-dev \
    ca-certificates \
    bash \
    curl \
    wget \
    bzip2 \
    gnupg \
    swig \
    vim \
    graphviz \
    git \
    make \
    llvm \
    xz-utils \
    tk-dev \
    unzip \
    sudo \
    locales \
    fonts-liberation \
    software-properties-common \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libffi-dev \
    liblzma-dev \
    libspatialindex-dev

# gdal    
#RUN add-apt-repository ppa:ubuntugis/ppa \
#   && apt-get update \
# debianなので上記のキーは入らない
RUN apt-get install -y \
    gdal-bin \
    libgdal-dev 
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal \
    C_INCLUDE_PATH=/usr/include/gdal    
# todo: 要不要の選別など

# pyarrowでorcを扱う必要がある場合、ここで色々インストールしないといけないかもしれない
#   parquetだけなら以下は不要なはず
# https://arrow.apache.org/install/

RUN apt-get clean && rm -rf /var/lib/apt/lists/*    
ENV SHELL=/bin/bash

# SPARK    
# https://qiita.com/hrkt/items/fe9b1162f7a08a07e812
ARG SPARK_VERSION=2.4.5
ARG HADOOP_VERSION=2.7
RUN curl -O http://apache.mirror.iphh.net/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && tar xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /usr/local/spark \
    && rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# nodejs
ENV NODEJS=node-v12.16.1-linux-x64
RUN wget https://nodejs.org/dist/v12.16.1/${NODEJS}.tar.xz \
    && tar Jxvf ${NODEJS}.tar.xz \
    && mv ${NODEJS} /usr/local/nodejs \
    && rm ${NODEJS}.tar.xz
#ENV PATH=$PATH:~/.nodejs/bin


# user        
# ref:
# https://zukucode.com/2019/06/docker-user.html
# https://qiita.com/Riliumph/items/3b09e0804d7a04dff85b
# 一般ユーザーアカウントを追加
ARG USER_NAME=user
ARG USER_UID=1000
ARG PASSWD=password
#RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
#    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
#    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
#    useradd -m -s /bin/bash -u ${USER_UID} ${USER_NAME} && \
#    gpasswd -a ${USER_NAME} sudo
RUN useradd -m -s /bin/bash -u ${USER_UID} ${USER_NAME} && \
    gpasswd -a ${USER_NAME} sudo && \
    echo "${USER_NAME}:${PASSWD}" | chpasswd && \
    echo "${USER_NAME} ALL=(ALL) ALL" >> /etc/sudoers

#RUN useradd -m -u ${USER_UID} ${USER_NAME}
# 一般ユーザーにsudo権限を付与
#RUN gpasswd -a ${UID} sudo


COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements2.txt /tmp/requirements2.txt
COPY ./constraints.txt /tmp/constraints.txt

USER ${USER_UID}
#WORKDIR /home/${USER_NAME} # TMP

# pip
# https://qiita.com/zakuro9715/items/68c8d8c6b1b05f91fa2e
ENV PATH=$PATH:/home/${USER_NAME}/.local/bin
RUN ${PYTHON} -m pip install --user --upgrade pip setuptools && \
    ${PYTHON} -m pip install --user -r /tmp/requirements.txt -c /tmp/constraints.txt && \
    ${PYTHON} -m pip install --user -r /tmp/requirements2.txt -c /tmp/constraints.txt
# TMP <= pysparkとpy4jのpathがうまく通らない <= もうまくいかない
#RUN ${PYTHON} -m pip install --user py4j==0.10.7 pyspark==${SPARK_VERSION}
# ENV
# py4j=0.10.7 pipでは入れていないので後で考えるかも
# ref: https://hub.docker.com/r/jupyter/pyspark-notebook/dockerfile
ARG PY4J_VER=0.10.7
ENV SPARK_HOME=/usr/local/spark \
    NODEJS_HOME=/usr/local/nodejs
ENV PYTHONPATH=${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-${PY4J_VER}-src.zip \
    SPARK_OPTS="--driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info" \
    PATH=$PATH:${SPARK_HOME}/bin:${NODEJS_HOME}/bin \
    PYSPARK_PYTHON=/usr/bin/${PYTHON} \
    PYSPARK_DRIVER=${PYTHON}
#RUN alias python=/usr/bin/${PYTHON}

WORKDIR /home/${USER_NAME}
RUN mkdir ~/.bin \
    && chown ${USER_NAME}:${USER_NAME} ~/.bin \
    && chmod 755 ~/.bin \
    && ln -s /usr/bin/${PYTHON} ~/.bin/python
ENV PATH=$PATH:~/.bin


# add jar
#RUN /usr/local/spark/bin/pyspark --packages graphframes:graphframes:0.7.0-spark2.4-s_2.11 && \
#    /usr/local/spark/bin/pyspark --packages org.postgresql:postgresql:jar:42.1.4
RUN ${SPARK_HOME}/bin/pyspark --packages graphframes:graphframes:0.7.0-spark2.4-s_2.11
RUN ${SPARK_HOME}/bin/pyspark --packages org.postgresql:postgresql:jar:42.1.4

# FONT
RUN mkdir ~/.fonts \
    && chown ${USER_NAME} ~/.fonts \
    && chmod 755 ~/.fonts
RUN wget https://ipafont.ipa.go.jp/IPAexfont/ipaexg00401.zip \
    && unzip ipaexg00401.zip \
    && mv ipaexg00401 -t ~/.fonts/ \
    && rm ipaexg00401.zip \
    && rm -rf ~/.cache/* \
    && fc-cache -fv

# jupyter lab
# nodejsに関して、condaから入れる or 直接公式からダウンロードしたものでないと受け付けないらしい
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install jupyter-matplotlib
RUN jupyter labextension install @lckr/jupyterlab_variableinspector

EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.token=''"]

