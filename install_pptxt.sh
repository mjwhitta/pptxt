#!/usr/bin/env bash

usage() {
    echo "Usage: ${0/*\//} [install_dir]"
    echo "Options:"
    echo "    -h"
    echo "        Display this help message"
    echo
    exit $1
}

if [ $# -gt 1 ]; then
    usage 1
fi

INSTALL_DIR="$HOME/bin"
case "$1" in
    "-h"|"--help") usage 0
        ;;
    *)
        if [ "$1" ]; then
            INSTALL_DIR="$1"
        fi
        ;;
esac

echo -n "Installing pptxt..."

# Save install location
cwd=$(pwd)

# Make sure INSTALL_DIR exists and go to it
mkdir -p $INSTALL_DIR && cd $INSTALL_DIR

# Copy
cp $cwd/pptxt.rb pptxt

echo "done!"
