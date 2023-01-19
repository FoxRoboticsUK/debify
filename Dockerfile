FROM ubuntu:22.04
MAINTAINER "Rohan Singh <rohan@washington.edu>"

ENV DEBIAN_FRONTEND noninteractive

# defaults for debify
ENV APTLY_DISTRIBUTION focal
ENV APTLY_COMPONENT main
ENV KEYSERVER keyserver.ubuntu.com

ENV GNUPGHOME /.gnupg
ENV GNP_PASSPHRASE jayceelock

# install aptly
RUN apt update && apt install -y aptly gpg nginx

ADD debify.sh /debify.sh
ENTRYPOINT ["/debify.sh"]
