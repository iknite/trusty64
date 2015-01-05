#!/bin/bash
set -x

# Updating and Upgrading dependencies
apt-get update -y -qq > /dev/null
apt-get dist-upgrade -y -qq > /dev/null
