#!/bin/bash

set -e

if [ ! -d /aptly/debs ]
then
    echo "Mount your Debian package directory to /aptly/debs."
    exit 1
fi

APTLY_REPO_NAME=debify

aptly repo create \
    -component="$APTLY_COMPONENT" \
    -distribution="$APTLY_DISTRIBUTION" \
    -config="/aptly/aptly.conf" \
    $APTLY_REPO_NAME
echo "Repo created"

aptly repo add \
    -config="/aptly/aptly.conf" \
    $APTLY_REPO_NAME \
    /aptly/debs/
echo "Debs added to repo"

aptly repo show \
    -config="/aptly/aptly.conf" \
    $APTLY_REPO_NAME 

if [ ! -z "$GPG_PASSPHRASE" ]
then
    passphrase="$GPG_PASSPHRASE"
elif [ ! -z "$GPG_PASSPHRASE_FILE" ]
then
    passphrase=$(<$GPG_PASSPHRASE_FILE)
fi

aptly publish repo \
    -batch \
    -architectures="$APTLY_ARCHITECTURES" \
    -passphrase="$passphrase" \
    -config="/aptly/aptly.conf" \
    $APTLY_REPO_NAME
echo "Repo published"

mv /aptly/repo/public /repo

if [ ! -z "$KEYSERVER" ] && [ ! -z "$URI" ]
then
    release_sig_path=$(find /repo/dists -name Release.gpg | head -1) 
    gpg_key_id=$(gpg --list-packets $release_sig_path | grep -oP "(?<=keyid ).+")

    echo "# setup script for $URI" > /repo/go

    case "$URI" in
        https://*)
            cat >> /repo/go <<-END
if [ ! -e /usr/lib/apt/methods/https ]
then
    apt-get update
    apt-get install -y apt-transport-https
fi
END
    esac

    cat >> /repo/go <<-END
apt-key adv --keyserver $KEYSERVER --recv-keys $gpg_key_id
echo "deb $URI $APTLY_DISTRIBUTION $APTLY_COMPONENT" >> /etc/apt/sources.list
apt-get update
END
fi

tar -C /repo -czf /aptly/debs/repo.tar.gz .
echo "Repo published as tarball"

aptly serve \
    -listen=:$PORT \
    -config="/aptly/aptly.conf"
