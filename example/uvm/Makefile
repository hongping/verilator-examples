_makefile_path := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

export VERILATOR_ROOT ?= /home/hongping/verilator
export UVM_HOME ?= ../../packages/uvm/src

OUTDIR ?= $(_makefile_path)/output
TARGET ?= $(OUTDIR)/simv

$(TARGET): Makefile filelist.f top.sv
	$(VERILATOR_ROOT)/bin/verilator --binary --build --timing \
	--sched-zero-delay -Wno-WIDTH -Wno-CASTCONST -j 0 -Mdir $(OUTDIR) -o $(TARGET) \
	+define+UVM_NO_DPI +incdir+$(UVM_HOME) $(UVM_HOME)/uvm_pkg.sv \
	-MAKEFLAGS "OBJCACHE= CXX=clang++ LINK=clang++" -CFLAGS "-std=c++20" \
	--top top -f $(_makefile_path)/filelist.f

run: $(TARGET)
	$(TARGET) +UVM_TESTNAME=base_test +verilator+seed+0

clean:
	rm -rf $(OUTDIR)

.PHONY: run all clean
