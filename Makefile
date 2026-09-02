IVERILOG ?= iverilog
VVP ?= vvp
YOSYS ?= yosys
XDOT ?= xdot
SIM ?= simulation.out
DESIGN ?= add4_balanced
SCHEMATIC ?= schematic.dot

RTL_SOURCES := $(wildcard design/*.v)
TB_SOURCE := tb/tb_compare.v

.PHONY: all help tb-build tb-run sim synth schematic clean distclean

all: tb-run synth

help:
	@printf '%s\n' \
		'make tb-build  Compile the comparison testbench' \
		'make tb-run    Compile and run the comparison testbench' \
		'make synth     Synthesize all designs with Yosys' \
		'make schematic View a design schematic (DESIGN=module)' \
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

schematic:
	@test -f design/$(DESIGN).v || (printf 'Unknown design: %s\n' '$(DESIGN)' >&2; exit 1)
	$(YOSYS) -Q -p "read_verilog design/$(DESIGN).v; hierarchy -check -top $(DESIGN); proc; opt; show -format dot -prefix schematic $(DESIGN)"
	$(XDOT) $(SCHEMATIC)

clean:
	rm -f $(SIM) waveform.vcd abc.history tb.out $(SCHEMATIC)

distclean: clean
	rm -rf netlist reports