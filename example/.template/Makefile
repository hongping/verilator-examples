_makefile_path := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))

export VERILATOR_ROOT ?= /home/hongping/verilator

OUTDIR ?= $(_makefile_path)/output
TARGET ?= $(OUTDIR)/simv

$(TARGET): Makefile filelist.f top.sv
	$(VERILATOR_ROOT)/bin/verilator --binary --build --timing \
	--sched-zero-delay -Mdir $(OUTDIR) -o $(TARGET) \
	-f $(_makefile_path)/filelist.f

run: $(TARGET)
	@$(TARGET)

clean:
	rm -rf $(OUTDIR)

.PHONY: run all clean