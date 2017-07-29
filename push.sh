#!/bin/bash

if [ "$1" == "" ]; then
    echo "$0 <server>  - Rsync unix-profile to server. Does not install it."
    exit 1;
fi

SERVER=$1

rsync -av ./ "$SERVER:unix-profile" --exclude=/.git --exclude=/backup --delete
