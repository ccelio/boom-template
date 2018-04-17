#! /bin/bash

# This script will:
#  * Build a new Spike+riscv-fesvr+riscv-pk combo at $RISCV/logger,
#  * Rename the spike in $RISCV/logger/bin to `lspike`.
#  * This lspike will output the commit log stream to stderr.

# top-level
git submodule update --init
(cd rocket-chip && git submodule update --init riscv-tools)
(cd rocket-chip/riscv-tools && git submodule update --init --recursive riscv-isa-sim riscv-fesvr riscv-pk)

echo "cd rocket-chip/riscv-tools"
cd rocket-chip/riscv-tools
f=build-logger.sh

if [[ ! -e "$f" ]]
then
	# If file doesn't exist, generate a new build script file.
	echo "Generating script: rocket-chip/riscv-tools/$f"
	echo "#! /bin/bash" >> $f
	echo "#" >> $f
	echo "# Script to build RISC-V ISA simulator, proxy kernel, and GNU toolchain with commit log output." >> $f
	echo "# Tools will be installed to \$RISCV/logger." >> $f
	echo "" >> $f
	echo ". build.common" >> $f
	echo "" >> $f
	echo "echo "Starting RISC-V Toolchain build process"" >> $f
	echo "echo "Tools will be installed to \$RISCV/logger."" >> $f
	echo "" >> $f
	echo "build_project riscv-fesvr --prefix=\$RISCV/logger" >> $f
	echo "build_project riscv-isa-sim --prefix=\$RISCV/logger --with-fesvr=\$RISCV/logger --with-isa=rv64imafd --enable-commitlog" >> $f
	echo "CC= CXX= build_project riscv-pk --prefix=\$RISCV/logger --host=riscv64-unknown-elf" >> $f
	echo "" >> $f
	echo "mv \$RISCV/logger/bin/spike \$RISCV/logger/bin/lspike" >> $f
	echo "echo \"RISC-V Toolchain installation (with commit logging) completed!\"" >> $f
else
	echo "Using existing $f script."
fi

chmod a+x $f && echo "./$f" && ./$f
retVal=$?
if [ ! $retVal -eq 0 ]; then
    echo "A error has been encountered while building the toolchain."
fi
exit $retVal
