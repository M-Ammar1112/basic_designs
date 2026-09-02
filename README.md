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
| Eight-bit left shifter | `left_shifter_8bit` | Shifts the input left by one bit and inserts zero at bit 0. |
| Eight-bit left rotator | `left_rotator_8bit` | Rotates the input left by one bit and moves bit 7 to bit 0. |
| Variable eight-bit left shifter | `left_shifter_variable_8bit` | Shifts the input left by the unsigned 3-bit `shamt` value and inserts zeros at bit 0. |
| Variable eight-bit left rotator | `left_rotator_variable_8bit` | Rotates the input left by the unsigned 3-bit `shamt` value. |

The two implementations of each adder and maximum function provide a simple basis for comparing RTL structure, synthesized logic, timing, and resource usage. The shifter and rotator designs demonstrate common fixed-width bit-manipulation building blocks.

The variable shifter and rotator accept `shamt[2:0]`, so they support shift or rotation amounts from 0 through 7. A shift amount of 0 leaves the input unchanged. The variable shifter discards bits shifted out of bit 7 and fills the low bits with zeros; the variable rotator wraps those bits back into the low positions.

## Repository Layout

```text
design/       Synthesizable Verilog RTL modules
tb/           Simulation testbenches
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
- A shell environment capable of running the synthesis script

The synthesis script uses the Yosys `synth_xilinx` flow with the `xc7` family.

## Simulation

From the repository root, compile and run the comparison testbench with Make:

```bash
make tb-build
make tb-run
```

The `tb-run` target also builds the testbench when needed. The shorter `make sim` target is an alias for the same compile-and-run workflow.

The testbench compares the balanced and cascaded implementations against reference results, including directed cases and 5,000 random tests. It also generates `waveform.vcd` for waveform inspection. Generated simulation output is excluded by `.gitignore`.

## Synthesis

Run the complete Yosys synthesis flow with:

```bash
make synth
```

The script synthesizes each current top-level module and writes JSON netlists to `netlist/` and synthesis logs to `reports/`. These directories are generated artifacts and are intentionally not tracked in Git.

## Schematic Viewing

View the RTL schematic for any standalone design with `xdot`:

```bash
make schematic DESIGN=add4_balanced
make schematic DESIGN=left_rotator_8bit
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
