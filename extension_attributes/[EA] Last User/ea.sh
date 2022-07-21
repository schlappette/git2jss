#!/bin/bash


lastuser=$(last -1 -t console | awk '{print $1}')

echo "<result>${lastuser}</result>"