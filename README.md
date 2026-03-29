# 4-Bit ALU Design

Done by Vighnesh Das with Swayam and Ammar

![ALU Architecture](docs/architecture.png)

## 📌 Overview

This repository implements a modular **4-bit Arithmetic Logic Unit (ALU)** in Verilog HDL using a clean, synthesizable design style.
The ALU supports logical and arithmetic operations, operand negation control, and status flags for downstream digital systems.

## ⚙️ Features

- 4-bit datapath with combinational outputs
- Operations: `AND`, `OR`, `XOR`, `ADD`, `SUB`
- Operand control bits for negation:
  - `op[3]` -> negate `A`
  - `op[2]` -> negate `B`
- Carry Look-Ahead Adder (CLA) for fast arithmetic
- Status outputs:
  - `cout` (carry out)
  - `neg`  (sign bit of result)
  - `zero` (high when result is zero)
- Exhaustive testbench over all:
  - opcodes (`0000` to `1111`)
  - input vectors (`A=0..15`, `B=0..15`)

## 🧠 Architecture Explanation

The design is partitioned into reusable building blocks:

- `mux_2.v`: 2:1 multiplexer (parameterized width)
- `mux_4.v`: 4:1 multiplexer built from `mux_2`
- `look_ahead_adder.v`: 4-bit CLA using parallel `Generate`/`Propagate` equations
- `alu.v`: top-level ALU integration and flag generation

### Datapath summary

1. `A` and `B` pass through negation-control multiplexers.
2. A conditioned logic path computes `AND`, `OR`, `XOR`.
3. A conditioned arithmetic path computes `ADD/SUB` with CLA.
4. `op[1:0]` selects final output via `mux_4`.

### Carry Look-Ahead logic

For each bit `i`:

- `G[i] = A[i] & B[i]`
- `P[i] = A[i] ^ B[i]`

Carries are computed in parallel:

```verilog
c1 = g0 | (p0 & cin);
c2 = g1 | (p1 & g0) | (p1 & p0 & cin);
c3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & cin);
cout = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & cin);
```

## 🔢 Opcode Table

| op[3] | op[2] | op[1:0] | Effective Operation |
|------:|------:|:-------:|---------------------|
| 0 | 0 | 00 | `A & B` |
| 0 | 0 | 01 | `A | B` |
| 0 | 0 | 10 | `A ^ B` |
| 0 | 0 | 11 | `A + B` |
| 0 | 1 | 11 | `A - B` (`A + ~B + 1`) |
| 1 | x | 00/01/10 | Logic with `~A` |
| x | 1 | 00/01/10 | Logic with `~B` |
| 1 | 1 | 11 | `~A + ~B + 1` |

> Note: NOT can be emulated through operand negation (for example, `~A` can be observed directly through logic-path combinations).

## 🛠️ Tools Used

- **Verilog HDL** for RTL design
- **ModelSim / Questa** for simulation
- **Icarus Verilog + GTKWave** for open-source simulation and waveform viewing
- **KiCad** for conceptual schematic/PCB representation

## ▶️ How to Run Simulation

### Option 1: Icarus Verilog + GTKWave

```bash
cd 4bit-alu
iverilog -o alu_sim src/mux_2.v src/mux_4.v src/look_ahead_adder.v src/alu.v testbench/alu_tb.v
vvp alu_sim
gtkwave alu_tb.vcd
```

### Option 2: ModelSim/Questa

```tcl
vlib work
vlog src/mux_2.v src/mux_4.v src/look_ahead_adder.v src/alu.v testbench/alu_tb.v
vsim alu_tb
run -all
add wave *
```

## 📊 Sample Output

```text
Starting exhaustive ALU validation (all opcodes and all 4-bit input pairs)...
--- Testing opcode 0000 ---
--- Testing opcode 0001 ---
...
--- Testing opcode 1111 ---
Simulation complete.
Total tests: 4096
Total errors: 0
PASS: All vectors matched the reference model.
```

![Waveform](docs/waveform.png)

## 🚀 Future Scope

- Add overflow flag and signed arithmetic mode
- Parameterize ALU width (8/16/32-bit variants)
- Add shift and rotate operations
- Add constrained-random and assertion-based verification
- Add synthesis scripts and timing reports for FPGA targets

## Repository Structure

```text
4bit-alu/
|-- src/
|   |-- alu.v
|   |-- look_ahead_adder.v
|   |-- mux_2.v
|   `-- mux_4.v
|-- testbench/
|   `-- alu_tb.v
|-- kicad/
|   |-- alu_schematic.kicad_sch
|   |-- alu_pcb.kicad_pcb
|   `-- symbols.lib
|-- docs/
|   |-- architecture.png
|   `-- waveform.png
|-- README.md
|-- LICENSE
`-- .gitignore
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
