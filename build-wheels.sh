#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y libsndfile-devel libsamplerate-devel
# yum install -y ffmpeg
rpm -Uvh https://repos.jethrocarr.com/pub/amberdms/linux/centos/5/amberdms-os/"$ARCH"/RPMS/espeak-1.45.05-4.el5."$ARCH".rpm
rpm -Uvh https://repos.jethrocarr.com/pub/amberdms/linux/centos/5/amberdms-os/"$ARCH"/RPMS/espeak-devel-1.45.05-4.el5."$ARCH".rpm

# Compile wheels
for PYBIN in /opt/python/*/bin;  do
    "${PYBIN}/pip" install -r /io/dev-requirements.txt
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
# for PYBIN in /opt/python/*/bin/; do
#     "${PYBIN}/pip" install python-manylinux-demo --no-index -f /io/wheelhouse
#     (cd "$HOME"; "${PYBIN}/nosetests" pymanylinuxdemo)
# done