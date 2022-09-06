#!/usr/bin/env bash
set -euo pipefail

HERE="$(dirname "$0")"
cd "$HERE"
if echo "$HERE" | grep -qv '^/'; then
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


required_files=(
    /usr/include/openssl/conf.h
    /usr/include/zlib.h
    /usr/include/x86_64-linux-gnu/ffi.h
    /usr/lib/tkConfig.sh
    /usr/lib/tclConfig.sh
    /usr/include/bzlib.h
    /usr/include/sqlite3.h
    /usr/bin/g++
    /usr/bin/gcc
    /usr/bin/make
    /usr/bin/curl
    /usr/bin/git
)

declare -A debian_packages
debian_packages[/usr/include/openssl/conf.h]="libssl-dev"
debian_packages[/usr/include/zlib.h]="zlib1g-dev"
debian_packages[/usr/include/x86_64-linux-gnu/ffi.h]="libffi-dev"
debian_packages[/usr/lib/tkConfig.sh]="tk-dev"
debian_packages[/usr/lib/tclConfig.sh]="tcl-dev"
debian_packages[/usr/include/bzlib.h]="libbz2-dev"
debian_packages[/usr/include/sqlite3.h]="libsqlite3-dev"
debian_packages[/usr/bin/g++]="g++ build-essential"
debian_packages[/usr/bin/gcc]="gcc build-essential"
debian_packages[/usr/bin/make]="build-essential"
debian_packages[/usr/bin/curl]="curl"
debian_packages[/usr/bin/git]="git"


missing_files=( )
for filename in "${required_files[@]}"; do
    if [[ ! -f "${filename}" ]]; then
        missing_files+=( "${filename}")
    fi
done

if [[ "${#missing_files[@]}" -gt 0 ]]; then 
    echo "Expected files not found: ${missing_files[@]}"
    if which apt-get >& /dev/null; then
        packages=( )
        for filename in "${missing_files[@]}"; do
            packages+=( ${debian_packages[$filename]} )
        done
        echo "Will attempt to install the following packages as a fix:"
        echo "${packages[@]}"
        sudo apt-get update && sudo apt-get install ${packages[@]}
    else
        echo "Can't install packages on non-debian systems yet."
        echo "Please install the corresponding packages manually and continue."
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