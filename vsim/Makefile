base_dir=$(abspath ..)
sim_dir=$(abspath .)
build_dir=$(sim_dir)/generated-src
output_dir=./output

SIMFLAGS=-q
DUMP_FLAG=+vcdplusfile=
DUMP_FSDB_FLAG=+fsdbfile=
# permissive flags guard the VCS plusArgs parameters.
PERMISSIVE=+permissive
PERMISSIVEOFF=+permissive-off


include $(base_dir)/Makefrag-variables

EXTRA_FIRRTL_ARGS=--infer-rw $(MODEL) --repl-seq-mem -c:$(MODEL):-o:$(build_dir)/$(notdir $(basename $@)).conf

sim = $(sim_dir)/simv-$(PROJECT)-$(CONFIG)
sim_debug = $(sim_dir)/simv-$(PROJECT)-$(CONFIG)-debug
sim_fsdb_debug = $(sim_dir)/simv-$(PROJECT)-$(CONFIG)-fsdb-debug

default: $(sim)
debug: $(sim_debug)
fsdb_debug: $(sim_fsdb_debug)

sim_vsrcs += \
	$(base_dir)/rocket-chip/src/main/resources/vsrc/TestDriver.v \
	$(base_dir)/rocket-chip/src/main/resources/vsrc/plusarg_reader.v \
	$(base_dir)/rocket-chip/src/main/resources/vsrc/SimDTM.v \
	$(build_dir)/$(long_name).behav_srams.v

VCS = vcs -full64

VCS_CC_OPTS = \
	-CC "-I$(VCS_HOME)/include" \
	-CC "-I$(RISCV)/include -I$(base_dir)/testchipip/csrc" \
	-CC "-std=c++11" \
	-CC "-Wl,-rpath,$(RISCV)/lib" \
	$(RISCV)/lib/libfesvr.so 

VCS_NONCC_OPTS = \
	+lint=all,noVCDE,noONGS,noUI -error=PCWM-L -timescale=1ns/10ps -quiet \
	+rad +v2k +vcs+lic+wait \
	+vc+list \
	-sverilog \
	+incdir+$(build_dir) \
	+define+CLOCK_PERIOD=1.0 $(sim_vsrcs) $(sim_csrcs) \
	+define+PRINTF_COND=$(TB).printf_cond \
	+define+STOP_COND=!$(TB).reset \
	+define+RANDOMIZE_MEM_INIT \
	+define+RANDOMIZE_REG_INIT \
	+define+RANDOMIZE_GARBAGE_ASSIGN \
	+define+RANDOMIZE_INVALID_ASSIGN \
	+define+RANDOMIZE_DELAY=2 \
	+libext+.v

VCS_OPTS = -notice -line $(VCS_NONCC_OPTS) $(VCS_CC_OPTS)

# Must place include here - verdi rule in Makefile requires VCS_NONCC_OPTS.
include $(base_dir)/Makefrag


$(build_dir)/$(long_name).behav_srams.v : $(build_dir)/$(long_name).conf $(mem_gen)
	cd $(build_dir) && \
	rm -f $@ && \
	$(mem_gen) $(build_dir)/$(long_name).conf >> $@.tmp && \
	mv $@.tmp $@

verilog: $(sim_vsrcs)

$(build_dir)/$(long_name).d : $(sim) ;
$(sim): $(sim_vsrcs) $(sim_csrcs)
	rm -rf csrc && $(VCS) $(VCS_OPTS) -o $@ \
	-debug_pp

$(sim_debug) : $(sim_vsrcs) $(sim_csrcs)
	rm -rf csrc && $(VCS) $(VCS_OPTS) -o $@ \
	+define+DEBUG -debug_pp

$(sim_fsdb_debug) : $(sim_vsrcs) $(sim_csrcs)
	rm -rf csrc && $(VCS) $(VCS_OPTS) -o $@ \
	+define+DEBUG -debug_pp +define+FSDB -debug_all -debug_access+all

clean:
	rm -rf generated-src csrc simv-* ucli.key vc_hdrs.h ../Makefrag.pkgs ../lib

.PHONY: clean



