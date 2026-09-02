IVERILOG ?= iverilog
VVP ?= vvp
YOSYS ?= yosys
XDOT ?= xdot
SIM ?= simulation.out
RV32I_SIM ?= rv32i_simulation.out
RV32I_COVERAGE_SIM ?= rv32i_coverage_simulation.out
RV32I_AS ?= clang
RV32I_OBJCOPY ?= llvm-objcopy
RV32I_LD ?= ld.lld
DESIGN ?= add4_balanced
SCHEMATIC ?= schematic.dot

RTL_SOURCES := $(wildcard design/*.v)
TB_SOURCE := tb/tb_compare.v

.PHONY: all help tb-build tb-run sim rv32i-build rv32i-run rv32i-asm rv32i-coverage-build rv32i-coverage-run rv32i-coverage-asm synth schematic clean distclean

all: tb-run rv32i-run synth

help:
	@printf '%s\n' \
		'make tb-build  Compile the comparison testbench' \
		'make tb-run    Compile and run the comparison testbench' \
		'make rv32i-run Compile and run the RV32I core test' \
		'make rv32i-asm Compile tests/RV32I/*.S (requires RISC-V tools)' \
		'make rv32i-coverage-run Run the broader RV32I coverage test' \
		'make synth     Synthesize all designs with Yosys' \
		'make schematic View a design schematic (DESIGN=module)' \
		'make all       Run both simulations and synthesis' \
		'make clean     Remove simulation outputs' \
		'make distclean Remove simulation and synthesis outputs'

tb-build: $(SIM)

$(SIM): $(RTL_SOURCES) $(TB_SOURCE)
	$(IVERILOG) -o $@ $(TB_SOURCE) $(RTL_SOURCES)

tb-run: tb-build
	$(VVP) $(SIM)

sim: tb-run

rv32i-build:
	$(IVERILOG) -g2012 -o $(RV32I_SIM) tb/RV32I/tb_rv32i_core.v design/RV32I/rv32i_core.v design/register_file.v

rv32i-run: rv32i-build
	$(VVP) $(RV32I_SIM)

rv32i-asm:
	$(RV32I_AS) --target=riscv32 -march=rv32i -mabi=ilp32 -c -o tests/RV32I/basic.o tests/RV32I/basic.S
	$(RV32I_LD) -m elf32lriscv --image-base=0 -Ttext=0 -e _start -o tests/RV32I/basic.elf tests/RV32I/basic.o
	$(RV32I_OBJCOPY) -O binary tests/RV32I/basic.elf tests/RV32I/basic.bin
	od -An -tx1 -v tests/RV32I/basic.bin | awk '{ for (i = 1; i <= NF; i++) { byte[count % 4] = $$i; count++; if (count % 4 == 0) printf "%s%s%s%s\n", byte[3], byte[2], byte[1], byte[0] } }' > tests/RV32I/basic.hex

rv32i-coverage-build:
	$(IVERILOG) -g2012 -o $(RV32I_COVERAGE_SIM) tb/RV32I/tb_rv32i_coverage.v design/RV32I/rv32i_core.v design/register_file.v

rv32i-coverage-run: rv32i-coverage-build
	$(VVP) $(RV32I_COVERAGE_SIM)

rv32i-coverage-asm:
	$(RV32I_AS) --target=riscv32 -march=rv32i -mabi=ilp32 -c -o tests/RV32I/coverage.o tests/RV32I/coverage.S
	$(RV32I_LD) -m elf32lriscv --image-base=0 -Ttext=0 -e _start -o tests/RV32I/coverage.elf tests/RV32I/coverage.o
	$(RV32I_OBJCOPY) -O binary tests/RV32I/coverage.elf tests/RV32I/coverage.bin
	od -An -tx1 -v tests/RV32I/coverage.bin | awk '{ for (i = 1; i <= NF; i++) { byte[count % 4] = $$i; count++; if (count % 4 == 0) printf "%s%s%s%s\n", byte[3], byte[2], byte[1], byte[0] } }' > tests/RV32I/coverage.hex

synth:
	./run_all.sh

schematic:
	@test -f design/$(DESIGN).v || (printf 'Unknown design: %s\n' '$(DESIGN)' >&2; exit 1)
	$(YOSYS) -Q -p "read_verilog design/$(DESIGN).v; hierarchy -check -top $(DESIGN); proc; opt; show -format dot -prefix schematic $(DESIGN)"
	$(XDOT) $(SCHEMATIC)

clean:
	rm -f $(SIM) $(RV32I_SIM) $(RV32I_COVERAGE_SIM) waveform.vcd abc.history tb.out $(SCHEMATIC) tests/RV32I/basic.o tests/RV32I/basic.elf tests/RV32I/basic.bin tests/RV32I/coverage.o tests/RV32I/coverage.elf tests/RV32I/coverage.bin

distclean: clean
	rm -rf netlist reports