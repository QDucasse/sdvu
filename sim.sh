#!/bin/sh
STANDARD=02
CONSTANTS_FILE=sdvu_constants
TB_HELPERS=tb_helpers

echo "Analyzing constants file needed for further analysis"
ghdl -a --std=$STANDARD src/$CONSTANTS_FILE.vhd

echo "Analyzing source file"
ghdl -a --std=$STANDARD src/$1.vhd

echo "Analyzing testbench helpers"
ghdl -a --std=$STANDARD tests/$TB_HELPERS.vhd

echo "Analyzing testbench"
ghdl -a --std=$STANDARD tests/$1_tb.vhd

echo "Running simulation"
ghdl -r --std=$STANDARD $1_tb --wave=$1_tb.ghw

echo "Opening gtkwave"
gtkwave $1_tb.ghw
