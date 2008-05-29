#!/bin/sh
DATE=$(date +%Y%m%d -u)
TAG=mysql-extras-$DATE
git tag mysql-extras-$DATE
git archive --prefix=$tag $tag | bzip2 >../${tag}.tar.bz2
