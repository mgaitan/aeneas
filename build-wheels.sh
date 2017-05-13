#!/bin/bash
set -e -x

# Install a system package required by our library
yum install -y libsndfile-devel libsamplerate-devel portaudio
# yum install -y ffmpeg

# from http://wiki.neuralbs.com/index.php/Installing_Espeak_on_AsteriskNow
wget --no-check-certificate http://repos.amberdms.com/pub/amberdms/linux/centos/5/amberdms-os/"$ARCH"/RPMS/espeak-1.45.05-4.el5."$ARCH".rpm
rpm -Uvh espeak-1.45.05-4.el5."$ARCH".rpm
wget --no-check-certificate http://repos.amberdms.com/pub/amberdms/linux/centos/5/amberdms-os/"$ARCH"/RPMS/espeak-devel-1.45.05-4.el5."$ARCH".rpm
rpm -Uvh espeak-devel-1.45.05-4.el5."$ARCH".rpm

# Compile wheels
for PYBIN in /opt/python/*/bin;  do
    # skip unsupported python versions
    if [[ "${PYBIN}" == *"cp26"* ]] || \
       [[ "${PYBIN}" == *"cp33"* ]] || \
       [[ "${PYBIN}" == *"cp34"* ]] ; then
        continue
    fi
    "${PYBIN}/pip" install -r /io/requirements.txt
    "${PYBIN}/pip" wheel /io/ -w wheelhouse/
done

rm wheelhouse/beautifulsoup4*

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair "$whl" -w /io/wheelhouse/
done

# Install packages and test
# for PYBIN in /opt/python/*/bin/; do
#     "${PYBIN}/pip" install python-manylinux-demo --no-index -f /io/wheelhouse
#     (cd "$HOME"; "${PYBIN}/nosetests" pymanylinuxdemo)
# done