#!/bin/bash
echo "select the operation ************  1)operation 1 2)operation 2 3)operation 3 4)operation 4 "

read n
case $n in
    1) echo "one" ;;
    2) echo "two" ;;
    3) echo "three" ;;
    4) echo "four" ;;
    *) invalid option;;
esac