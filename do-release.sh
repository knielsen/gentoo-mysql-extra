#!/bin/sh
DATE=$(date +%Y%m%d-%H%MZ -u)
TAG=mysql-extras-$DATE
outfile=${TAG}.tar.bz2
git tag $TAG
git archive --prefix="${TAG}/" $TAG | bzip2 >../${outfile}
echo "$outfile generated."
