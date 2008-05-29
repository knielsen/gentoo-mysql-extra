#!/bin/sh
DATE=$(date +%Y%m%d -u)
TAG=mysql-extras-$DATE
git tag $TAG
git archive --prefix="${TAG}/" $TAG | bzip2 >../${TAG}.tar.bz2
