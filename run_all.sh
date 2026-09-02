#!/bin/bash

set -e

mkdir -p reports
mkdir -p netlist


echo ""
echo "========================================"
echo " ADD4 CASCADE SYNTHESIS"
echo "========================================"

yosys -Q -l reports/add4_cascade.log -p "
read_verilog design/add4_cascade.v;
hierarchy -check -top add4_cascade;
synth_xilinx -family xc7 -top add4_cascade;
stat;
ltp;
write_json netlist/add4_cascade.json;
"


echo ""
echo "========================================"
echo " ADD4 BALANCED SYNTHESIS"
echo "========================================"

yosys -Q -l reports/add4_balanced.log -p "
read_verilog design/add4_balanced.v;
hierarchy -check -top add4_balanced;
synth_xilinx -family xc7 -top add4_balanced;
stat;
ltp;
write_json netlist/add4_balanced.json;
"


echo ""
echo "========================================"
echo " MAX3 CASCADE SYNTHESIS"
echo "========================================"

yosys -Q -l reports/max3_cascade.log -p "
read_verilog design/max3_cascade.v;
hierarchy -check -top max3_cascade;
synth_xilinx -family xc7 -top max3_cascade;
stat;
ltp;
write_json netlist/max3_cascade.json;
"


echo ""
echo "========================================"
echo " MAX3 BALANCED SYNTHESIS"
echo "========================================"

yosys -Q -l reports/max3_balanced.log -p "
read_verilog design/max3_balanced.v;
hierarchy -check -top max3_balanced;
synth_xilinx -family xc7 -top max3_balanced;
stat;
ltp;
write_json netlist/max3_balanced.json;
"


echo ""
echo "========================================"
echo " ALL SYNTHESIS COMPLETED"
echo "========================================"
echo ""
echo "Logs:"
echo "reports/add4_cascade.log"
echo "reports/add4_balanced.log"
echo "reports/max3_cascade.log"
echo "reports/max3_balanced.log"
echo ""