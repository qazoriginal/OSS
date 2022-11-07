#!/bin/bash

date >> /tmp/run.log
echo Hello, world!
#wc -l /tmp/run.log >&2
cat /tmp/run.log | wc -l >&2
