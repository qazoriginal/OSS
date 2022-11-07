#!/bin/bash

echo Процессов ользователя:
whoami
ps -eF | grep -c "^$USER"
echo Процессов пользователя root:
ps -eF | grep -c "^root"
