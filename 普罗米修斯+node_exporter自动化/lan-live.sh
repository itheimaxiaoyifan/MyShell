#!/bin/bash
for i in {100..199}
do
ping -c 1 10.163.1.$i &>> /dev/null && echo "10.163.1.$i up" || echo "10.163.1.$i down"  &
done
wait
