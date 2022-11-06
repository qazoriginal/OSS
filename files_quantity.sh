#!/bin/bash
echo Домашний каталог пользователя
whoami
cd
echo содержит обычных файлов:
let A=$(ls -l | grep -c "^-")
echo $A
echo скрытых файлов:
let B=$(ls -la | grep -c "^-")
let C=$B-$A
echo $C
