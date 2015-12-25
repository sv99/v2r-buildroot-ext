#!/bin/bash
# must be executed from base directory
cd `dirname "${BASH_SOURCE[0]}"`/..

tar czvf update_pack.tar.gz --exclude "*.pyc" --exclude ".DS_Store" --exclude "*.swp" \
    remotecontrol/ scripts/ lircd/ pipeline.txt \
    manage.py server.py README.md
