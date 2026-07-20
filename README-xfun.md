# xfun: the Blackbird fun ISA extension

This is a fork of [riscv-gnu-toolchain] carrying one addition: assembler
and disassembler support for **`xfun`**, the vendor RISC-V extension used
by the Blackbird combinator graph-reduction accelerator.

Everything else is upstream. The change is kept as a **patch against the
`binutils` submodule** (`patches/0001-riscv-xfun-fn-assembler-support.patch`)
rather than a submodule fork, so this repository stays a thin, rebasable
fork of upstream.

## Use

```bash
git clone --recursive https://github.com/hamsterlabz/riscv-gnu-toolchain
cd riscv-gnu-toolchain
./apply-xfun.sh                  # patch the binutils submodule
./configure --prefix=/opt/riscv --with-arch=rv32ima_zicsr --with-abi=ilp32
make                             # or: make newlib / make linux
```

`./apply-xfun.sh --check` dry-runs it; `--revert` undoes it. If you only
need the assembler, `git submodule update --init binutils` is enough
before applying.

## What it adds

Enable per-invocation with `-march=..._xfun`:

```bash
riscv32-unknown-elf-as -march=rv32imf_zicsr_xfun foo.S -o foo.o
riscv32-unknown-elf-objdump -d foo.o          # decodes fn.* back
```

| Group | Mnemonics |
|---|---|
| Reduction primitives | `fn.y` `fn.seq` `fn.force` `fn.box` `fn.enter` |
| Recursion schemes | `fn.cata` `fn.ana` `fn.para` `fn.hylo` |
| Host value movement | `fn.tor` `fn.update` `fn.databox` |
| Application-tree data words | `fn.link` `fn.elink` `fn.combi.t<type>` |

`fn.link` / `fn.elink` / `fn.combi` encode 32-bit **data** words (their low
two bits are not `0b11`, so they are not RISC-V instructions). They are
emitted directly by gas `md_assemble` instead of through the opcode table,
and the disassembler renders them back.

The patch touches `bfd/elfxx-riscv.c`, `gas/config/tc-riscv.c`,
`include/opcode/riscv{,-opc}.h`, `opcodes/riscv-{dis,opc}.c` — additions
only, no upstream lines removed. It is written against **binutils 2.46**.

## Related

[LambdaLinux](https://github.com/hamsterlabz/LambdaLinux) builds a Yocto
distribution for the Blackbird SoC and carries the same change rebased
onto the binutils version its Yocto release ships.

[riscv-gnu-toolchain]: https://github.com/riscv-collab/riscv-gnu-toolchain
