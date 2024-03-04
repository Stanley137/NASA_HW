#!/bin/bash
cd code
g++ helloworld.cpp
./a.out
cd ..
cp code/output2.txt hello.txt
if [[ -d .code.backup ]]; then rm -r .code.backup; fi
cp -r code .code.backup
rm link1
rm link2
rm link3
if [[ -d link1 ]]; then rm -r link1; fi
if [[ -d link2 ]]; then rm -r link2; fi
if [[ -d link3 ]]; then rm -r link3; fi
ln -s code/helloworld.cpp link1
ln -s .code.backup link2
ln -s link2 link3
cp hello.txt link4
