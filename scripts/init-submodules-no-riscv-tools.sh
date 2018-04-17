#! /bin/bash

# Script for faster checkout if you already have installed your RISC-V tools.

# top-level
git submodule update --init
# rocket-chip (skip tools)
(cd rocket-chip && git submodule update --init --recursive hardfloat chisel3 firrtl)
# Skip riscv-tools.
# torture submodules
(cd torture && git submodule update --init --recursive)
