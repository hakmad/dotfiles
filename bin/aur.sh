#!/bin/bash

DOWNLOADS_DIR=~/downloads/.aur/
mkdir -p $DOWNLOADS_DIR

git clone https://aur.archlinux.org/$1 $DOWNLOADS_DIR$1

cd $DOWNLOADS_DIR$1
makepkg -si
cd -

rm -rf $DOWNLOADS_DIR$1
