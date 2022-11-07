#!/bin/bash

grep "000000" ../bash.txt > /tmp/zeros
grep -v "000000" ../bash.txt > /tmp/nozeros
head -n 10 /tmp/zeros
tail -n 10 /tmp/zeros
head -n 10 /tmp/nozeros
tail -n 10 /tmp/nozeros
