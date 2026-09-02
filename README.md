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

The two implementations of each function provide a simple basis for comparing RTL structure, synthesized logic, timing, and resource usage.

## Repository Layout

```text
design/       Synthesizable Verilog RTL modules
tb/           Simulation testbenches
run_all.sh    Yosys synthesis flow for all current designs
netlist/      Generated synthesis netlists, ignored by Git
reports/      Generated synthesis reports, ignored by Git
```

## Requirements

- Yosys
- Icarus Verilog or another Verilog simulator
- A shell environment capable of running `run_all.sh`

The synthesis script uses the Yosys `synth_xilinx` flow with the `xc7` family.

## Simulation

From the repository root, compile and run the comparison testbench with Icarus Verilog:

```bash
iverilog -o simulation.out tb/tb_compare.v design/*.v
vvp simulation.out
```

The testbench compares the balanced and cascaded implementations against reference results, including directed cases and 5,000 random tests. It also generates `waveform.vcd` for waveform inspection. Generated simulation output is excluded by `.gitignore`.

## Synthesis

Run the complete Yosys synthesis flow with:

```bash
./run_all.sh
```

The script synthesizes each current top-level module and writes JSON netlists to `netlist/` and synthesis logs to `reports/`. These directories are generated artifacts and are intentionally not tracked in Git.

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
