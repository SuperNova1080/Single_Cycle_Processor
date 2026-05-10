# MIPS Single-Cycle CPU

A fully functional 32-bit MIPS single-cycle processor implemented in Verilog, supporting a core subset of the MIPS instruction set. Simulated and verified with Icarus Verilog — all tests passing.

---

## Architecture Overview


The processor follows the classic single-cycle MIPS datapath: every instruction completes in exactly one clock cycle. The control unit decodes the opcode and drives all datapath muxes and memory enables.

---

## Supported Instructions

| Type   | Instructions           | Opcode / Funct    |
|--------|------------------------|-------------------|
| R-type | `ADD`, `SUB`           | `funct 0x20/0x22` |
| R-type | `AND`, `OR`            | `funct 0x24/0x25` |
| R-type | `SLT`                  | `funct 0x2A`      |
| I-type | `ADDI`                 | `op 0x08`         |
| I-type | `LW`                   | `op 0x23`         |
| I-type | `SW`                   | `op 0x2B`         |
| I-type | `BEQ`                  | `op 0x04`         |

---

## File Structure

```
.
├── adder.v            # 32-bit adder (used for PC+4 and branch target)
├── address_shift.v    # Left-shift-by-2 for branch offset
├── alu.v              # ALU: ADD, SUB, AND, OR, SLT
├── aluctl.v           # ALU control: decodes ALUOp + funct → ALUCtl
├── control.v          # Main control unit: opcode → control signals
├── datamem.v          # Data memory (128 x 32-bit words, sync write / async read)
├── instmem.v          # Instruction memory (128 bytes, byte-addressed)
├── mux.v              # 32-bit 2-to-1 mux
├── mux5bit.v          # 5-bit 2-to-1 mux (RegDst)
├── pc.v               # Program counter register
├── reg_file.v         # 32 x 32-bit register file
├── sign_extend.v      # 16-bit → 32-bit sign extender
├── SingleCycleCPU.v   # Top-level datapath
└── tb_SingleCycleCPU.v  # Testbench
```

---

## Simulation

### Requirements

- [Icarus Verilog](https://steveicarus.github.io/iverilog/) (`iverilog` + `vvp`)
- GTKWave (optional, for waveform viewing)

### Run

```bash
# Compile and simulate
iverilog -o sim.out *.v && vvp sim.out

# View waveforms (uncomment $dumpvars in testbench first)
gtkwave tb_SingleCycleCPU.vcd
```

### Test Results

The testbench runs a self-checking program covering all supported instructions:

```
==============================
  MIPS Single-Cycle CPU Test  
==============================
  PASS  ADDI      r1 = 0x00000063
  PASS  ADDI      r2 = 0x00000003
  PASS  ADD       r3 = 0x00000008
  PASS  LW        r4 = 0x00000008
  PASS  AND       r5 = 0x00000001
  PASS  OR        r6 = 0x00000007
  PASS  SLT       r7 = 0x00000001
  PASS  SW/LW    mem[0] = 0x00000008
------------------------------
  Results: 8 passed, 0 failed
==============================
```

### Loading Your Own Program

Instruction memory is loaded via `$readmemh`. Uncomment and update the path in `instmem.v`:

```verilog
$readmemh("path/to/your/program.mem", inst);
```

Each line in the `.mem` file is one byte in hex. Instructions are stored little-endian.

---

## Control Signal Table

| Instruction | RegDst | ALUSrc | MemtoReg | RegWrite | MemRead | MemWrite | Branch | ALUOp |
|-------------|--------|--------|----------|----------|---------|----------|--------|-------|
| R-type      | 1      | 0      | 0        | 1        | 0       | 0        | 0      | 10    |
| ADDI        | 0      | 1      | 0        | 1        | 0       | 0        | 0      | 00    |
| LW          | 0      | 1      | 1        | 1        | 1       | 0        | 0      | 00    |
| SW          | 0      | 1      | 0        | 0        | 0       | 1        | 0      | 00    |
| BEQ         | 0      | 0      | 0        | 0        | 0       | 0        | 1      | 01    |

---

## Design Notes

- **Single-cycle**: every instruction completes in one clock cycle; clock period must be long enough for the critical path (typically the LW path: PC → InstMem → RegFile → ALU → DataMem → RegFile)
- **Memory**: both instruction and data memories are word-addressed internally (`address[31:2]`); instruction memory is byte-addressed externally to support `$readmemh` hex files
- **Branch**: `PCSrc = Branch & zero`; the branch target is `PC+4 + (sign_extend(imm16) << 2)`
- **Register 0**: resets to 0; avoid writing to `$zero` in your programs

---

## References

- Patterson & Hennessy, *Computer Organization and Design* (MIPS Edition) — Chapter 4
