#!/bin/bash

find ~ -type f -name "*.txt" > /tmp/qaz
cat /tmp/qaz
cat /tmp/qaz | xargs du -acb 2>/dev/null | tail -1 | cut -f1
cat /tmp/qaz | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}'
rm /tmp/qaz
