#!/bin/bash


if [ -z $1 ] || [ -z $2 ]
then
  echo -e "[+] ./compile <file> <arch>"
  echo -e "\t<file> = name without .asm"
  echo -e "\t<arch> = 32 | 64"
  exit
fi

if [ $2 -eq "64" ]
then
  nasm -f elf64 $1.asm -o $1.o
  ld $1.o -o ./bin/$1
  echo -e "\n[+] ./bin/$1\n"
elif [ $2 -eq "32" ]
then
  nasm -f elf32 $1.asm -o $1.o
  gcc -m32 $1.o -o ./bin/$1
  echo "[+] ./bin/$1"
fi

