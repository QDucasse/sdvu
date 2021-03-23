#!/bin/sh

echo "Analyzing source file"
ghdl -a --std=08 src/$1.vhd

echo "Analyzing testbench"
ghdl -a --std=08 tests/$1_tb.vhd

echo "Running simulation"
ghdl -r --std=08 $1_tb --wave=$1_tb.ghw 

echo "Opening gtkwave"
gtkwave $1_tb.ghw
