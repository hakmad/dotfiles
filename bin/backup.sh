#!/bin/bash

mkdir ~/backup
cd ~/backup

cp -r ~/downloads .
cp -r ~/media .
cp -r ~/workspace .

tar -czf backup.tar.gz *
mv backup.tar.gz ~/

cd -
rm -rf ~/backup
