# Basic Synthesizable Hardware Designs

This repository is a growing collection of small, synthesizable Verilog hardware designs. The modules are intended to support digital design learning and can also be integrated directly into larger projects as reusable black-box building blocks.

The current synthesis flow targets Yosys with Xilinx 7-series technology mapping. Vivado support is planned for a future update.

## Current Designs

| Design | Module | Description |
| --- | --- | --- |
| Four-input adder | `add4_balanced` | Adds four 8-bit unsigned inputs using a balanced adder structure. |
| Four-input adder | `add4_cascade` | Adds four 8-bit unsigned inputs through a cascaded adder structure. |
| Three-input maximum | `max3_balanced` | Selects the maximum of three 8-bit unsigned inputs using a balanced comparison structure. |
| Three-input maximum | `max3_cascade` | Selects the maximum of three 8-bit unsigned inputs through cascaded comparisons. |
| Eight-bit left shifter | `left_shifter` | Shifts the input left by one bit and inserts zero at bit 0. |
| Eight-bit left rotator | `left_rotator` | Rotates the input left by one bit and moves bit 7 to bit 0. |
| Variable eight-bit left shifter | `left_shifter_variable` | Shifts the input left by the unsigned 3-bit `shamt` value and inserts zeros at bit 0. |
| Variable eight-bit left rotator | `left_rotator_variable` | Rotates the input left by the unsigned 3-bit `shamt` value. |
| RV32I register file | `register_file` | 32 registers of 32 bits with two asynchronous read ports, one synchronous write port, and a hardwired zero register. |
| RV32I core | `rv32i_core` | Single-cycle RV32I integer core with instruction fetch, register, ALU, branch, jump, load, and store datapaths. |

The two implementations of each adder and maximum function provide a simple basis for comparing RTL structure, synthesized logic, timing, and resource usage. The shifter and rotator designs demonstrate common fixed-width bit-manipulation building blocks.

The variable shifter and rotator accept `shamt[2:0]`, so they support shift or rotation amounts from 0 through 7. A shift amount of 0 leaves the input unchanged. The variable shifter discards bits shifted out of bit 7 and fills the low bits with zeros; the variable rotator wraps those bits back into the low positions.

The `register_file` module follows the standard RV32I register-file organization. `rs1` and `rs2` select the two combinational read ports, while `rd`, `write_data`, and `reg_write` control a write on the rising edge of `clk`. Register `x0` always reads as zero and ignores writes.

## Repository Layout

```text
design/       Synthesizable Verilog RTL modules
tb/           Simulation testbenches
tests/RV32I/  RV32I assembly tests and instruction images
design/RV32I/ RV32I core RTL
Makefile      Build, simulation, synthesis, and cleanup targets
run_all.sh    Yosys synthesis flow for all current designs
netlist/      Generated synthesis netlists, ignored by Git
reports/      Generated synthesis reports, ignored by Git
```

## Requirements

- Yosys
- `xdot` and Graphviz for schematic viewing
- Icarus Verilog and its `vvp` runtime
- GNU Make
- Clang with RISC-V support, LLVM `ld.lld`, and `llvm-objcopy` for assembling the included RV32I tests, or a compatible RISC-V toolchain
- A shell environment capable of running the synthesis script

The synthesis script uses the Yosys `synth_xilinx` flow with the `xc7` family.

## Simulation

From the repository root, compile and run the comparison testbench with Make:

```bash
make tb-build
make tb-run
```

The `tb-run` target also builds the testbench when needed. The shorter `make sim` target is an alias for the same compile-and-run workflow.

The testbench compares all current designs against reference results, including directed cases, exhaustive variable shift amounts, all 32 register-file addresses, the `x0` behavior, and 5,000 random tests. It also displays representative outputs and generates `waveform.vcd` for waveform inspection. Generated simulation output is excluded by `.gitignore`.

## RV32I Core

The core is located in `design/RV32I/rv32i_core.v` and is intended as a compact learning implementation of the RV32I base integer ISA. It has a combinational instruction interface and a byte-addressable data-memory interface. `FENCE` is treated as a no-op, while `ECALL` and `EBREAK` halt the simulation core through the `halted` output.

Run the included core test with the checked-in instruction image:

```bash
make rv32i-run
```

The testbench prints a cycle-by-cycle assembly-style instruction trace, including the program counter and decoded operands. Example output is formatted as `PC=00000008  add x3, x1, x2`. Unknown instruction encodings are displayed as `.word` values.

The separate testbench in `tb/RV32I/` checks arithmetic, branches, stores, loads, and shifts. Assembly source is in `tests/RV32I/basic.S`. When a RISC-V-capable Clang or GNU toolchain is installed, compile it with:

```bash
make rv32i-asm
```

The resulting `basic.hex` can be loaded by the core testbench. Set `RV32I_AS` and `RV32I_OBJCOPY` to use another compatible toolchain.

Run the broader instruction-coverage program with:

```bash
make rv32i-coverage-run
```

This separate test exercises upper-immediate instructions, register and immediate ALU operations, logical and arithmetic shifts, signed and unsigned comparisons, all conditional branch variants, `jal`, stores, loads, and byte/halfword sign extension. Its assembly source is `tests/RV32I/coverage.S`, and its expected memory signatures are checked by `tb/RV32I/tb_rv32i_coverage.v`.

## Synthesis

Run the complete Yosys synthesis flow with:

```bash
make synth
```

The script synthesizes each current top-level module, including `rv32i_core`, and writes JSON netlists to `netlist/` and synthesis logs to `reports/`. These directories are generated artifacts and are intentionally not tracked in Git.

## Schematic Viewing

View the RTL schematic for any standalone design with `xdot`:

```bash
make schematic DESIGN=add4_balanced
make schematic DESIGN=left_rotator
```

The `DESIGN` value must match a Verilog filename in `design/` without the `.v` extension. The default is `add4_balanced`. The generated DOT file is temporary and ignored by Git.

## Common Commands

```bash
make help       # List available targets
make all        # Run simulation and synthesis
make clean      # Remove simulation outputs
make distclean  # Remove simulation and synthesis outputs
```

## Reuse in Larger Designs

Each file in `design/` defines a standalone top-level module with explicit ports and no hidden dependencies. A module can be instantiated in another Verilog design as a reusable component, for example:

```verilog
add4_balanced u_add4 (
    .a(a),
    .b(b),
    .c(c),
    .d(d),
    .sum(sum)
);
```

When adding a new design, keep the implementation synthesizable, place its RTL in `design/`, and add focused verification in `tb/` where appropriate. Designs should remain independently usable so they can serve both as learning examples and as black-box components in larger systems.

## Future Development

Planned improvements include:

- Additional reusable synthesizable modules
- More focused testbenches and automated checks
- Vivado synthesis and implementation flows
- Comparative resource and timing reports across implementations
