#!/bin/bash

yum install -y epel-release

PACKAGES=(
    curl
    git
    python36-pip
)

yum install -y "${PACKAGES[@]}"

yum clean all

pip3.6 install tox

# This step is needed so Kubelet registration doesn't fail for DNS entries
# longer than 63 characters.
hostnamectl set-hostname bootstrap
