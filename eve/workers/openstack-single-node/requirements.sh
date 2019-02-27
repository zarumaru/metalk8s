#!/bin/bash

PACKAGES=(
    curl
    iproute
)

yum install -y "${PACKAGES[@]}"

yum clean all
