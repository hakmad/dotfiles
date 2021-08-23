#!/bin/bash

git clone https://aur.archlinux.org/$1 ~/downloads/$1

cd ~/downloads/$1
makepkg -si
cd -

rm -rf ~/downloads/$1
