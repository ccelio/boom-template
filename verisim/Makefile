base_dir=$(abspath ..)
sim_dir=$(abspath .)
build_dir=$(sim_dir)/generated-src
output_dir=./output

SIMFLAGS=
DUMP_FLAG=-v
# permissive flags guard the VCS plusArgs parameters. Unused for  Verilator.
PERMISSIVE=
PERMISSIVEOFF=



include $(base_dir)/Makefrag-variables

sim = $(sim_dir)/simulator-$(PROJECT)-$(CONFIG)
sim_debug = $(sim_dir)/simulator-$(PROJECT)-$(CONFIG)-debug
sim_fsdb_debug = $(sim_dir)/simulator-$(PROJECT)-$(CONFIG)-fsdb-debug

default: $(sim)

debug: $(sim_debug)
fsdb_debug: $(sim_fsdb_debug)

CXXFLAGS := $(CXXFLAGS) -O1 -std=c++11 -I$(RISCV)/include -D__STDC_FORMAT_MACROS
LDFLAGS := $(LDFLAGS) -L$(RISCV)/lib -Wl,-rpath,$(RISCV)/lib -L$(sim_dir) -lfesvr -lpthread

include $(base_dir)/Makefrag
include $(sim_dir)/Makefrag-verilator

sim_csrcs += \
	$(base_dir)/rocket-chip/src/main/resources/csrc/emulator.cc

model_dir = $(build_dir)/$(long_name)
model_dir_debug = $(build_dir)/$(long_name).debug

model_header = $(model_dir)/V$(MODEL).h
model_header_debug = $(model_dir_debug)/V$(MODEL).h

model_mk = $(model_dir)/V$(MODEL).mk
model_mk_debug = $(model_dir_debug)/V$(MODEL).mk

$(model_mk): $(sim_vsrcs) $(INSTALLED_VERILATOR)
	rm -rf $(build_dir)/$(long_name)
	mkdir -p $(build_dir)/$(long_name)
	$(VERILATOR) $(VERILATOR_FLAGS) -Mdir $(build_dir)/$(long_name) \
	-o $(sim) $< $(sim_csrcs) -LDFLAGS "$(LDFLAGS)" \
	-CFLAGS "-I$(build_dir) -include $(model_header)"
	touch $@

# Building simulator also builds makefile .d fragment that is configuration-specific.
$(build_dir)/$(long_name).d : $(sim) ;
$(sim): $(model_mk) $(sim_csrcs)
	$(MAKE) VM_PARALLEL_BUILDS=1 -C $(build_dir)/$(long_name) -f V$(MODEL).mk


$(model_mk_debug): $(sim_vsrcs) $(INSTALLED_VERILATOR)
	mkdir -p $(build_dir)/$(long_name).debug
	$(VERILATOR) $(VERILATOR_FLAGS) -Mdir $(build_dir)/$(long_name).debug --trace \
	-o $(sim_debug) $< $(sim_csrcs) -LDFLAGS "$(LDFLAGS)" \
	-CFLAGS "-I$(build_dir) -include $(model_header_debug)"
	touch $@

$(sim_debug): $(model_mk_debug) $(sim_csrcs)
	$(MAKE) VM_PARALLEL_BUILDS=1 -C $(build_dir)/$(long_name).debug -f V$(MODEL).mk

$(sim_fsdb_debug):
	$(error ERROR: verilator cannot produce fsdb files)

list:
	@grep '^[^#[:space:]].*:' Makefile

clean:
	rm -rf generated-src ./simulator-*
