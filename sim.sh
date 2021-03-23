#!/bin/sh
STANDARD=02

echo "Analyzing source file"
ghdl -a --std=$STANDARD src/$1.vhd

echo "Analyzing testbench"
ghdl -a --std=$STANDARD tests/$1_tb.vhd

echo "Running simulation"
ghdl -r --std=$STANDARD $1_tb --wave=$1_tb.ghw

echo "Opening gtkwave"
gtkwave $1_tb.ghw
