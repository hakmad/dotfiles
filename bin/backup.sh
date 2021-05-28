#!/bin/bash

BACKUPDIR=~/.backup/
CURRENTDIR=$(pwd)

mkdir $BACKUPDIR
cd $BACKUPDIR

cp -r ~/.dotfiles ./dotfiles
cp -r ~/downloads .
cp -r ~/media .
cp -r ~/workspace .

tar -czf backup.tar.gz *

mv backup.tar.gz ~/

cd $CURRENTDIR
rm -rf $BACKUPDIR
