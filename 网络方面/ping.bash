#!/bin/bash
for i in {100..199}
do
ping -c 1 192.168.1.$i & >> /dev/null && echo "192.168.1.$i up" || echo "192.168.1.$i down" &
done
wait