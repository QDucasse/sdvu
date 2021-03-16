#!/bin/sh

echo "Analyzing source file"
ghdl -a ../src/$1.vhd --std=08

echo "Analyzing testbench"
ghdl -a ../tests/$1_tb.vhd

echo "Running simulation"
ghdl -r $1_tb --wave=$1_tb.ghw

echo "Opening gtkwave"
gtkwave $1_tb.ghw
