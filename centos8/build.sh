#!/bin/bash

# 実行スクリプトのpath取得
# https://qiita.com/koara-local/items/2d67c0964188bba39e29
SCRIPT_DIR=$(cd $(dirname $0); pwd)
cd $SCRIPT_DIR

# symbolicの実体を辿ってimageをbuild
# ref: https://blog.kkty.jp/entry/2019/06/16/214951
tar -czh . | docker build \
        -t jupyter_pip_custom_centos8 \
        --build-arg BASE_IMAGE=centos:8 \
        --build-arg USER_NAME=user \
        --build-arg USER_UID=1000 \
        --build-arg PASSWD=awesome \
        --build-arg SPARK_VERSION=2.4.5 \
        --build-arg HADOOP_VERSION=2.7 \
        - 
