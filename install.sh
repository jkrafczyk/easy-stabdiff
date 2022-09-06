#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$0")"
cd "$HERE"
if echo "$HERE" | grep -v '^/'; then
    HERE="$(pwd)/$HERE"
fi

if [[ "$(uname --kernel-name)" != "Linux" ]]; then
    echo "Only supported on 64-bit x64/x86-64/amd64 linux."
    exit 1
fi
if [[ "$(uname --machine)" != "x86_64" ]]; then
    echo "Only supported on 64-bit x64/x86-64/amd64 linux."
    exit 1
fi

if [[ ! -d /usr/include/openssl || ! -f /usr/include/zlib.h || ! -f /usr/include/ffi.h ]]; then
    if which apt-get >& /dev/null; then
        echo "Openssl development headers not found."
        echo "Trying to install. You may be asked for your password."
        set -x
        sudo apt-get update
        sudo apt-get install libsqlite3-dev libssl-dev zlib1g-dev libffi-dev  tk-dev tcl-dev libbz2-dev build-essential autoconf gcc g++
        set +x
    else
        echo "Openssl dev libraries not installed and this is not a debian system."
        echo "Please manually install the corresponding package and try again."
        exit 1
    fi
fi

if ! which autoconf >& /dev/null || ! which gcc  >& /dev/null  || ! which make  >& /dev/null ; then
    if which apt-get >& /dev/null; then
        echo "Some autoconf, gcc or make not found."
        echo "Trying to install. You may be asked for your password."
        set -x
        sudo apt-get update
        sudo apt-get install libsqlite3-dev libssl-dev zlib1g-dev libffi-dev  tk-dev tcl-dev libbz2-dev build-essential autoconf gcc g++
        set +x
    else
        echo "Some autoconf, gcc or make not found."
        echo "Please manually install the corresponding packages and try again."
        exit 1
    fi
fi

echo "Ensuring python3.9 is installed locally..."
if [[ ! -f "Python-3.9.12.tar.xz" ]]; then
    curl -Lo Python-3.9.12.tar.xz "https://www.python.org/ftp/python/3.9.12/Python-3.9.12.tar.xz"   
fi
if [[ ! -d "Python-3.9.12" ]]; then
    tar xavf Python-3.9.12.tar.xz
fi

if [[ ! -x "python3.9/bin/python3.9" ]]; then
    pushd Python-3.9.12
    ./configure  --prefix="$HERE/python3.9"
    #./configure --enable-optimizations --prefix="$HERE/python3.9"
    make -j
    make install
    popd
fi

echo "Ensuring existing virtualenv..."
if [[ ! -x "./env" ]]; then
    "$HERE/python3.9/bin/python3.9" -m venv env
fi

source "./env/bin/activate"
if [[ ! -f "stable_diffusion/.git/config" ]]; then
    git clone https://github.com/bes-dev/stable_diffusion.openvino.git stable_diffusion
fi

echo "Installing required python packages..."
pip install --upgrade pip
pip install -r stable_diffusion/requirements.txt
pip install ftfy==6.1.1