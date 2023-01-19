FROM ubuntu:22.04
MAINTAINER "Jacobus Lock <jacobus.lock@fox-robotics.com>"

ENV DEBIAN_FRONTEND noninteractive

# defaults for debify
ENV APTLY_DISTRIBUTION focal
ENV APTLY_COMPONENT main
ENV KEYSERVER keyserver.ubuntu.com
ENV PORT 80

ENV GNUPGHOME /.gnupg

# install aptly
RUN apt update && apt install -y aptly gpg

ADD debify.sh /debify.sh
ENTRYPOINT ["/debify.sh"]
