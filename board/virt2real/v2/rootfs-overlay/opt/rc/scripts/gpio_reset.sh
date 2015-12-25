#!/bin/bash
sudo echo "set gpio $1 output 1" > /dev/v2r_gpio
sleep 3
sudo echo "set gpio $1 output 0" > /dev/v2r_gpio
