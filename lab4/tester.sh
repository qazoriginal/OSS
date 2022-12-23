#!/bin/bash

bash "$1" 1 2 3
ONE=$RANDOM
TWO=$RANDOM
THREE=$RANDOM
FOUR=$RANDOM
FIVE=$RANDOM
bash "$1" $ONE $TWO $THREE $FOUR $FIVE
bash "$1" foo bar foobar "foo bar"
bash "$1" foo --foo --help -l
