IVERILOG ?= iverilog
VVP ?= vvp
SIM ?= simulation.out

RTL_SOURCES := $(wildcard design/*.v)
TB_SOURCE := tb/tb_compare.v

.PHONY: all help tb-build tb-run sim synth clean distclean

all: tb-run synth

help:
	@printf '%s\n' \
		'make tb-build  Compile the comparison testbench' \
		'make tb-run    Compile and run the comparison testbench' \
		'make synth     Synthesize all designs with Yosys' \
		'make all       Run simulation and synthesis' \
		'make clean     Remove simulation outputs' \
		'make distclean Remove simulation and synthesis outputs'

tb-build: $(SIM)

$(SIM): $(RTL_SOURCES) $(TB_SOURCE)
	$(IVERILOG) -o $@ $(TB_SOURCE) $(RTL_SOURCES)

tb-run: tb-build
	$(VVP) $(SIM)

sim: tb-run

synth:
	./run_all.sh

clean:
	rm -f $(SIM) waveform.vcd

distclean: clean
	rm -rf netlist reports